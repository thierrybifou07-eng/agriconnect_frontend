# Phase 2 — Authentification : spécification détaillée

Rédigée le 7 novembre 2026 à partir du code de `feature/api` (template), du backend `feature/mobile-contract`
(`src/controllers/auth.controller.js`, `src/validators/auth.validator.js`, `src/utils/userApi.js`,
`src/controllers/user.controller.js`, `src/controllers/legal.controller.js`) et de la branche GetX
`origin/feature/api-connection-first`.

À lire avec : `docs/API_CONTRACT.md` § 2, 3, 4.1 et 6 ; `docs/INTEGRATION_PLAN.md` section 3 (méthode).

> **Changement de découpage par rapport aux fiches d'origine.** C06 supprime le dépôt de démonstration. Or
> l'inscription du template (nom complet, e-mail, mot de passe) ne peut pas produire une requête valide pour le
> backend (prénom, nom, téléphone et `acceptTerms` obligatoires). Pour que chaque commit reste vert et honnête,
> C06 **retire** l'inscription (page, contrôleur, route, lien, tests) et C07 la **recrée** au format du backend.
> De même, le panneau des comptes de démonstration et `expectedRole` disparaissent dès C06, puisqu'ils dépendent
> de `DemoAuthRepository`.

---

## Ce que le backend fait réellement (vérifié dans le code)

