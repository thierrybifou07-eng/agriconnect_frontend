# Architecture AgriConnect

## Vue d'ensemble

Le frontend est structuré par feature, avec une séparation claire entre la couche
modèle de domaine, les repositories, les clients API et la UI GetX.

```text
lib/
├─ app/                    # App, bindings, routes, thèmes
├─ core/
│  ├─ config/             # variables d'environnement
│  ├─ network/            # Dio, retry, erreurs, pagination
│  ├─ storage/            # stockage persistant
│  ├─ realtime/           # SocketService / transports
│  ├─ localization/      # ARB + générés
│  └─ ui/                 # gestion d'état UI / notifiers
├─ features/<feature>/
│  ├─ data/               # DTO, API, repository impl
│  ├─ domain/             # entités, interfaces de repository
│  └─ presentation/      # controllers, bindings, pages, widgets
├─ shared/                # widgets visuels sans logique métier
└─ main.dart
```

## Flux d'authentification et de refresh

1. Un utilisateur se connecte via `AuthController`.
2. Le `ApiClient` stocke les jetons dans `SecureTokenStorage`.
3. `ApiInterceptor` ajoute le `Authorization` sur chaque requête.
4. Si le backend répond `401`, le client tente un refresh unique.
5. En cas de succès, la requête originale est relancée ; en cas d'échec, la
   session est fermée proprement et l'utilisateur est redirigé vers le login.

## Flux temps réel

- `SocketService` gère la connexion avec `socket_io_client`.
- Les événements `session_revoked`, `connect`, `disconnect` et les notifications
  sont relayés par `SessionEvents`/`ApiFailureEvents`.
- Les écrans lisent `SocketService.connected` pour afficher le bandeau
  « Hors ligne / Reconnexion… » et pour désactiver les actions dépendantes du
  service en temps réel.

## Flux IA

- Les moteurs IA sont surveillés par les modules de `features/ai`.
- Les suggestions passent par des API dédiées et sont validées avant
  approbation.
- Les modifications sont appliquées dans le flux métier normal (chat, listing,
  moderation) sans contourner les règles de validation.

## Règles de conception conservées

- Les écrans sont pilotés par un `GetxController` unique.
- Les dépendances sont injectées via les `Binding`s.
- Les repositories lèvent `ApiFailure` et ne propagent jamais des exceptions
  brutes jusqu'à l'UI.
- Les contrôleurs remettent l'état dans `UiState` et n'appellent pas
  `setState` pour la logique métier.
- Les services permanents sont enregistrés uniquement dans `AppBinding`.
