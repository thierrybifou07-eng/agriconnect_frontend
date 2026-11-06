# AgriConnect — application mobile (Flutter)

Application de la plateforme d'intermédiation agricole AgriConnect (fournisseurs, acheteurs, livreurs,
équipe AgriConnect). Elle se connecte au backend `agriconnect-backend` (API REST `/api/v2` + Socket.io).

## Lancer en développement

1. Démarrer le backend (`npm run dev`, port 4000) avec ses données de démonstration (`npm run seed:demo`).
2. Copier un fichier d'environnement et l'adapter :
   - émulateur Android : `env/dev.emulator.json.example` → `env/dev.emulator.json`
     (`http://10.0.2.2:4000/api/v2`, l'adresse du PC vue depuis l'émulateur) ;
   - téléphone réel sur le même Wi-Fi : `env/dev.device.json.example` → `env/dev.device.json`,
     avec l'adresse IP locale du PC.
3. `flutter run --dart-define-from-file=env/dev.emulator.json`

Sans fichier, l'application vise `http://10.0.2.2:4000/api/v2`. En debug, une URL qui ne se termine pas par
`/api/v2` arrête l'application au démarrage avec un message explicite.

## Documentation

- `docs/API_CONTRACT.md` : contrat réseau réel du backend (prioritaire sur la spec OpenAPI pour les réponses).
- `docs/INTEGRATION_PLAN.md` : avancement de la connexion au backend, commit par commit.
- `docs/PROJECT_STATUS.md` : état du projet, règles métier et règles Git.
- `.github/copilot-instructions.md` : règles pour les agents de code.

## Vérifications avant chaque commit

```bash
dart analyze
flutter test
git diff --check
```
