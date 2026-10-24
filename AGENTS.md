# AGENTS.md — AgriConnect (frontend Flutter)

> Placer ce fichier **à la racine du dépôt frontend**. OpenCode le lit à chaque session.
> Sources de vérité : `docs/API_REALITY.md` (réponses réelles de l'API), `docs/api/openapi.yaml` (requêtes),
> `docs/AI_AGENT_DESIGN.md` (Agent IA). **En cas de conflit, `API_REALITY.md` gagne sur `openapi.yaml`.**

## Produit en une minute
AgriConnect = plateforme de **consignation agricole**. Le fournisseur (SUPPLIER) déclare des **lots** ; l'équipe
(AGENT/ADMIN/ROOT) les valide et publie des **annonces** ; l'acheteur (BUYER) ne voit que les annonces et
**demande un devis** par messagerie ; l'équipe émet un **devis** (`QUOTED`) que l'acheteur confirme ; les paiements
sont saisis à la main par le staff ; un livreur (DRIVER, agence de transport) livre. Acheteur et fournisseur ne se
voient jamais. Il n'y a **ni panier, ni checkout, ni commande créée par l'acheteur**.

## Rôles (`user.role.code`) → zone de l'app
`SUPPLIER`→`/supplier` · `BUYER`→`/buyer` · `DRIVER`→`/driver` · `AGENT`→`/staff` (onglets selon `user.agent.capabilities`)
· `ADMIN` et `ROOT`→`/admin` (ROOT ajoute l'édition des réglages et la création d'ADMIN).

## Stack imposée
Flutter · **GetX** (`get`) pour état, DI, routage, dialogues · **Dio** pour HTTP · `flutter_secure_storage` (jetons) ·
`shared_preferences` (préférences) · `socket_io_client` · gen-l10n (ARB) pour les textes · **aucun** `flutter_riverpod`,
**aucun** `go_router`, **aucune** génération de code (`build_runner`, `freezed`, `json_serializable` interdits).
Ajoute les dépendances avec `flutter pub add <paquet>` (sans numéro de version).

## Arborescence cible
```
lib/
  main.dart
  app/            app.dart · app_binding.dart · routes/{app_routes,app_pages}.dart · routes/middlewares/ · theme/
  core/           config/app_env.dart · network/{api_client,api_interceptors,api_failure,paginated}.dart
                  storage/{token_storage,prefs_storage}.dart · realtime/socket_service.dart · media/media_url.dart
                  ui/{app_notifier,ui_state,state_views}.dart · utils/{money,dates}.dart · localization/
  features/<f>/   data/{dto/,<f>_api.dart,<f>_repository_impl.dart}
                  domain/{entities,<f>_repository.dart}
                  presentation/{controllers/,bindings/,pages/,widgets/}
  shared/widgets/ composants purement visuels (sans logique réseau)
lib_legacy/ test_legacy/     ← ancien code, EXCLU de l'analyse, supprimé en P16. Ne jamais l'importer.
```

## Règles GetX (non négociables)
1. Un écran = un `GetxController` (dans `presentation/controllers/`) + un `Binding` (`presentation/bindings/`) + une page.
   Les pages étendent `GetView<XController>` ou lisent le contrôleur fourni ; **`Get.find` est interdit dans `domain/` et `data/`**.
2. **Injection par constructeur.** Les dépendances sont enregistrées dans les `Binding`s (`Get.lazyPut`) ; services
   permanents (`Get.put(..., permanent: true)`) uniquement dans `AppBinding` : `PrefsStorage`, `TokenStorage`,
   `ApiClient`, `AuthController`, `SocketService`, `LocaleController`.
3. État d'écran = `Rx<UiState<T>>` (`idle | loading | success(data) | error(ApiFailure)`) + `Obx`. Pas de `setState` pour de l'état métier.
4. Les repositories **lèvent `ApiFailure`** ; les contrôleurs l'attrapent et le placent dans l'état. Jamais d'exception brute vers l'UI.
5. Navigation : `Get.toNamed`, `Get.offAllNamed`, `Get.back` ; noms de routes dans `AppRoutes` (constantes). Garde d'accès par
   `GetMiddleware` (`AuthMiddleware`, `RoleMiddleware`, `CapabilityMiddleware`). Messages/dialogues via `AppNotifier` uniquement.
6. Fermer ce qui doit l'être dans `onClose()` (`StreamSubscription`, `TextEditingController`, `ScrollController`, `Worker`).
7. Un contrôleur ne dépasse pas ≈ 300 lignes ; une page ≈ 400 ; sinon on extrait des widgets.

## Règles données et API
- **Ne jamais inventer un champ, un statut ou une route.** S'il n'est pas dans `API_REALITY.md`, demander ou vérifier le backend.
- IDs = `int`. Montants/quantités = `double` (jamais `int`). Devise XAF ; format via `core/utils/money.dart`.
- Dates : ISO 8601 UTC → `DateTime` ; affichage local via `core/utils/dates.dart`.
- URL de médias : l'API renvoie des chemins relatifs → toujours passer par `MediaUrl.resolve(path)`.
- Erreurs : `{error, code?, details?[]}` → `ApiFailure(status, code, message, fieldErrors)`. Afficher d'abord une phrase
  localisée par `code` connu ; sinon `message` du serveur. 401 → refresh unique puis déconnexion ; 403
  `PROFILE_NOT_VERIFIED` → bannière + chemin vers la vérification ; 409 `INVALID_STATE_TRANSITION` → recharger l'objet.
- Pagination : `{items,page,limit,total}` ; `limit ≤ 100`. Listes longues = défilement infini via `Paginated<T>`.
- Écritures idempotentes (`POST /staff/orders/:id/payments`) : un `Idempotency-Key` (uuid v4) **par tentative utilisateur**, réutilisé en cas de relance.
- Uploads : multipart, noms de champs exacts (`avatar`, `file`+`type`, `images`) ; vérifier taille/format **avant** envoi.
- Aucune donnée fictive, aucune `Demo*`/`Fake*` dans `lib/`. Les faux repositories n'existent que dans `test/`.
- Secrets : aucune URL/clé en dur ; `--dart-define-from-file=env/dev.json` (`API_BASE_URL`, `SOCKET_URL`). `env/*.json` ignorés par git, `env/dev.example.json` versionné.

## Textes et accessibilité
Tout texte visible passe par gen-l10n : ajouter la clé dans **tous** les `.arb` existants (FR référence + EN). Cibles tactiles ≥ 48 dp.
Utilisateurs peu technophiles : phrases courtes, un seul appel à l'action principal par écran, états vides et d'erreur explicites avec bouton « Réessayer ».

## Tests (obligatoires à chaque phase)
- Harnais : `test/support/get_test_harness.dart` (`Get.testMode = true`, `Get.reset()` dans `setUp`/`tearDown`).
- Pour chaque module : (a) **tests de contrat** DTO sur des fixtures JSON `test/fixtures/api/*.json` fidèles à `API_REALITY.md` ;
  (b) tests de contrôleur avec un faux repository (état loading/success/error, cas d'erreur API clés) ; (c) 1–3 tests de widget sur l'écran principal.
- `dart format .` · `flutter analyze` (**0 issue**) · `flutter test` (**tout vert**) avant tout commit.

## Mode de travail
- **Une phase = un commit**, message Conventional Commits (`feat(auth): …`) + **description détaillée** (liste des fichiers, décisions, écarts constatés). Ne jamais `git push`.
- Rester dans le périmètre de la phase. Pas de refactor « au passage ». Pas de nouvelle dépendance non listée dans le prompt sans le dire.
- Avant de coder : lire le prompt, `API_REALITY.md`, puis les fichiers de `lib_legacy/` indiqués pour **porter l'UI** (conserver design, textes, thème).
- Si un fait de l'API contredit le prompt : **s'arrêter et le signaler** avec la preuve (extrait de code backend, réponse `curl`).
- Après **2 tentatives infructueuses** sur le même problème : arrêter et rapporter (commande, erreur, hypothèses). Ne pas contourner par un mock.
- Backend local pour vérifier : `http://10.0.2.2:4000/api/v2` (émulateur Android), `npm run seed:demo` côté backend.

## Comptes de démonstration (créés par `npm run seed:demo`, dev uniquement)
Voir `docs/DEMO_ACCOUNTS.md` (généré en P00 côté backend et copié ici) : admin, agent complet, agent support seul, agent IA,
livreur, fournisseur vérifié, fournisseur non vérifié, acheteur vérifié, acheteur non vérifié.
