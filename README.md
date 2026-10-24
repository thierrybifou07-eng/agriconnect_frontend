# AgriConnect

AgriConnect est une plateforme de consignation agricole. Les fournisseurs
déclarent des lots, l'équipe les valide et publie des annonces, puis les
acheteurs demandent un devis par messagerie. L'équipe émet le devis et gère
les paiements; un livreur assure la livraison. L'acheteur et le fournisseur
ne sont jamais mis en contact direct.

## Prérequis

- Flutter et Dart (Flutter 3.47 ou ultérieur recommandé)
- Le backend AgriConnect lancé localement pour les parcours connectés
- Un émulateur Android, ou un appareil sur le même réseau local que le backend

## Démarrage

Copiez `env/dev.example.json` vers `env/dev.json`, puis adaptez les URL selon
votre environnement. Le fichier `env/dev.json` est ignoré par Git.

Sur émulateur Android, l'exemple utilise `10.0.2.2`. Sur un appareil réel,
remplacez l'hôte par l'adresse IP LAN du PC qui exécute le backend, par exemple
`http://<IP-LAN>:4000/api/v2` pour l'API et `http://<IP-LAN>:4000` pour le
socket.

Depuis le dépôt backend, démarrez le serveur et chargez les comptes de
démonstration en développement :

```sh
npm run dev
npm run seed:demo
```

Depuis ce dépôt frontend :

```sh
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

L'application affiche actuellement un écran provisoire pendant la migration.

## Documentation

Consultez [`docs/`](./docs/) pour la [réalité de l'API](./docs/API_REALITY.md),
la [conception de l'agent IA](./docs/AI_AGENT_DESIGN.md), les
[comptes de démonstration](./docs/DEMO_ACCOUNTS.md) et le
[suivi de migration](./docs/MIGRATION_STATUS.md).
