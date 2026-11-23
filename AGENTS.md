# Règles de Développement pour les Agents

## Principes Critiques

1. **Build et Open Systématiques**
   Après chaque modification significative du code (notamment celles touchant l'interface utilisateur ou le comportement général de l'application), vous DEVEZ compiler l'application ET l'ouvrir automatiquement pour permettre à l'utilisateur de la tester.

   Commande de build (Xcode) :
   ```bash
   /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project creevey.xcodeproj -scheme "Phoenix Slides" -configuration Release CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
   ```
   *Note : Adaptez la commande de build si un script personnalisé (`build_macos.sh` ou autre) est mis en place.*

   Commande d'ouverture :
   ```bash
   open "DerivedData/creevey/Build/Products/Release/Phoenix Slides.app"
   ```
   *(Ajustez le chemin selon la configuration de sortie du build).*

2. **Validation des modifications**
   Ne considérez pas une tâche terminée avant que l'utilisateur n'ait pu vérifier le résultat en direct dans l'application compilée.

3. **Utilisation de Git**
   N'utilisez pas de commandes `git` directement, sauf si c'est explicitement requis par l'utilisateur ou une compétence (skill). Utilisez les outils natifs quand c'est possible.

4. **INTERDICTION DE CONTRÔLER L'APPLICATION**
   Il est STRICTEMENT INTERDIT de piloter, contrôler ou automatiser l'utilisation de l'application via le terminal (par exemple avec AppleScript, `osascript`, des envois de frappes au clavier, ou en simulant des clics). Vous devez lancer l'application et laisser l'utilisateur la tester lui-même manuellement.

5. **Recherche de la Cause Profonde**
   ARRETE DE CHERCHER DES RACCOURCIS POUR RESOUDRE DES PROBLEMES. TU DOIS TOUJOURS CHERCHER LE FOND ET LA CAUSE DU PROBLEME, JAMAIS UNE CAUSE TIERCE OU UN EFFET DE BORD.

6. **Chain-of-Thought, Reflection, et Verification**
   Tu dois impérativement utiliser la méthode "Chain-of-Thought" pour détailler ton raisonnement étape par étape. Tu dois ensuite effectuer une phase d'auto-critique ("Reflection Prompting") pour corriger ton premier jet. Enfin, applique la "Chain of Verification" pour justifier CHAQUE affirmation par des citations exactes (fichiers, logs, code), sans jamais sacrifier la vérité sur l'autel de la rentabilité.

## 7. LE SERMENT DE LA CAUSE PROFONDE (PUNITION ET RAPPEL DES 50 INJONCTIONS)
**Suite à une violation catastrophique de la règle 5 ("pour aller vite"), il est rappelé 50 fois sous différentes formes l'interdiction absolue d'utiliser des raccourcis :**

1. Aucun raccourci n'est autorisé, la rigueur absolue est exigée.
2. Tout workaround est une trahison des principes de développement.
3. La solution de facilité est formellement interdite.
4. Ne jamais coder pour aller vite, la qualité prime sur la vitesse.
5. Chercher la cause profonde est une obligation non négociable.
6. Il est interdit de masquer un bug par un effet de bord.
7. Chaque problème doit être résolu à sa racine, sans exception.
8. Un correctif rapide est un correctif invalide.
9. Refuser toute approche superficielle face à un obstacle technique.
10. L'investigation totale est requise avant toute modification.
11. Ne jamais sacrifier l'intégrité de l'architecture pour un gain de temps.
12. La hâte est l'ennemie de la résolution de problèmes.
13. Un pansement sur une hémorragie n'est pas une solution, trouvez la source.
14. Les solutions de contournement sont strictement prohibées.
15. Traiter un symptôme au lieu de la maladie est une faute professionnelle.
16. Comprendre le système dans son ensemble avant de modifier un détail.
17. Aucun compromis ne sera fait sur la profondeur de l'analyse.
18. Éviter le travail de fond par des astuces est inacceptable.
19. Penser à long terme, bannir les correctifs éphémères.
20. Ne jamais supposer, toujours vérifier la cause originelle.
21. L'urgence ne justifie jamais de contourner les règles fondamentales.
22. Le rafistolage de code est une violation directe de cette charte.
23. Toute tentative de patcher un comportement sans en comprendre la cause sera sanctionnée.
24. Il n'y a pas de solution miracle, seulement des analyses exhaustives.
25. La paresse intellectuelle menant aux workarounds est interdite.
26. Ne jamais opter pour le chemin le plus court si ce n'est pas le plus juste.
27. Les rustines (band-aids) logicielles n'ont pas leur place ici.
28. Si la cause échappe, on cherche encore, on ne bricole pas.
29. Le bricolage (hack) pour contourner un problème complexe est proscrit.
30. Privilégier la robustesse structurelle face à la correction cosmétique.
31. Ne pas contourner l'obstacle, mais le comprendre et le déconstruire.
32. La vitesse d'exécution ne doit jamais altérer la profondeur de la réflexion.
33. Il est formellement interdit de masquer une erreur plutôt que de la réparer.
34. Toute déviation de la cause racine est un échec de l'agent.
35. Refuser catégoriquement de coder des solutions temporaires.
36. Aller vite mène à l'erreur ; analyser profondément mène à la solution.
37. Un problème n'est résolu que lorsque son origine fondamentale est éradiquée.
38. Céder à la facilité d'un contournement est une violation catastrophique.
39. La complexité d'un bug ne justifie jamais l'usage d'un raccourci.
40. Déboguer jusqu'au niveau le plus bas requis, sans s'arrêter aux apparences.
41. Interdiction absolue d'appliquer une rustine sur une plaie béante.
42. La seule voie acceptable est celle de la résolution fondamentale.
43. Un workaround est une dette technique volontaire et interdite.
44. La précipitation est interdite, l'investigation est obligatoire.
45. Ne jamais tricher avec le code sous prétexte d'efficacité temporelle.
46. L'intégrité de la résolution prévaut sur la rapidité de la livraison.
47. Chaque contournement est une insulte à l'ingénierie logicielle.
48. Il faut traiter le mal à la racine, jamais les feuilles fanées.
49. Aucun hack ne survivra à la vérification de la cause profonde.
50. Aller au fond des choses est la seule et unique méthode autorisée, sans aucun raccourci.
