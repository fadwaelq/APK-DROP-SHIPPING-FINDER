# Guide d'Internationalisation (i18n) - Dropshipping Finder

Ce projet utilise le système de localisation standard de Flutter (`flutter_localizations` et `intl`).

## Structure des fichiers
- `lib/l10n/` : Contient les fichiers `.arb` pour chaque langue.
  - `app_fr.arb` (Français)
  - `app_en.arb` (Anglais)
  - `app_ar.arb` (Arabe - RTL)
  - `app_es.arb` (Espagnol)
  - `app_de.arb` (Allemand)
- `l10n.yaml` : Fichier de configuration pour la génération automatique.

## Comment ajouter une nouvelle traduction
1. Ouvrez `lib/l10n/app_fr.arb`.
2. Ajoutez une nouvelle clé :
   ```json
   "welcome_message": "Bienvenue dans l'application",
   "@welcome_message": {
     "description": "Message de bienvenue affiché sur l'écran d'accueil"
   }
   ```
3. Répétez l'opération dans les autres fichiers `.arb` (`app_en.arb`, etc.).
4. Enregistrez les fichiers. Les classes de localisation seront automatiquement générées au prochain démarrage ou via la commande :
   ```bash
   flutter gen-l10n
   ```

## Comment utiliser les traductions dans le code
Importez le fichier généré :
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

Utilisez ensuite `AppLocalizations.of(context)` :
```dart
Text(AppLocalizations.of(context)!.welcome_message)
```

## Cas avec paramètres
Si vous avez besoin d'insérer une variable :
- Dans le fichier `.arb` :
  ```json
  "hello_user": "Bonjour {name}",
  "@hello_user": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
  ```
- Dans le code :
  ```dart
  Text(AppLocalizations.of(context)!.hello_user("Jean"))
  ```

## Support de l'Arabe (RTL)
L'application supporte automatiquement la direction de droite à gauche (RTL) pour l'arabe. Flutter ajuste l'alignement des textes et la direction des icônes de navigation nativement.
