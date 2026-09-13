# Plan d'implémentation : Remplacement du système de groupes par les Tags macOS

## 1. Objectifs
- Remplacer le système interne de "groupes" (touches F2 à F12) par les **tags natifs macOS**.
- Assurer des performances maximales sur des lecteurs réseau (SAMBA/ENCFS) contenant jusqu'à 200 000 images, sans utiliser Spotlight.
- Gérer la sélection multiple dans la vue navigateur.

## 2. Raccourcis Clavier et Logique de filtrage

Tous ces raccourcis s'appliquent dans le contexte du navigateur (et non en vue image unique) et sur l'ensemble des fichiers actuellement sélectionnés.

| Touches | Action |
| :--- | :--- |
| **F2 à F12** | Applique de manière absolue le tag correspondant ("F2", "F3", ..., "F12") à la sélection. |
| **F1** | Supprime tous les tags "F2" à "F12" de la sélection. |
| **Shift + F2 à F12** | Bascule (Toggle) l'état du tag sur la sélection : ajoute le tag s'il est absent, le retire s'il est présent. |
| **Alt + F2 à F12** | Filtre le navigateur pour n'afficher *que* les images possédant le tag correspondant. |
| **Alt + F1** | Annule le filtre (affiche toutes les images). |

## 3. Architecture de Lecture Asynchrone (Le "Tag Scanner")

Pour scanner 200 000 images sur un lecteur réseau sans geler l'interface ni retarder l'affichage des miniatures, la lecture des tags sera totalement découplée du scan de l'arborescence.

### A. API de lecture
- **Interdiction** d'utiliser `NSURLTagNamesKey` ou Spotlight pour la lecture de masse.
- **Obligation** d'utiliser l'appel C bas niveau `getxattr(path, "com.apple.metadata:_kMDItemUserTags", ...)` qui est 5 fois plus rapide et ne dépend pas d'une base de données locale.

### B. Le Pool de Concurrence
- Création d'une `NSOperationQueue` dédiée (`tagScanQueue`).
- `maxConcurrentOperationCount` défini sur une valeur agressive (ex: `16` ou `32`) pour saturer la bande passante Gigabit en multipliant les requêtes SMB sans surcharger le CPU.
- Qualité de service (QoS) configurée sur `NSQualityOfServiceUtility`.

### C. Le Pipeline du Scan
1. La boucle principale (`NSDirectoryEnumerator` dans `CreeveyController.m`) découvre un fichier.
2. Le chemin du fichier est envoyé immédiatement au `tagScanQueue` en tâche de fond.
3. À la fin complète du scan (qui peut prendre 1 à 2 minutes pour 200 000 fichiers), l'UI reçoit le tableau de résultats et affiche le navigateur.
4. À ce moment-là :
   - Les tags qui ont déjà été traités par les workers asynchrones pendant le scan s'affichent instantanément avec l'image.
   - Si les workers asynchrones ont pris plus de temps que le scan lui-même (à cause de l'I/O réseau), les tags manquants apparaîtront progressivement sur les vignettes affichées au fur et à mesure que la file d'attente se vide.

## 4. Architecture d'Écriture des Tags

Contrairement à la lecture de masse, l'écriture de tags se fait lors d'une action utilisateur (appui sur F2) sur une sélection finie d'images (de 1 à quelques milliers max).
- L'écriture n'étant pas un goulot d'étranglement continu, nous pouvons utiliser l'API Apple standard : `[url setResourceValue:tags forKey:NSURLTagNamesKey error:&error]` ou continuer avec `setxattr`.
- L'utilisation de l'API standard pour l'écriture garantit que le système (le Finder) est correctement notifié du changement (ce que `setxattr` seul pourrait ne pas faire immédiatement).

## 5. Étapes de développement (Next Steps)

1. **Parser de BPLIST** : `getxattr` renvoie un bplist (Binary Plist). Il faut écrire la fonction C/Objective-C qui décode ce bplist pour en extraire le tableau de strings (les noms des tags).
2. **Création du `TagManager`** : Une classe singleton responsable de la `NSOperationQueue` et du décodage.
3. **Modification du Scanner** : Injection des appels au `TagManager` dans la boucle de `CreeveyController.m` (lignes ~1600).
4. **Câblage des événements UI** : Interception des touches F1-F12 avec leurs modificateurs (Shift/Alt) dans le contrôleur de la vue navigateur.
5. **Implémentation du Filtre Visuel** : Application du prédicat de filtrage (Alt+F2..F12) sur la source de données du navigateur.
