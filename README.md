# AgriConnect

AgriConnect est une plateforme de consignation agricole. Les fournisseurs
ajoutent des lots, l'équipe valide les déclarations et publie les annonces,
puis les acheteurs demandent un devis par messagerie. L'équipe émet le devis,
traite les paiements manuellement et un livreur assure la livraison. L'acheteur
et le fournisseur ne sont jamais mis en contact direct.

## Stack

- Flutter + Dart
- GetX pour l'état, l'injection et le routage
- Dio pour HTTP
- flutter_secure_storage + shared_preferences
- socket_io_client pour le temps réel
- gen-l10n pour les textes
- aucune dépendance Riverpod / GoRouter / génération de code

## Prérequis

- Flutter 3.12+ ou version compatible
- un backend AgriConnect fonctionnel
- un émulateur Android ou un appareil sur le même réseau LAN que le backend

## Configuration

Créez un fichier `env/dev.json` à partir de `env/dev.example.json` puis adaptez
les URLs à votre environnement. Les fichiers JSON de `env/` sont ignorés par git.

Pour un émulateur Android, l'exemple utilise `10.0.2.2`. Sur un appareil réel,
remplacez l'hôte par l'adresse IP LAN du PC qui exécute le backend, par exemple
`http://<IP-LAN>:4000/api/v2` pour l'API et `http://<IP-LAN>:4000` pour le
socket.

Pour la release, utilisez `env/prod.example.json` comme base de `env/prod.json` en
remplaçant l'URL par un endpoint HTTPS et en gardant la clé de signature à
l'extérieur du dépôt.

## Démarrage local

Depuis le dépôt backend :

```sh
npm run dev
npm run seed:demo
```

Depuis ce dépôt frontend :

```sh
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

## Vérifications avant validation

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=env/prod.json
```

## Documentation

- [Architecture](./docs/ARCHITECTURE.md)
- [Réalité de l'API](./docs/API_REALITY.md)
- [Conception de l'agent IA](./docs/AI_AGENT_DESIGN.md)
- [Comptes de démonstration](./docs/DEMO_ACCOUNTS.md)
- [Suivi de migration](./docs/MIGRATION_STATUS.md)
- [Checklist E2E](./docs/E2E_CHECKLIST.md)
