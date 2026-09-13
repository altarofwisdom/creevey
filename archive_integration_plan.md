# Plan d'Intégration : Lecture Transparente des Archives (ZIP/RAR/7Z)

Ce document détaille l'architecture et les effets de bord potentiels de l'intégration du framework `XADMaster` dans Phoenix Slides pour traiter les archives comme des répertoires.

## 1. Abstraction des Chemins (Virtual Paths)
Actuellement, toute l'application (du scanner au cache d'images) repose sur des chemins de fichiers réels (chemins POSIX ou `NSURL`).
*   **Stratégie :** Créer un format de chemin virtuel. Par exemple, `/chemin/vers/fichier.cbz::/dossier_interne/image.jpg`.
*   **Impacts et Angles Morts :**
    *   Toutes les fonctions système (comme `NSFileManager`, `CGImageSource`) échoueront sur ces chemins.
    *   Il faudra créer une classe utilitaire (ex: `ArchiveManager`) pour faire l'interface : `if ([path containsString:@"::"]) { ... }`.
    *   **Action sur les fichiers (Corbeille/Déplacement) :** Si l'utilisateur tente de supprimer (Cmd+Backspace) une image affichée qui est dans une archive, l'application risque de planter ou de supprimer l'archive entière.
    *   *Solution :* Bloquer les opérations de déplacement/suppression et l'édition EXIF pour toute image ayant un chemin virtuel.

## 2. Intégration dans `FastScanner` (Découverte)
Le scanner récursif doit identifier les archives et lire leur table des matières.
*   **Gestion des archives multi-parties (Split archives) :**
    *   *Problème :* Les archives type `.rar`, `.r00`, `.r01` ou `.part1.rar`, `.part2.rar`. Si le scanner parse chaque partie, on aura des doublons et des plantages.
    *   *Solution :* Le scanner doit identifier et ignorer les fichiers qui sont des "suites" d'archives, et ne parser que le fichier maître.
*   **Archives corrompues :**
    *   *Problème :* `XADMaster` peut crasher ou bloquer indéfiniment en tentant de lire l'index d'une archive vérolée.
    *   *Solution :* Envelopper les appels `XADMaster` dans des blocs `@try/@catch` d'Objective-C et implémenter un timeout pour ne pas figer l'interface.
*   **Archives protégées par mot de passe :**
    *   *Problème :* Demander un mot de passe figerait le scanner en arrière-plan et polluerait l'expérience utilisateur.
    *   *Solution :* `XADMaster` possède une méthode pour vérifier si une archive est chiffrée. Si c'est le cas, on la saute silencieusement.
*   **Archives imbriquées :**
    *   *Problème :* Un zip dans un zip dans un rar.
    *   *Solution :* Limiter la profondeur d'exploration des archives à 1 pour garantir la rapidité.
*   **Les empilements réseaux et virtuels (Samba + EncFS + Zip) :**
    *   *Problème :* Cas extrême : l'archive se trouve sur un montage distant Samba, au sein d'un répertoire déchiffré à la volée par EncFS (FUSE), le tout encapsulant le zip final. Cet empilement (Réseau -> Chiffrement FUSE -> Archive) génère une latence énorme à chaque opération de recherche (seek) dans le fichier.
    *   *Solution :* L'approche de l'extraction à la volée en mémoire est impérative ici pour éviter les écritures temporaires sur le disque local ou distant. Il faudra s'assurer que `XADMaster` ne fait pas de sauts (seeks) superflus pour parser l'index. La latence réseau/FUSE pour extraire une image sera acceptée telle quelle (c'est le prix de la sécurité et de la transparence), sans tentative de mise en cache sur disque. L'implémentation devra être testée spécifiquement sur ce type de montage pour garantir sa stabilité.

## 3. Le Moteur de Rendu et le Cache (`DYImageCache`)
C'est ici que l'image est extraite en mémoire (`NSData`) pour être affichée.
*   **Slideshow Multi-images (Mosaïque) et Concurrence :**
    *   *Problème :* L'application affiche 8 images en même temps. `DYImageCache` utilise plusieurs threads pour charger les images. Si les 8 threads demandent à `XADMaster` d'extraire des images de *la même* archive en parallèle, cela va causer un goulot d'étranglement ou un plantage (si `XADArchive` n'est pas thread-safe).
    *   *Solution :* Instaurer un système de verrou (Lock) par fichier d'archive, garantissant qu'une seule extraction a lieu à la fois par archive.
*   **Le Mode "Solid Archives" (Très critique) :**
    *   *Problème :* Le format `.7z` et certains `.rar` utilisent une compression "solide". Cela signifie que pour extraire l'image numéro 50, l'algorithme doit décompresser de manière séquentielle les 49 images précédentes. 
    *   *Le Mode Random (Aléatoire) :* Si l'utilisateur est en mode Aléatoire et saute de l'image 10 à 200, puis à 50 dans une archive solide, le CPU va tourner à 100% et l'application va figer.
    *   *Solution :* **Les archives solides ne seront pas supportées et seront délibérément ignorées.** Par souci de simplicité et de sécurité, il ne faut faire **aucune extraction temporaire sur le disque** (pas de dossier `/tmp/`). L'application doit parser l'index de l'archive ; si elle détecte un bloc "solide", le scanner l'abandonnera et documentera que ce format (rare pour des images) n'est pas pris en charge en lecture transparente. Seules les archives à accès aléatoire classique (ZIP, RAR non-solide) seront lues directement en mémoire.

## 4. Effets de bord sur le Slideshow (Random, Navigation)
Puisque le Slideshow se base sur un tableau (`NSArray`) contenant des chaînes de caractères (les chemins de fichiers), l'intégration est étonnamment compatible avec le code existant.
*   **Mode Random inter-répertoires :** Le mélange entre des images de zips et des images standard ne posera aucun souci. Le tableau `filenames` contiendra simplement un mix de chemins normaux et de chemins virtuels.
*   **Tri (Sorting) :** 
    *   *Problème :* Le tri par date EXIF nécessite d'ouvrir le fichier pour lire les métadonnées. L'extraction de 1000 images d'un zip juste pour lire leur date EXIF va détruire les performances.
    *   *Solution :* Fallback (repli) : si l'utilisateur demande un tri par date sur une archive, on utilise par défaut le tri alphabétique, ou la date de modification du fichier de l'archive elle-même.
*   **Surveillance système (`DYFileWatcher`) :**
    *   Les évènements (FSEvents) de macOS ne voient pas à l'intérieur des archives. Si on ajoute une image dans un zip ouvert, l'app ne s'actualisera pas en temps réel. C'est une limitation acceptable, mais le watcher devra se contenter de surveiller le dossier parent.

## Résumé du plan de développement
1. **Infrastructure (Cœur) :**
   - Importer `XADMaster.framework`.
   - Créer le format de chemin virtuel.
   - Adapter `DYImageCache` pour qu'il sache retourner une image depuis un chemin virtuel.
2. **Scanner :**
   - Modifier `FastScanner` pour intercepter les fichiers cibles et lister leur contenu.
   - Gérer les exceptions (mots de passe, corruption, multi-parties).
3. **Optimisation et Cas Extrêmes :**
   - Identifier et rejeter les archives "solides" (aucun cache sur disque autorisé).
   - Valider la fluidité (ou au moins la stabilité) des lectures à travers les couches FUSE/Samba/EncFS.
   - Protéger les extractions multi-threads (Lock par archive).
4. **UI et Sécurité :**
   - Désactiver la fonction corbeille pour les sous-fichiers.
   - S'assurer que le tri ne bloque pas l'application.