| Appel | Réponse | Erreurs |
|---|---|---|
| `POST /auth/login {email,password}` (public) | `200 {user, accessToken, refreshToken}` où `user` = `userToApi` **+ `agent`**, **sans `media` ni `profile`** | 401 `{error:'Identifiants invalides'}` **sans code** ; 403 `{code:'ACCOUNT_SUSPENDED'}` ; 429 `{code:'RATE_LIMITED'}` ; 400 validation |
| `POST /auth/register` (public) | `201 {user, accessToken, refreshToken}` où `user` = `userToApi` seul (**ni `agent`, ni `media`, ni `profile`**) | 409 **sans code**, message « Un compte existe déjà avec cet email » ou « … avec ce numéro » ; 400 validation (`details[]`) ou `REFERRAL_CODE_UNKNOWN` ; 429 `RATE_LIMITED` |
| `GET /auth/me` (protégé) | `userToApi` + `media[]` + `profile` + `agent` | 401 (le refresh est géré par l'intercepteur) ; 403 `ACCOUNT_SUSPENDED` |
| `POST /auth/logout {refreshToken}` (public) | `204`, idempotent | 400 si `refreshToken` absent |
| `POST /auth/forgot-password {email}` (public) | `200 {message}` identique que le compte existe ou non | 429 `RATE_LIMITED` |
| `GET /legal/{code}?lang=fr\|en` (public) | `{code, version, locale, title, content, publishedAt}` ; repli sur `fr` | 404 |

- `userToApi` : `{id, firstname, lastname, email, phone, location, role:{code,label}, userStatus:{code,label},
  emailVerified, profileVerificationStatus, referralCode, createdAt}`.
- `agent` : `{id, displayName, kind:'HUMAN'|'AI', autonomy, capabilities:string[]}` ou `null`. Non nul
  seulement pour un compte `AGENT` qui a une fiche active.
- Documents légaux à accepter à l'inscription : `BUYER` → `CGU` + `BUYER_TERMS` ; `SUPPLIER` → `CGU` +
  `SUPPLIER_CONSIGNMENT_TERMS` (`src/utils/legal.js`). `acceptTerms: true` vaut acceptation de ces documents.
- Comptes de démonstration (`npm run seed:demo`), mot de passe commun `Demo@2026x` :
  `admin@demo.agriconnect.test`, `agent.complet@demo.agriconnect.test`, `agent.support@demo.agriconnect.test`,
  `livreur@demo.agriconnect.test`, `fournisseur.verifie@…`, `fournisseur.nonverifie@…`, `acheteur.verifie@…`,
  `acheteur.nonverifie@…` (tous en `@demo.agriconnect.test`). **Aucun compte ROOT n'est créé par le seed.**

---

## C06 — `feat(auth)!: remote authentication and backend user model`

### Objectif

L'application s'authentifie contre le backend. L'utilisateur, son rôle et ses capacités viennent du serveur.
Les jetons vivent uniquement dans `TokenStorage` (phase 1). La session se restaure au démarrage et se termine
proprement (déconnexion, jeton expiré, compte suspendu, session révoquée). Le temps réel démarre et s'arrête
avec la session.

### Fichiers

| Action | Fichier |
|---|---|
| Réécrit | `lib/features/auth/domain/auth_user.dart` |
| Réécrit | `lib/features/auth/domain/capability.dart` |
| Modifié | `lib/features/auth/domain/user_role.dart` |
| Nouveau | `lib/features/auth/domain/profile_verification_status.dart` |
| Réécrit | `lib/features/auth/domain/auth_repository.dart` |
| Nouveau | `lib/features/auth/data/auth_user_dto.dart` |
| Nouveau | `lib/features/auth/data/remote_auth_repository.dart` |
| Nouveau | `lib/features/auth/data/user_cache.dart` |
| Supprimé | `lib/features/auth/data/demo_auth_repository.dart` |
| Supprimé | `lib/core/storage/session_storage.dart` |
| Réécrit | `lib/features/auth/application/auth_controller.dart`, `auth_state.dart` |
| Modifié | `lib/features/auth/application/login_controller.dart` |
| Supprimés | `lib/features/auth/application/register_controller.dart`, `lib/features/auth/presentation/pages/register_page.dart` (recréés en C07) |
| Modifié | `lib/features/auth/presentation/pages/login_page.dart` |
| Modifié | `lib/features/auth/presentation/widgets/role_profile_page.dart` |
| Modifié | `lib/app/router/redirect_policy.dart`, `lib/app/router/app_router.dart` |
| Modifié | `lib/core/localization/locale_x.dart`, `l10n/app_fr.arb`, `l10n/app_en.arb` (+ fichiers générés) |
| Modifié | `lib/core/errors/failures.dart` (codes `role_mismatch` et `role_not_allowed` retirés) |
| Modifiés | tout fichier qui lit `AuthUser.photoUrl` ou construit un `AuthUser` (voir « Migration des appels ») |
| Nouveau | `test/support/auth_fakes.dart` |
| Nouveaux | `test/features/auth/auth_user_dto_test.dart`, `remote_auth_repository_test.dart`, `auth_controller_test.dart` |
| Migrés | tous les tests qui amorcent une session (environ 25 fichiers, voir « Tests ») |

Sources à porter depuis la branche GetX (lire avec `git show origin/feature/api-connection-first:<chemin>`) :
`lib/features/auth/data/dto/auth_user_dto.dart`, `lib/features/auth/data/auth_api.dart`,
`lib/features/auth/domain/auth_user.dart`, `lib/features/auth/domain/agent_capability.dart`,
`lib/features/auth/domain/profile_verification_status.dart`, `test/fixtures/api/login_agent_with_capabilities.json`,
`test/features/auth/auth_contract_test.dart`, `test/features/auth/auth_user_test.dart`. On en reprend la logique
de lecture, pas l'architecture GetX.

### Domaine

**`UserRole`** (`user_role.dart`)
- Garder l'enum et `routePrefix`, `homePath`, `isStaff`.
- Ajouter `String get code` (`'BUYER'`, `'SUPPLIER'`, `'DRIVER'`, `'AGENT'`, `'ADMIN'`, `'ROOT'`) et
  `static UserRole? fromCode(String? code)` qui renvoie `null` pour un code inconnu.
- `fromName` ne lève plus jamais : `UserRole.values.asNameMap()[name]`, avec les alias v1 `farmer` → supplier
  et `superAdmin` → root, sinon `null`. Le type de retour devient `UserRole?` ; adapter les appelants.
- `onboardingRoles` et `selectableForSignup` restent jusqu'en C07.

**`UserCapability`** (`capability.dart`)
- Les 9 valeurs du backend : `buyerSupport`, `supplierSupport`, `listingManagement`, `orderProcessing`,
  `stockValidation`, `paymentFollowup`, `dispatchCoordination`, `userVerification`, `disputeHandling`.
  Les 4 noms existants sont conservés à l'identique (ils sont utilisés par `RoleSection` et les pages agent).
- `key` et `fromKey` couvrent les 9 codes ; `fromKey` renvoie `null` pour un code inconnu.
- Supprimer l'extension `UserRoleCapabilityX` (le « bundle » de démonstration par rôle).
- `locale_x.dart` : `UserCapabilityLabelX` couvre les 9 valeurs. Ajouter 5 clés ARB FR/EN :
  `capabilitySupplierSupport` (Support fournisseurs / Supplier support), `capabilityListingManagement`
  (Gestion des annonces / Listing management), `capabilityDispatchCoordination` (Coordination des expéditions /
  Dispatch coordination), `capabilityUserVerification` (Vérification des profils / Profile verification),
  `capabilityDisputeHandling` (Litiges et indemnisations / Disputes and compensations).

**`ProfileVerificationStatus`** : `unverified`, `pending`, `verified`, `rejected`, `unknown`, avec
`static parse(Object?)` qui accepte les codes en majuscules et renvoie `unknown` sinon.

**`AuthUser`** (`auth_user.dart`) — immuable, sans `toJson`, sans constructeur par défaut des capacités :

```dart
class AuthUser {
  const AuthUser({
    required this.id,            // int
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.role,          // UserRole
    this.roleLabel,              // libellé serveur, affichage seulement
    this.location,
    this.emailVerified = false,
    this.profileVerificationStatus = ProfileVerificationStatus.unknown,
    this.referralCode,
    this.avatarUrl,              // URL absolue (MediaUrl), média isPrimary de /auth/me
    this.profile,                // AuthProfile? (sealed : SupplierProfile, BuyerProfile, DriverProfile)
    this.agent,                  // AgentInfo? {id, displayName, kind, autonomy, capabilities}
  });

  String get fullName;           // '$firstname $lastname'.trim()
  String get initials;           // comportement actuel conservé
  bool get isStaff;              // role.isStaff
  Set<UserCapability> get capabilities;
  AuthUser copyWith(...);        // utile en C10
}
```

Règle des capacités (`docs/API_CONTRACT.md` § 6) :
- `ADMIN` et `ROOT` : les 9 capacités, même sans fiche agent.
- `AGENT` : celles de `agent.capabilities` reconnues par `fromKey`, ou aucune si `agent` est `null`.
- `BUYER`, `SUPPLIER`, `DRIVER` : aucune.

L'extension `AuthCapabilityGuardX` (`hasCapability`, `requireCapability`…) est conservée telle quelle.

**`AuthRepository`** (`auth_repository.dart`) :

```dart
abstract interface class AuthRepository {
  /// POST /auth/login, enregistre les jetons, puis complète l'utilisateur par GET /auth/me.
  Future<AuthUser> signIn({required String email, required String password});

  /// Restaure la session au démarrage. `null` = aucune session utilisable.
  Future<AuthUser?> restore();

  /// GET /auth/me ; met le cache à jour.
  Future<AuthUser> refreshCurrentUser();

  /// POST /auth/logout (au mieux), puis efface jetons et cache. Ne lève jamais.
  Future<void> signOut();

  /// Efface jetons et cache sans appeler le serveur (session déjà perdue).
  Future<void> clearLocalSession();
}
```

`register`, `forgotPassword` et `legalDocument` sont ajoutés en C07.

### Données

**`AuthUserDto.fromJson(Object? json)`** (`auth_user_dto.dart`)
- Lit la forme `userToApi` (+ `agent`, `media`, `profile` quand ils sont présents). Utilise les helpers de
  `lib/core/network/json.dart`.
- `role` : `fromCode(json['role']['code'])`. Un rôle absent ou inconnu lève une `FormatException`. Jamais de
  rôle par défaut : un compte au rôle inconnu ne doit entrer dans aucun espace.
- `id` absent ou non entier : `FormatException`.
- `avatarUrl` : premier élément de `media` où `isPrimary == true`, résolu avec `MediaUrl` (URL relative
  `/uploads/...` → origine). Sinon `null`.
- `profile` : selon le rôle, d'après `docs/API_CONTRACT.md` § 4.1 ; `null` pour le staff ou si absent.
- Tolérant : un champ facultatif mal typé devient `null`, il ne fait pas échouer la lecture.

**`UserCache`** (`user_cache.dart`) : garde le dernier JSON utilisateur reçu du serveur (forme brute, pas un
format maison) dans `shared_preferences`, clé `auth_user_cache_v2`.
- `Future<Map<String, Object?>?> read()`, `Future<void> write(Map<String, Object?> json)`, `Future<void> clear()`.
- Aucune donnée sensible : ni jeton, ni mot de passe. Les jetons restent dans `TokenStorage`.
- Provider `userCacheProvider`.
- Au premier appel de `restore()`, supprimer les anciennes clés v1 : `auth_user_v1`, `auth_token_v1`,
  `auth_token_expires_at_v1`.

**`RemoteAuthRepository`** (`remote_auth_repository.dart`), dépendances : `ApiClient`, `TokenStorage`, `UserCache`.

- `signIn` :
  1. `post('auth/login', auth: false, data: {email: email.trim(), password})`.
  2. Réponse sans `accessToken` ou `refreshToken` texte : `FormatException`.
  3. `tokenStorage.save(access, refresh)`, puis `userCache.write(user)`.
  4. `GET auth/me` pour obtenir `media` et `profile`. En cas d'échec réseau, garder l'utilisateur du login :
     la connexion ne doit pas échouer pour une donnée d'affichage.
  5. Renvoyer l'`AuthUser`.
- `restore` :
  1. Supprimer les clés v1 (voir `UserCache`).
  2. `tokenStorage.read()` vaut `null` : vider le cache, renvoyer `null`.
  3. `GET auth/me` (l'intercepteur rafraîchit le jeton si besoin). Succès : écrire le cache, renvoyer l'utilisateur.
  4. `ApiFailure` de type `network`, `timeout` ou `server` : renvoyer l'utilisateur du cache s'il existe
     (démarrage hors ligne), sinon `null` **sans effacer les jetons**.
  5. `ApiFailure` 401 ou 403 : l'intercepteur a déjà effacé les jetons et émis l'événement de fin de session.
     Vider le cache et renvoyer `null`.
  6. JSON illisible (`FormatException`) : `clearLocalSession()`, renvoyer `null`.
- `signOut` : lire les jetons ; si un refresh token existe, `post('auth/logout', auth: false,
  data: {refreshToken})` en ignorant toute erreur ; puis `tokenStorage.clear()` et `userCache.clear()`.
- Provider `authRepositoryProvider = Provider<AuthRepository>((ref) => RemoteAuthRepository(...))`, défini
  dans `remote_auth_repository.dart` ou dans `auth_controller.dart` (garder un seul endroit).

### Application

**`AuthState`**
- `status` : `initial`, `unauthenticated`, `authenticated`.
- `user` : `AuthUser?`.
- `endReason` : `SessionEndReason?`, renseigné quand la session s'est terminée sans action de l'utilisateur
  (affiché par la page de connexion).
- Supprimer `accessToken`, `expiresAt`, `isExpired` : les jetons et leur expiration relèvent de la couche réseau.
- `capabilities` reste un raccourci vers `user?.capabilities`.
- `==` et `hashCode` : `status`, `user?.id`, `user?.role`, `endReason`.

**`AuthController`** (`Notifier<AuthState>`)
- `build()` :
  1. S'abonne à `ref.read(sessionEventsProvider).stream` (désabonnement dans `ref.onDispose`).
  2. Lance la restauration une seule fois.
  3. Renvoie `AuthState.initial()`.
- Restauration : `repository.restore()`.
  - Un utilisateur : `authenticated`, puis `ref.read(realtimeServiceProvider).start()` sans l'attendre.
  - `null` : `unauthenticated`, avec le motif reçu pendant la restauration s'il y en a un.
  - Toute exception inattendue : `unauthenticated`, sans lever.
- `Future<Failure?> signIn({email, password})` : renvoie la `Failure` à afficher, ou `null`.
  - Succès : `authenticated` (`endReason` à `null`), puis démarrage du temps réel.
  - `ApiFailure` 401 sans code : `AuthFailure('invalid_credentials')`. Le backend ne donne pas de code et le
    message générique d'un 401 est « session expirée », ce qui serait faux ici.
  - Autres `ApiFailure` (403 `ACCOUNT_SUSPENDED`, 429, réseau…) : renvoyées telles quelles, leur
    `message(l10n)` est déjà localisé.
  - `FormatException` ou autre : `UnexpectedFailure()`.
- `Future<void> signOut()` : `realtime.stop()`, `repository.signOut()`, puis `unauthenticated` (sans motif).
- `Future<void> refreshUser()` : `repository.refreshCurrentUser()` ; ne change l'état que si l'on est
  connecté ; ignore les échecs réseau. Prévu pour C10 et C11, à ajouter dès maintenant.
- Événement de `SessionEvents` :
  - Si `authenticated` : `realtime.stop()`, `repository.clearLocalSession()`, puis `unauthenticated(endReason)`.
  - Si `initial` (pendant la restauration) : mémoriser le motif pour l'état final.
  - Si déjà `unauthenticated` : mettre seulement `endReason` à jour. Un 403 au login émet aussi
    `suspended` : la page affiche déjà son erreur, ce n'est pas grave.
- Supprimer `updateProfileName` et `authAccessTokenProvider` (aucun autre appelant). La vraie modification du
  profil arrive en C10.

**`LoginController`** : `submit({email, password})` sans `expectedRole`.

### Présentation et routeur

- `login_page.dart` :
  - Retirer le panneau des comptes de démonstration, `_fillFromAccount` et l'import de `demo_auth_repository.dart`.
  - Retirer `expectedRole` et le lien « Créer un compte » (réintroduit en C07).
  - Garder la bannière du rôle choisi (`SelectedRoleBanner`) jusqu'en C07.
  - Si `authControllerProvider.endReason` est renseigné et qu'aucune erreur de formulaire n'est affichée,
    afficher le même encadré que les erreurs avec : `sessionEndedExpired` (« Votre session a expiré.
    Reconnectez-vous. »), `sessionEndedSuspended` (réutiliser `apiErrAccountSuspended`) ou
    `sessionEndedRevoked` (« Vous avez été déconnecté depuis un autre appareil ou par l'équipe. »).
    Ajouter les clés FR/EN nécessaires.
- `role_profile_page.dart` :
  - Retirer le mode édition du nom (bouton, formulaire, dialogue d'abandon, `_save`).
  - Afficher en lecture seule : nom complet, e-mail, téléphone, rôle (`roleLabel`, sinon libellé local),
    statut de vérification du profil, capacités.
  - Clés ARB devenues inutiles : les supprimer seulement si plus aucun fichier ne les utilise.
- `redirect_policy.dart` : supprimer la branche « session expirée » et les références à `isExpired`. Le reste
  ne change pas en C06.
- `app_router.dart` :
  - Supprimer les deux appels `signOut()` liés à `isExpired` (vers les lignes 260-270 et 389) et l'import de
    `RegisterPage` ; retirer la route `RoutePaths.register`.
  - `RedirectPolicy.isAuthLocation` ne garde que `login` (C07 rajoute les autres).
  - `currentUserId` de `SuperAdminStaffPage` reçoit `user?.id.toString()` jusqu'à C34.
- `user_avatar.dart` et les appelants : `photoUrl` → `avatarUrl` côté `AuthUser`. Le paramètre `photoUrl` du
  widget `UserAvatar` garde son nom.

### Migration des appels

Lancer `grep -rn "AuthUser(\|fullName:\|photoUrl\|DemoAuthRepository\|expectedRole\|sessionStorageProvider\|authAccessTokenProvider\|updateProfileName" lib test`.
Chaque occurrence doit être traitée. `fullName` reste disponible en getter : les pages qui ne font que
l'**afficher** ne changent pas. Les classes `AdminUser`, `StaffAccount`, `ChatParticipant` et `BuyerOrder` ont
leur propre `fullName` : **ne pas y toucher**.

### Tests

**Support commun** — `test/support/auth_fakes.dart` :
- `AuthUser testUser(UserRole role, {int id = 1, Set<String>? agentCapabilities, ProfileVerificationStatus status = ProfileVerificationStatus.verified})`.
  Prénom et nom par défaut lisibles (par exemple `Awa` `Diallo`). Pour `agent` sans liste fournie : les 4
  capacités historiques, pour que les tests agent actuels gardent leurs onglets.
- `class FakeAuthRepository implements AuthRepository` :
  - utilisateur restauré configurable (`restoreUser`) ;
  - comptes acceptés pour `signIn` (`Map<String, AuthUser>` par e-mail, mot de passe unique `Demo@2026x`) ;
  - `signInFailure` configurable ;
  - compteurs d'appels ;
  - aucun minuteur en attente.
- `List<Override> signedInOverrides(AuthUser user)` qui renvoie :
  - `authRepositoryProvider` → `FakeAuthRepository(restoreUser: user)` ;
  - `tokenStorageProvider` → `InMemoryTokenStorage` amorcé (ajouter un paramètre facultatif
    `InMemoryTokenStorage({TokenPair? initial})` à `test/support/in_memory_token_storage.dart`) ;
  - `realtimeServiceProvider` → service construit sur `FakeRealtimeTransport` (aucun vrai socket en test).
- `List<Override> signedOutOverrides({FakeAuthRepository? repository})` : même chose sans session.

**Migration des tests existants** : remplacer partout l'amorçage par `SharedPreferences` (`'auth_user_v1':
jsonEncode(AuthUser(...).toJson())`) par `...signedInOverrides(testUser(UserRole.x))` dans les `overrides`
du `ProviderScope`. Les clés `welcome_*` restent. Fichiers concernés : la sortie de
`grep -rln "auth_user_v1\|AuthUser(" test`.

Tests réécrits :
- `auth_session_test.dart` : sur `FakeAuthRepository` et `InMemoryTokenStorage` (restauration avec et sans
  session, connexion, déconnexion, fin de session par événement).
- `v2_role_foundation_test.dart` : retirer les cas `role_mismatch`, `role_not_allowed` et les comptes de
  démonstration ; garder les cas de rôles et capacités.
- `user_role_test.dart` : `fromCode`, `fromName` qui ne lève plus.
- `widget_test.dart` : supprimer « registers a new account… », « rejects a demo account whose role does not
  match… », « an expired stored session is cleared… » et « register form validates… » (ils reviennent sous une
  autre forme en C07). Réécrire « signs in with a demo account… » en « signs in through the form and reaches
  the role dashboard » avec `FakeAuthRepository`.
- `access_policy_test.dart` : retirer les cas `isExpired` et les cas « persisted capability list » ; ajouter
  « ADMIN et ROOT reçoivent les 9 capacités », « un AGENT sans fiche n'en a aucune ».
- `role_profile_test.dart` : retirer les cas d'édition du nom ; vérifier l'affichage en lecture seule.
- `auth_responsive_presentation_test.dart` : retirer « registration presentation fits… » (revient en C07).

Nouveaux tests :
- `auth_user_dto_test.dart` :
  - lecture de `test/fixtures/api/login_agent_with_capabilities.json` (porté de la branche GetX) ;
  - un utilisateur `/auth/me` avec `media` et `profile` fournisseur ;
  - un rôle inconnu lève `FormatException` ;
  - un champ facultatif mal typé devient `null` ;
  - capacités : admin et root (9), agent avec fiche, agent sans fiche, acheteur.
- `remote_auth_repository_test.dart` (avec `fake_http_adapter.dart`) :
  - login : jetons enregistrés, `GET /auth/me` appelé, utilisateur du login conservé si `/auth/me` échoue ;
  - login 401 → `ApiFailure` 401 ;
  - restore sans jetons → `null` ;
  - restore réseau KO avec cache → utilisateur du cache, jetons intacts ;
  - restore 401 → `null` et cache vidé ;
  - signOut : `POST /auth/logout` avec le refresh token, jetons et cache effacés même si le serveur répond 500 ;
  - les clés v1 sont supprimées.
- `auth_controller_test.dart` :
  - 401 au login → `invalid_credentials` ;
  - 403 suspendu → `ApiFailure` dont le message est `apiErrAccountSuspended` ;
  - le temps réel démarre à la connexion et s'arrête à la déconnexion (vérifié sur `FakeRealtimeTransport`) ;
  - un événement `expired` pendant une session → `unauthenticated` avec `endReason` ;
  - un événement pendant la restauration est conservé.

### Critères d'acceptation

- `grep -rn "Demo\(Auth\|Account\)\|expectedRole\|role_mismatch\|auth_token_v1\|SessionStorage" lib` ne renvoie rien.
- `flutter analyze` propre et `flutter test` vert. Le nombre de tests baisse ; le commit dit de combien et pourquoi.
- À la main, backend lancé avec `npm run seed:demo`, application en `--dart-define-from-file=env/dev.emulator.json` :
  - `admin@demo.agriconnect.test` / `Demo@2026x` mène au tableau de bord Admin, et la console du backend
    montre `POST /api/v2/auth/login 200` puis `GET /api/v2/auth/me 200` ;
  - mauvais mot de passe → « Identifiants invalides » (message localisé) ;
  - après redémarrage de l'application, la session est restaurée sans repasser par la connexion ;
  - déconnexion → page de connexion, et `POST /api/v2/auth/logout 204` côté backend.

### Hors périmètre

Inscription, mot de passe oublié, documents légaux, suppression de la page des rôles (C07). Modification du
profil, avatar, sessions (C10). Coquille staff à 9 sections (C21).

---

## C07 — `feat(auth)!: sign-in without role picking, role-aware sign-up and recovery`

### Objectif

Le parcours d'accueil devient : présentation → langue → connexion. Le rôle n'est plus choisi avant la connexion :
il vient du serveur. L'inscription revient au format du backend (Fournisseur ou Acheteur uniquement). On ajoute
« mot de passe oublié » et la lecture des conditions.

### Fichiers

| Action | Fichier |
|---|---|
| Modifié | `lib/features/auth/domain/auth_repository.dart` (+ `register`, `forgotPassword`, `legalDocument`) |
| Nouveau | `lib/features/auth/domain/register_request.dart`, `lib/features/auth/domain/legal_document.dart` |
| Modifié | `lib/features/auth/data/remote_auth_repository.dart` |
| Nouveaux | `lib/features/auth/application/register_controller.dart`, `forgot_password_controller.dart`, `legal_document_provider.dart` |
| Nouveaux | `lib/features/auth/presentation/pages/register_page.dart`, `forgot_password_page.dart`, `legal_document_page.dart` |
| Modifié | `lib/features/auth/presentation/pages/login_page.dart` |
| Supprimés | `lib/features/onboarding/presentation/pages/role_page.dart`, `lib/features/auth/presentation/widgets/selected_role_banner.dart` |
| Modifiés | `lib/features/onboarding/application/welcome_controller.dart`, `welcome_state.dart`, `lib/features/onboarding/data/welcome_storage.dart` |
| Modifié | `lib/features/auth/domain/user_role.dart` (`onboardingRoles` → `signupRoles = [supplier, buyer]`) |
| Modifiés | `lib/core/constants/route_paths.dart`, `lib/app/router/redirect_policy.dart`, `lib/app/router/app_router.dart` |
| Modifié | `lib/core/utils/validators.dart` |
| Modifiés | ARB FR/EN (+ générés) |
| Tests | voir plus bas |

Pour l'apparence de la page d'inscription, reprendre la mise en page de l'ancienne
(`git show HEAD~1:lib/features/auth/presentation/pages/register_page.dart`) : `AuthPageLayout`, `AppTextField`,
`PrimaryButton`, encadré d'erreur.

### Domaine et données

**`RegisterRequest`** : `firstname`, `lastname`, `phone`, `email`, `password`, `role` (`UserRole.supplier` ou
`UserRole.buyer`, sinon `ArgumentError`), `acceptTerms` (doit valoir `true`), `location?`, `referralCode?`,
`farmName?` (fournisseur), `buyerType?` (`RETAILER | FARMER | WHOLESALER | OTHER`, acheteur),
`businessName?` (acheteur).
- `toJson()` n'envoie que les champs non vides et pertinents pour le rôle.
- `role` est envoyé en code backend (`SUPPLIER` ou `BUYER`).
- Le téléphone est envoyé normalisé : espaces, points et tirets retirés.

**`LegalDocument`** : `code`, `version`, `locale`, `title`, `content` (texte brut, avec retours à la ligne),
`publishedAt`.

**`RemoteAuthRepository`** :
- `register(RegisterRequest)` : `post('auth/register', auth: false, data: request.toJson())`, puis même
  traitement que `signIn` (jetons, cache, `GET /auth/me` au mieux).
- `forgotPassword(String email)` : `post('auth/forgot-password', auth: false, data: {email})`.
- `legalDocument(String code, String languageCode)` : `get('legal/$code', auth: false, query: {'lang': languageCode})`.

**`AuthController.register(RegisterRequest)`** : comme `signIn`. Correspondance des erreurs :
- 409 sans code : si `serverMessage` contient « email », l'erreur s'affiche sous le champ e-mail
  (`registerEmailTaken`) ; si elle contient « numéro », sous le téléphone (`registerPhoneTaken`) ; sinon,
  `errConflict` dans l'encadré.
  **Fragile** : cela dépend du texte du backend. Ajouter un test qui fige ces deux messages, et noter dans le
  commit qu'un code serveur (`EMAIL_TAKEN`, `PHONE_TAKEN`) serait préférable (évolution backend à proposer,
  hors de ce commit).
- 400 avec `details[]` : `ApiFailure.fieldErrors` affichés sous les champs correspondants (`firstname`,
  `lastname`, `phone`, `email`, `password`, `farmName`, `businessName`, `referralCode`, `acceptTerms`).
- `REFERRAL_CODE_UNKNOWN` : sous le champ code de parrainage (message `apiErrReferralCodeUnknown` existant).

### Validation côté client (`validators.dart`)

Reproduire exactement les règles du backend pour éviter les allers-retours :
- `password` :
  - au moins 8 caractères ;
  - au moins une minuscule, une majuscule, un chiffre et un caractère parmi `@$!%*?&` ;
  - seuls lettres, chiffres et `@$!%*?&` sont acceptés ;
  - pas 4 caractères identiques d'affilée.
  Un message par règle non respectée, la première trouvée. Regex du backend :
  `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])(?!.*(.)\1\1\1)[A-Za-z\d@$!%*?&]{8,}$`.
  **Ne pas appliquer** cette règle au formulaire de connexion : un mot de passe non conforme ne doit pas
  empêcher d'essayer de se connecter. La connexion ne vérifie que « non vide ».
- `phone` : après normalisation, `^\+?[0-9]{8,15}$`.
- `personName` (prénom, nom) : 2 à 80 caractères après `trim`.
- `farmName` : 2 à 120 caractères ; `businessName` ≤ 120 ; `referralCode` ≤ 20.
- `email` : inchangé (accepte `.test`).

### Écrans

**Connexion** (`login_page.dart`) :
- Champs e-mail et mot de passe uniquement ; plus de bannière de rôle.
- Liens « Mot de passe oublié ? » (→ `RoutePaths.forgotPassword`) et « Créer un compte » (→ `RoutePaths.register`).
- Messages : 401 → `invalid_credentials` (déjà fait en C06), 403 suspendu, 429 trop de tentatives
  (`apiErrRateLimited`), réseau.

**Inscription** (`register_page.dart`), un seul formulaire défilant :
1. Choix du type de compte : `SegmentedButton` Fournisseur | Acheteur, Acheteur par défaut. Texte d'aide :
   « Les comptes livreur sont créés par l'équipe AgriConnect. »
2. Prénom, nom, téléphone (clavier téléphone), e-mail, mot de passe, confirmation.
3. Selon le type :
   - Fournisseur : nom de l'exploitation (facultatif côté serveur, mais à proposer).
   - Acheteur : type d'acheteur (liste des 4 valeurs, libellés localisés) et nom de l'entreprise (facultatif).
4. Localisation (texte libre, facultatif), code de parrainage (facultatif).
5. Case « J'accepte les conditions », avec deux liens qui ouvrent la page des conditions : `CGU`, puis
   `BUYER_TERMS` ou `SUPPLIER_CONSIGNMENT_TERMS` selon le type. Bouton désactivé tant que la case n'est pas
   cochée.
6. Bouton « Créer mon compte » ; état de chargement ; champs désactivés pendant l'envoi.

Après succès : le routeur emmène vers l'espace du rôle (comportement actuel).

**Mot de passe oublié** (`forgot_password_page.dart`) : un champ e-mail et un bouton. Après réponse 200,
toujours le même message (« Si un compte existe pour cette adresse, un e-mail vient d'être envoyé. »), puis un
bouton retour vers la connexion. Gérer 429 et les erreurs réseau. Ne jamais indiquer si le compte existe.

**Conditions** (`legal_document_page.dart`, route `/legal/:code`) : chargement, erreur avec réessai, titre,
version, date, contenu défilant. Langue = `localeProvider`.

### Accueil et routeur

- `WelcomeState` et `WelcomeController` : retirer `selectedRole`, `selectRole` et `clearSelectedRole`.
  `WelcomeStorage` supprime la clé `welcome_selected_role_v1` au chargement.
- `RoutePaths` : retirer `role` ; ajouter `forgotPassword = '/forgot-password'` et `legal = '/legal/:code'`
  (avec un helper `legalFor(code)`).
- `RedirectPolicy`, cas non connecté : présentation non faite → `onboarding` ; langue absente → `language` ;
  sinon, les pages publiques autorisées sont `login`, `register`, `forgotPassword` et `/legal/...`, et toute
  autre adresse mène à `login`. Connecté : comportement inchangé (une page publique renvoie vers l'accueil du
  rôle).
- `LanguagePage` ne change pas : c'est `RedirectPolicy` qui mène à `login` une fois la langue choisie.
- `UserRole.onboardingRoles` et `selectableForSignup` remplacés par `signupRoles`.

### Tests

- `access_policy_test.dart` : retirer les cas « choix du rôle » ; ajouter : langue choisie sans session →
  `login` ; `register`, `forgot-password` et `/legal/CGU` accessibles sans session ; un utilisateur connecté
  qui ouvre `/register` revient à l'accueil de son rôle ; aucune boucle de redirection.
- `widget_test.dart` :
  - parcours présentation → langue → connexion ;
  - inscription Acheteur complète sur `FakeAuthRepository` jusqu'au tableau de bord acheteur ;
  - inscription refusée si les conditions ne sont pas acceptées (bouton inactif) ;
  - erreur 409 e-mail affichée sous le champ e-mail.
- `test/features/auth/validators_test.dart` : chaque règle du mot de passe (y compris `Paaaa1x@` refusé pour
  4 caractères identiques d'affilée, et `Abcdef1#` refusé car `#` n'est pas accepté), téléphone avec espaces, limites des noms.
- `test/features/auth/register_request_test.dart` : JSON fournisseur et acheteur, champs vides omis,
  téléphone normalisé.
- `remote_auth_repository_test.dart` : `register` (201 puis `/auth/me`), `forgotPassword`, `legalDocument`
  avec `lang`.
- `auth_responsive_presentation_test.dart` : la page d'inscription tient aux largeurs testées (360, 390,
  600 dp) avec les champs du fournisseur et ceux de l'acheteur.
- `welcome_responsive_presentation_test.dart` et `mobile_keyboard_audit_test.dart` : retirer la page des rôles,
  ajouter mot de passe oublié et inscription au contrôle clavier.

### Critères d'acceptation

- `grep -rn "RolePage\|selectedRole\|SelectedRoleBanner\|onboardingRoles" lib` ne renvoie rien.
- À la main contre le backend :
  - créer un acheteur → dans maildev, l'e-mail de vérification arrive ; l'application ouvre l'espace acheteur ;
  - recréer avec le même e-mail → erreur sous le champ e-mail ;
  - mot de passe `Paaaa1x@` → refusé par le formulaire, sans appel réseau ;
  - mot de passe oublié → message neutre, et e-mail visible dans maildev pour un compte existant ;
  - les deux liens de conditions s'ouvrent, en FR et en EN.

### Hors périmètre

Vérification d'e-mail dans l'application (bannière et renvoi : C10). Inscription livreur (création par l'Admin :
C34). Réinitialisation du mot de passe dans l'application : le lien de l'e-mail ouvre une page web du backend.

---

## C08 — `test(app): staff sessions stay interactive after sign-in`

### Objectif

Empêcher le retour du bug de la branche GetX : après connexion d'un compte Admin, Root ou Agent, plus aucun
appui n'était pris en compte. Le test doit échouer si la coquille staff devient inerte, quelle qu'en soit la
cause (barrière modale, widget plein écran au-dessus, erreur de construction, navigation cassée).

### Fichiers

| Action | Fichier |
|---|---|
| Nouveau | `test/staff_interaction_guard_test.dart` |
| Nouveau | `docs/E2E_CHECKLIST.md` |
| Modifié | `test/support/auth_fakes.dart` si un utilitaire manque |

Aucun fichier de `lib/` ne doit changer, **sauf** si le test révèle un vrai défaut. Dans ce cas, corriger la
cause dans `lib/` dans le même commit et l'expliquer dans la description. Ne jamais adapter le test pour qu'il
passe.

### Mise en place

- Partir des réglages de `test/role_shell_responsive_navigation_test.dart` et `test/agent_space_test.dart` :
  taille d'écran (`tester.view.physicalSize`, `devicePixelRatio`, remise à zéro par `addTearDown`), fakes
  `FakeAdminRepository`, `FakeAgentRepository` et `FakeSuperAdminRepository`, clés `welcome_*` dans
  `SharedPreferences`.
- Session : `signedOutOverrides(repository: FakeAuthRepository(accounts: {...}))`. Le test commence **non
  connecté**, sur la page de connexion, et se connecte **par le formulaire**. Le bug survenait après la
  connexion, pas sur une session restaurée.
- Comptes de test :
  - `admin@test.local` → `testUser(UserRole.admin)` ;
  - `root@test.local` → `testUser(UserRole.root)` ;
  - `agent@test.local` → `testUser(UserRole.agent, agentCapabilities: {les 9})`.

### Scénario, pour chaque rôle × chaque largeur (390 dp téléphone, 1280 dp tablette)

1. Saisir e-mail et mot de passe, appuyer sur « Se connecter », `pumpAndSettle`.
2. Vérifier :
   - la page d'accueil du rôle est affichée (type de page, comme dans `role_shell_responsive_navigation_test`) ;
   - `find.byType(ErrorWidget)` ne trouve rien ;
   - `tester.takeException()` est `null`.
3. Lister les destinations de la coquille : barre du bas, plus la feuille « Plus » sur téléphone ; barre
   latérale `ValueKey('roleShellSidebar')` sur tablette. Pour **chaque** destination :
   - l'appuyer (`warnIfMissed: true`), puis `pumpAndSettle` ;
   - vérifier que la destination est maintenant sélectionnée (`NavigationBar.selectedIndex`, ou le
     `ListTile.selected` de la barre latérale, ou la destination « Plus » pour une section secondaire) ;
   - vérifier que la page attendue est affichée, sans `ErrorWidget` ni exception.
   Une destination qui ne réagit pas fait échouer le test **avec le nom de la destination** dans le message
   (`reason:`).
4. Dans la section Profil, appuyer sur `SignOutButton` : la boîte de confirmation (`AlertDialog`) doit
   s'ouvrir. Appuyer sur « Annuler » : elle se ferme et le profil est toujours affiché. C'est le contrôle
   « un bouton réagit », valable pour tous les rôles.
5. Rouvrir la confirmation et appuyer sur « Confirmer » : retour à la page de connexion. La déconnexion
   fonctionne, et le test se termine sans session.

Écrire le scénario une fois, dans une fonction paramétrée par rôle et largeur, puis générer les 6 cas.

### Vérifier que le test attrape le bug (à faire en local, ne pas commiter)

Entourer temporairement le contenu de `RoleShell` d'un `IgnorePointer(ignoring: true, ...)`, ou ajouter un
`ModalBarrier(dismissible: false)` plein écran dans un `Stack` au-dessus. Lancer
`flutter test test/staff_interaction_guard_test.dart` : les 6 cas doivent échouer. Annuler la modification et
écrire dans la description du commit que cette vérification a été faite.

### `docs/E2E_CHECKLIST.md`

Créer le fichier avec une section « Interactivité des rôles staff », à refaire à la fin des phases 8, 9 et 10 :
- Prérequis : backend sur `feature/mobile-contract`, `npm run seed:demo`, application lancée avec
  `--dart-define-from-file=env/dev.emulator.json`.
- Comptes : `admin@demo.agriconnect.test`, `agent.complet@demo.agriconnect.test` et
  `agent.support@demo.agriconnect.test`, mot de passe `Demo@2026x`. Aucun compte ROOT n'est fourni par le seed :
  à créer à la main ou à ignorer, en le notant.
- Pour chaque compte : se connecter, ouvrir chaque onglet, appuyer sur un bouton par section, ouvrir et annuler
  la déconnexion, puis se déconnecter. Case à cocher par compte et par onglet, avec date et résultat.
- Les autres parcours de bout en bout seront ajoutés en C42.

### Critères d'acceptation

- `flutter test test/staff_interaction_guard_test.dart` : 6 cas verts.
- La vérification « le test échoue avec `IgnorePointer` » a été faite et mentionnée dans le commit.
- **Point de contrôle de phase** : Thierry fait à la main la section de `E2E_CHECKLIST.md` avec le compte Admin
  et un compte Agent sur l'émulateur, contre le vrai backend. On ne passe pas à la phase 3 sans ce contrôle.
