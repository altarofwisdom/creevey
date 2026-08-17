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
