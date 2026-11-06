# Plan d'intégration frontend ↔ backend

Mis à jour le 7 novembre 2026. Ce fichier est la feuille de route **exécutable** : il contient la description
complète de chaque commit restant. Le plan illustré (contexte, décisions, risques) reste sur
https://claude.ai/artifact/HNhWPnpodzbn7vEkEybjqi, mais un agent de code n'a besoin que de ce fichier, de
`docs/API_CONTRACT.md` et de `.github/copilot-instructions.md`.

Statuts : À FAIRE · EN COURS · FAIT · ANNULÉ (raison).

## 1. Dépôts et branches

| Dépôt | Branche de travail | Copie distante | État |
|---|---|---|---|
| `agriconnect_frontend` | `feature/api` (PC) | `origin/feature/api-setup` | Phases 0 et 1 faites |
| `agriconnect-backend` | `feature/mobile-contract` (PC) | `origin/feature/ai-fallback` | B1 à B4 et B6 faits, B5 à faire |

- Le contenu de `feature/api` et de `origin/feature/api-setup` est identique ; seuls les identifiants de commit
  diffèrent (commits repris par cherry-pick). Travailler sur `feature/api`.
- Code GetX à porter (entités, API, DTO, tests de contrat) : branche `origin/feature/api-connection-first`.
  Le lire avec `git show origin/feature/api-connection-first:<chemin>`, ne jamais la fusionner ni basculer dessus.

## 2. Avancement

### Baseline

| Vérification | Résultat |
|---|---|
| `dart analyze` | Après C05 et `close_sinks` (7 novembre) : 0 erreur, 0 avertissement, 0 remarque attendue (à confirmer) |
| `flutter test` | Après C05 : 700 tests réussis |

### Backend (`agriconnect-backend`)

| # | Commit | Statut |
|---|---|---|
| B1 | chore(dev): log API requests with morgan and run with nodemon | FAIT |
| B2 | feat(ai): add Anthropic Claude provider | FAIT (inactif tant que `ANTHROPIC_API_KEY` est vide) |
| B3 | feat(ai): automatic fallback to a second provider on timeout or outage | FAIT |
| B4 | fix(seed): demo AI agent follows AI_PROVIDER instead of pinning Ollama | FAIT |
| B5 | docs(api): fix Order, sender label and AdminUser schemas, document sockets | À FAIRE (avant la phase 9) |
| B6 | fix(staff): lot validation no longer requires a rejection reason | FAIT |

### Frontend (`agriconnect_frontend`)

| Phase | # | Commit | Statut |
|---|---|---|---|
| 0 | C01 | chore(android): build with the local toolchain and allow network access | FAIT |
| 0 | C02 | docs: API contract, integration plan and coding-agent rules | FAIT |
| 1 | C03 | feat(core): environment config, Dio client and typed API failures | FAIT |
| 1 | C04 | feat(auth): secure token storage and single-flight refresh | FAIT |
| 1 | C05 | feat(realtime): Socket.io service with token-aware reconnection | FAIT (+ 2 commits de correctifs d'analyse) |
| 2 | C06 | feat(auth)!: remote authentication and backend user model | À FAIRE |
| 2 | C07 | feat(auth)!: sign-in without role picking, role-aware sign-up and recovery | À FAIRE |
| 2 | C08 | test(app): staff sessions stay interactive after sign-in | À FAIRE |
| 3 | C09 | feat(reference): cached reference data and pickers | À FAIRE |
| 3 | C10 | feat(account): profile, avatar, sessions and email verification | À FAIRE |
| 3 | C11 | feat(account): profile verification documents and verified-only gating | À FAIRE |
| 3 | C12 | feat(account): payout accounts and referral | À FAIRE |
| 4 | C13 | feat(chat)!: support conversations over REST and Socket.io | À FAIRE |
| 5 | C14 | feat(buyer)!: anonymous listing catalog with server-side filters | À FAIRE |
| 5 | C15 | feat(buyer)!: replace cart and checkout with quote requests | À FAIRE |
| 5 | C16 | feat(buyer)!: quotes and orders with countdown, confirmation and tracking | À FAIRE |
| 6 | C17 | feat(supplier)!: stock lots replace products | À FAIRE |
| 6 | C18 | feat(supplier): lot declaration with multipart photos | À FAIRE |
| 6 | C19 | feat(supplier)!: earnings tab replaces supplier orders | À FAIRE |
| 7 | C20 | feat(driver)!: pull-based delivery pool and status progression | À FAIRE |
| 8 | C21 | feat(staff)!: capability-driven staff shell with nine capabilities | À FAIRE |
| 8 | C22 | feat(staff): support inbox and conversation handling | À FAIRE |
| 8 | C23 | feat(staff): lot validation, quality checks and stock movements | À FAIRE |
| 8 | C24 | feat(staff): listing management from validated lots | À FAIRE |
| 8 | C25 | feat(staff): quote issuing and order processing | À FAIRE |
| 8 | C26 | feat(staff): payment recording with idempotency | À FAIRE |
| 8 | C27 | feat(staff): delivery dispatch coordination | À FAIRE |
| 8 | C28 | feat(staff): profile verification review | À FAIRE |
| 8 | C29 | feat(staff): supplier compensation requests | À FAIRE |
| 9 | C30 | feat(ai): suggestion repository with realtime tracking | À FAIRE |
| 9 | C31 | feat(ai): reply suggestions in the support thread | À FAIRE |
| 9 | C32 | feat(ai): AI listing drafts from lots | À FAIRE |
| 9 | C33 | feat(admin): AI engine status, test console and AI agents | À FAIRE |
| 10 | C34 | feat(admin)!: users, drivers and staff accounts | À FAIRE |
| 10 | C35 | feat(admin)!: statistics dashboard from /admin/stats | À FAIRE |
| 10 | C36 | feat(admin): payouts, compensations and referrals | À FAIRE |
| 10 | C37 | feat(admin): reference data, agencies and delivery zones | À FAIRE |
| 10 | C38 | feat(admin): audit log and legal document versions | À FAIRE |
| 10 | C39 | feat(root)!: real platform settings | À FAIRE |
| 11 | C40 | feat(notifications)!: notification center fed by socket events | À FAIRE |
| 11 | C41 | chore: remove remaining demo data, assets and dead code | À FAIRE |
| 11 | C42 | docs: end-to-end checklist and project status | À FAIRE |

## 3. Méthode de travail (agent de code)

Pour **chaque** commit, dans l'ordre du tableau :

1. Relire la fiche du commit (section 6), les sections concernées de `docs/API_CONTRACT.md` et le code existant
   touché. Pour tout ce qui est « porté de la branche GetX », lire d'abord le fichier source sur
   `origin/feature/api-connection-first`.
2. Annoncer en quelques lignes les fichiers qui vont changer, puis implémenter **uniquement** cette fiche.
3. Vérifier : `flutter analyze` (0 erreur, aucun nouvel avertissement), `flutter test` (vert), `git diff --check`.
   Après une modification des ARB : `flutter gen-l10n`, fichiers générés commités.
4. Commiter avec `git add <chemins exacts>`. Message : la première ligne de la fiche comme sujet, puis une
   description en français qui résume la diff **réelle** (adapter la fiche si l'implémentation diffère, et dire
   pourquoi).
5. Passer `Statut` à FAIT dans la section 2 de ce fichier, dans le même commit.
6. S'arrêter à la fin de chaque phase et à chaque point de contrôle, et attendre le feu vert de Thierry.

Interdits : pousser, réécrire l'historique, `git add .`, désactiver ou affaiblir un test, inventer un champ,
un endpoint, un code d'erreur ou une valeur d'enum. Si `API_CONTRACT.md` ne répond pas, vérifier dans le code
du backend (`../agriconnect_backend/src`) ; si le doute persiste, s'arrêter et poser la question.
Après deux échecs sur le même problème : s'arrêter et rapporter.

## 4. Ce que le socle (phases 0 et 1) fournit déjà

À réutiliser, jamais à réécrire :

| Besoin | Où |
|---|---|
| URL de l'API et origine (socket, médias) | `Env.apiBaseUrl`, `Env.origin` (`lib/core/config/env.dart`) ; lancement : `--dart-define-from-file=env/dev.emulator.json` |
| Appels REST | `apiClientProvider` → `ApiClient.get/post/patch/put/delete/postMultipart/getBytes`, chemins relatifs (`'auth/login'`), `auth: false` pour les routes publiques |
| Erreurs | `ApiFailure` (`lib/core/errors/failures.dart`) avec `kind`, `status`, `apiCode`, `fieldErrors` (erreurs `details[]` par champ) ; messages localisés via les clés `apiErr*` |
| Lecture JSON tolérante, pagination, URL des médias | `lib/core/network/json.dart`, `paginated.dart`, `media_url.dart` |
| Jetons | `tokenStorageProvider` (`flutter_secure_storage`) ; refresh unique partagé dans `AuthInterceptor.refreshAccessToken` |
| Fin de session (expirée, suspendue, révoquée) | `sessionEventsProvider` (`SessionEndReason`) : l'auth doit l'écouter en C06 |
| Temps réel | `realtimeServiceProvider` : `start()` après connexion ou restauration, `stop()` à la déconnexion (à câbler en C06), flux par événement, `joinConversation` |
| Doublures de test | `test/support/` : `fake_http_adapter.dart`, `in_memory_token_storage.dart`, `fake_realtime_transport.dart`, `fakes.dart` |

## 5. Décisions d'architecture (rappel)

- A1 : Riverpod conservé, aucune dépendance GetX.
- A2 : chaque `domain/*_repository.dart` reçoit `data/remote_*_repository.dart` ; le `Demo*` correspondant est
  supprimé dans le même commit.
- A3 : doublures de test uniquement dans `test/support/`.
- A4 : identifiants `int`, montants et quantités `double`, dates UTC.
- A5 : aucun calcul de total, frais ou commission côté client.
- A6 : jetons dans `flutter_secure_storage`, refresh unique partagé.
- A7 : le rôle vient de `user.role.code` après connexion ; aucun choix de rôle avant la connexion.
- A8 : capacités lues dans `user.agent.capabilities` ; ADMIN et ROOT reçoivent les 9.
- A9 : un seul jeu d'écrans équipe par capacité, partagé par Agent, Admin et Root.
- A10 : une fonctionnalité sans équivalent backend est supprimée, jamais simulée.
- A11 : le frontend ne parle jamais à Ollama, Gemini ni Claude.
- A12 : un commit = une étape verte.

Écarts entre la spec OpenAPI et le code backend : `docs/API_CONTRACT.md`, écarts D1 à D8. En cas de conflit, le
code du backend fait foi, pas `openapi.yaml`.

## 6. Fiches des commits restants

### Phase 2 — Authentification

> Point de contrôle : C08 doit être vert avant d'aller plus loin. S'il échoue, on corrige la coquille, jamais le test.

#### C06

```text
feat(auth)!: remote authentication and backend user model

- AuthUser : id int, firstname, lastname, phone, emailVerified,
  profileVerificationStatus, referralCode, avatar (media[]), profil du
  rôle (fournisseur, acheteur, livreur) et fiche agent
- UserCapability : les 9 capacités du backend au lieu de 4 ; ADMIN et
  ROOT reçoivent les 9, les autres celles de user.agent ou aucune
- UserRole lu depuis role.code ; fromName ne lève plus sur un nom
  inconnu (corrige la perte de langue, PROJECT_STATUS § 7.6)
- data/remote_auth_repository.dart : login, register, refresh, logout,
  me ; DemoAuthRepository et DemoAccount supprimés
- AuthController : restauration par refresh puis GET /auth/me,
  déconnexion via POST /auth/logout, motif conservé (expirée,
  suspendue, révoquée)
- expectedRole et l'erreur role_mismatch supprimés
- Les sessions v1 enregistrées sont effacées au premier lancement
- Tests réécrits sur FakeAuthRepository : auth_session,
  v2_role_foundation, user_role, widget_test, access_policy
```

#### C07

```text
feat(auth)!: sign-in without role picking, role-aware sign-up and recovery

- LoginPage : e-mail et mot de passe seuls ; panneau des comptes de démo
  supprimé ; messages dédiés pour compte suspendu (403) et trop de
  tentatives (429) ; motif de déconnexion affiché
- RegisterPage : choix Fournisseur ou Acheteur dans la page ; prénom,
  nom, téléphone, e-mail, mot de passe, localisation, code de
  parrainage ; farmName (fournisseur), buyerType et businessName
  (acheteur) ; CGU obligatoires ; erreurs details[] sous chaque champ
- validators.dart : règle de mot de passe du backend (8 caractères,
  majuscule, minuscule, chiffre, spécial parmi @$!%*?&, pas 4 identiques
  d'affilée) et téléphone ^\+?[0-9]{8,15}$
- Nouvelles pages : LegalDocumentPage (GET /legal/{code}?lang=) et
  ForgotPasswordPage (même message dans tous les cas)
- Parcours d'accueil : onboarding, langue, connexion ; RolePage sort du
  parcours obligatoire ; RedirectPolicy et WelcomeController adaptés
- Tests : auth_responsive_presentation, welcome_responsive_presentation,
  mobile_keyboard_audit mis à jour
```

#### C08

```text
test(app): staff sessions stay interactive after sign-in

- test/staff_interaction_guard_test.dart : pour ADMIN, ROOT et AGENT
  (dépôts factices), après connexion, chaque destination de navigation
  est appuyée et doit changer la section affichée ; un bouton de chaque
  section doit réagir
- Échoue si une barrière modale, un widget plein écran ou une erreur de
  construction rend la coquille inerte (bug de la branche GetX)
- docs/E2E_CHECKLIST.md : même contrôle à la main sur émulateur, à
  refaire à la fin des phases 8, 9 et 10
```

### Phase 3 — Compte et référentiels

#### C09

```text
feat(reference): cached reference data and pickers

- features/reference/ : catégories, produits, unités, zones et hubs via
  /reference/* (toutes les pages lues, 100 par page), cache mémoire
  vidé à la déconnexion
- Widgets de sélection : produit avec recherche, zone, hub, unité
- Jamais appelé pour un livreur (le backend répond 403 au rôle DRIVER)
- Entités et API portées de la branche GetX ; test reference_contract
```

#### C10

```text
feat(account): profile, avatar, sessions and email verification

- RoleProfilePage lit GET /auth/me ; PATCH /auth/me pour prénom, nom,
  localisation et e-mail (avertissement : nouvelle vérification)
- Profil du rôle : PATCH /auth/me/profile (fournisseur : farmName,
  description, zone ; acheteur : buyerType, businessName, zone ;
  livreur : véhicule, immatriculation) ; absent pour le staff
- Avatar : image_picker puis POST /auth/me/avatar (champ avatar, jpeg,
  png ou webp, 5 Mo vérifiés avant envoi)
- Nouvelle page Mes sessions : liste, fermeture d'une session, fermer
  les autres (POST /auth/logout-all)
- Bannière e-mail non vérifié avec renvoi du lien (attente de 5 min)
- updateProfileName local supprimé
```

#### C11

```text
feat(account): profile verification documents and verified-only gating

- Page Documents : POST /auth/me/documents (champ file, jpeg, png, webp
  ou pdf, 8 Mo ; type ID_CARD, BUSINESS_REGISTRATION, FARM_PROOF ou
  OTHER), liste avec statut et note du relecteur
- Bannière par statut : à compléter, en cours d'examen, refusé
- PROFILE_NOT_VERIFIED intercepté partout : dialogue vers Documents
- Bloqué tant que le profil n'est pas VERIFIED : déclaration de lot
  (fournisseur), confirmation de devis (acheteur)
- pubspec : file_picker pour les PDF
```

#### C12

```text
feat(account): payout accounts and referral

- Comptes de paiement (fournisseur, acheteur) : liste, ajout, compte par
  défaut, suppression ; seul le numéro masqué est affiché
- Parrainage : code personnel à partager, totaux en attente, éligibles
  et payés, liste des filleuls (prénom, type, statut, montant)
```

### Phase 4 — Messagerie client

#### C13

```text
feat(chat)!: support conversations over REST and Socket.io

- ChatConversation : type (BUYER_SUPPORT, SUPPLIER_SUPPORT), statut
  (OPEN, WAITING_CUSTOMER, CLOSED), sujet, escalade ; ChatParticipant et
  les interlocuteurs fictifs supprimés : l'interlocuteur est toujours
  « Équipe AgriConnect »
- ChatMessage : senderLabel (Vous, Équipe AgriConnect, Assistant
  AgriConnect (IA)) avec badge IA
- data/remote_chat_repository.dart : conversations et messages paginés
  (ordre croissant, anciens chargés en remontant), envoi par POST,
  réception par message:new après join_conversation acquitté
- Non-lus calculés localement (dernier message vu, persisté) : le
  backend n'a pas de compteur
- Ouverture : POST /conversations avec listingId (acheteur) ou lotId
  (fournisseur), jamais les deux
- DemoChatRepository supprimé ; routes de messagerie livreur supprimées
  (un livreur ne peut ouvrir aucune conversation)
```

### Phase 5 — Acheteur

> Les phases 5, 6 et 7 sont indépendantes : l'ordre est libre.

#### C14

```text
feat(buyer)!: anonymous listing catalog with server-side filters

- BuyerProduct devient CatalogListing : référence, titre, catégorie,
  unité, prix unitaire, quantité disponible, péremption, zone, images,
  grade qualité ; sellerName, location et published supprimés
- GET /catalog/listings paginé avec categoryId, zoneId, q et sort
  (price | expiry) ; défilement continu ; catégories lues dans
  /catalog/categories au lieu de l'enum CatalogCategory
- CatalogLocations (villes ivoiriennes codées en dur) supprimé ; filtre
  de zone alimenté par /reference/zones
- Fiche : GET /catalog/listings/{id}, images résolues par MediaUrl
- Partie catalogue de DemoBuyerRepository supprimée
```

#### C15

```text
feat(buyer)!: replace cart and checkout with quote requests

- Bouton « Demander un devis » sur la fiche : quantité souhaitée et
  message, puis POST /conversations {listingId, content} et ouverture
  du fil
- Supprimés : CartPage, CheckoutPage, OrderConfirmationPage,
  BuyerCartController, CheckoutController, placeOrder et leurs routes
- Tableau de bord : « Mon panier » devient « Mes demandes de devis »
- Tests panier et paiement supprimés avec la fonction ; remplacés par
  le parcours de demande de devis
```

#### C16

```text
feat(buyer)!: quotes and orders with countdown, confirmation and tracking

- BuyerOrder aligné sur le DTO : orderNumber, statut (QUOTED, CONFIRMED,
  PREPARING, READY_FOR_PICKUP, OUT_FOR_DELIVERY, COMPLETED, CANCELLED),
  lignes, subtotal, buyerFee, deliveryFee, total, mode de livraison,
  adresse ou point de retrait ; DriverInfo supprimé
- Devis QUOTED : compte à rebours jusqu'à reservedUntil ; Confirmer
  (exige VERIFIED) ; Annuler avec motif
- Suivi : étapes selon le mode (retrait au hub ou livraison),
  rafraîchies sur delivery:status et au glisser vers le bas
- Badge du nombre de devis en attente sur l'onglet Commandes
- DemoBuyerRepository supprimé ; buyer_space_test réécrit sur
  FakeBuyerRepository
```

### Phase 6 — Fournisseur

#### C17

```text
feat(supplier)!: stock lots replace products

- Product, DeclarationStatus et ProductPublicationStatus remplacés par
  SupplierLot et sa machine d'états (PENDING_VALIDATION, AVAILABLE,
  FULLY_RESERVED, SOLD_OUT, EXPIRED, RETURNED, REJECTED, WITHDRAWN)
- Onglet Produits devient Mes lots : filtres par statut ; quantités
  initiale, disponible, réservée, vendue, perdue ; motif de rejet
- Détail : modifier (PENDING_VALIDATION), supprimer (PENDING_VALIDATION
  ou REJECTED), retirer avec motif (AVAILABLE sans réservation),
  contacter l'équipe (conversation avec lotId)
- Tableau de bord : métriques calculées depuis les lots
- La règle « déclarer n'est pas publier » reste vraie : l'équipe crée
  l'annonce, jamais le fournisseur
- product_publication_policy_test remplacé par supplier_lot_state_test
```

#### C18

```text
feat(supplier): lot declaration with multipart photos

- Formulaire : produit (référentiel), zone, prix convenu, quantité,
  stockage (sur site : adresse et coordonnées ; au hub : choix du hub),
  péremption obligatoire si le produit est périssable, récolte, notes
- Photos : 1 à 5 (jpeg, png, webp, 5 Mo chacune) dans le champ images
- PROFILE_NOT_VERIFIED, FILE_TOO_LARGE, UNSUPPORTED_MEDIA_TYPE et
  INVALID_MULTIPART traduits ; details[] affichés sous les champs
- pubspec : geolocator pour proposer la position actuelle (facultatif)
- supplier_product_form_page.dart remplacé par supplier_lot_form_page.dart
```

#### C19

```text
feat(supplier)!: earnings tab replaces supplier orders

- Onglet Commandes remplacé par Revenus : reversements (ON_HOLD, READY,
  PAID, CANCELLED ; brut, commission, net) et indemnisations (statut,
  motif, montant), paginés
- Supprimés : SupplierOrder, confirmOrder, supplier_orders_page,
  supplier_order_detail_page et leurs tests (le backend ne montre jamais
  l'acheteur au fournisseur)
- DemoSupplierRepository supprimé
```

### Phase 7 — Livreur

#### C20

```text
feat(driver)!: pull-based delivery pool and status progression

- DriverDelivery aligné sur le DTO : adresses et coordonnées
  d'enlèvement et de livraison, distance, acheteur (prénom, nom,
  téléphone), articles ; jamais de prix
- Onglet Livraisons : Disponibles (rafraîchi par delivery:available) et
  Mes courses (filtre statut) ; Accepter, avec DELIVERY_ALREADY_TAKEN et
  DELIVERY_ALREADY_ACTIVE expliqués
- Détail : Récupérée, En route, Livrée ; Échec avec motif obligatoire ;
  appel et itinéraire via url_launcher (ajouté au pubspec)
- Onglet Trajets et DriverTrip supprimés (aucun équivalent backend)
- DemoDriverRepository supprimé ; tests driver_* réécrits
```

### Phase 8 — Espace équipe (Agent, Admin, Root)

> Point de contrôle : à la fin de la phase, connexion manuelle Admin puis Agent sur émulateur ; chaque onglet et un bouton par section doivent réagir.

#### C21

```text
feat(staff)!: capability-driven staff shell with nine capabilities

- RoleSection : sections support, lots, annonces, devis et commandes,
  paiements, expéditions, vérifications, litiges, chacune liée à sa
  capacité backend
- Coquille Agent : seules les sections des capacités de la fiche ;
  Admin et Root voient toutes ces sections plus les leurs
- Chaque page revérifie sa capacité et traduit le 403 « Capacité
  requise » ; agent sans capacité : écran explicatif
- StatefulShellRoute conservé : une section n'est construite qu'à sa
  première ouverture (à l'inverse de la coquille GetX)
- Supprimés : AgentCase et ses statuts, DemoAgentRepository, les 4 pages
  agent de démonstration, les sections Admin Produits, Commandes et
  Livraisons ; agent_space_test réécrit
```

#### C22

```text
feat(staff): support inbox and conversation handling

- Boîte de réception : GET /staff/conversations, filtres statut, non
  assignées, les miennes, escaladées ; nom du client affiché
- Fil équipe : messages paginés, notes internes distinguées, réponse,
  s'assigner, escalader avec motif, fermer
- Temps réel : message:new, conversation:assigned et
  conversation:escalated sur la salle staff
- Accès par type : BUYER_SUPPORT ou SUPPLIER_SUPPORT selon la fiche
```

#### C23

```text
feat(staff): lot validation, quality checks and stock movements

- File des lots : GET /staff/lots par statut (PENDING_VALIDATION par
  défaut) ; fournisseur et statut de vérification visibles
- Détail : Valider (409 NOT_VERIFIED si fournisseur non vérifié),
  Rejeter et Retourner avec motif, contrôles qualité (grade A, B ou C,
  notes) avec historique
- Mouvements de stock paginés (GET /staff/stock-movements)
- Création d'un lot pour le compte d'un fournisseur (POST /staff/lots,
  multipart)
- Valider est envoyé sans corps de requête (voir B6)
```

#### C24

```text
feat(staff): listing management from validated lots

- Liste des annonces (DRAFT, ACTIVE, SOLD, INACTIVE) et détail avec le
  lot source
- Créer depuis un lot AVAILABLE : titre, description, prix de vente,
  zone, 1 à 5 photos ; PRICE_BELOW_SUPPLIER et LOT_ALREADY_LINKED
  expliqués
- Modifier, publier (exige un lot disponible avec stock), dépublier
- Emplacement prévu pour le bouton Brouillon IA, branché en C32
```

#### C25

```text
feat(staff): quote issuing and order processing

- Émettre un devis depuis une conversation acheteur : annonces et
  quantités, prix unitaire ajustable, retrait au hub ou livraison
  (zone, adresse, coordonnées), notes ; ZONE_NOT_COVERED et
  INSUFFICIENT_STOCK expliqués
- Liste et détail : prix fournisseur, commission, net fournisseur,
  statut de paiement, origines et frais de transport
- Actions : confirmer pour l'acheteur, avancer le statut (PREPARING,
  READY_FOR_PICKUP, COMPLETED), annuler avec motif
- Totaux toujours lus dans la réponse serveur
```

#### C26

```text
feat(staff): payment recording with idempotency

- Paiements d'une commande : liste et saisie (montant, CASH,
  MOBILE_MONEY ou BANK_TRANSFER, référence, date)
- En-tête Idempotency-Key : UUID créé à l'ouverture du formulaire et
  réutilisé à chaque nouvel essai ; bouton bloqué pendant l'envoi
- Remboursement réservé à un Admin humain ; 403 traduit
- pubspec : uuid
```

#### C27

```text
feat(staff): delivery dispatch coordination

- Créer les livraisons d'une commande en livraison agence ;
  DELIVERIES_ALREADY_CREATED et INVALID_DELIVERY_MODE expliqués
- Liste par statut et commande : coût agence, frais facturé, valeur
  assurée, police d'assurance
- Actions : libérer une course acceptée, relancer après échec, annuler
- Statuts mis à jour par delivery:status
```

#### C28

```text
feat(staff): profile verification review

- File GET /admin/verifications par statut, type de document et rôle ;
  ouverte aux agents USER_VERIFICATION et aux admins
- Détail : pièce téléchargée en octets par Dio avec l'en-tête
  Authorization du relecteur (lien valable 10 min, lié à ce compte) ;
  image affichée en mémoire, PDF ouvert depuis un fichier temporaire
  supprimé à la fermeture
- Approuver ou refuser (note obligatoire) ; 409 si déjà examiné
- pubspec : path_provider, open_filex
```

#### C29

```text
feat(staff): supplier compensation requests

- Déclarer une indemnisation depuis un lot : motif (EXPIRED_UNSOLD,
  LOST_OR_DAMAGED, OTHER), quantité, livraison liée, note
- COMPENSATION_RATE_ZERO et INVALID_AMOUNT expliqués ; approbation et
  paiement restent côté Admin (C36)
```

### Phase B5 — Documentation OpenAPI (dépôt backend)

> À faire dans `agriconnect-backend`, branche `feature/mobile-contract`, avant la phase 9. Ensuite, remplacer `agriconnect-api.yaml` dans le projet Claude par le nouveau `docs/openapi.yaml`.

#### B5

```text
docs(api): fix Order, sender label and AdminUser schemas, document sockets

- openapi/order.openapi.js : schéma Order aligné sur orderToBuyerDto et
  orderToStaffDto (orderNumber, subtotal, buyerFee, deliveryFee, total,
  reservedUntil, delivery, pickup)
- openapi/openapi.config.js : senderLabel accepte « Assistant AgriConnect
  (IA) » ; référence AdminUser inexistante corrigée dans Agent.user
- docs/REALTIME.md : les 10 événements Socket.io, salles et charges
- docs/API_REALITY.md : 146 routes, section IA à jour (Ollama, Gemini, Claude,
  relais)
- docs/openapi.yaml régénéré (npm run docs:openapi)
```

### Phase 9 — Agent IA (frontend)

> Avant de commencer : `npm run ai:eval -- --provider ollama` puis `--provider gemini` côté backend. Point de contrôle manuel en fin de phase, comme pour la phase 8.

#### C30

```text
feat(ai): suggestion repository with realtime tracking

- features/ai/ : entités, API et dépôt portés de la branche GetX
  (payloads REPLY et LISTING_DRAFT ; statuts PENDING, APPROVED,
  EXECUTED, REJECTED, FAILED, EXPIRED)
- ai:suggestion et ai:suggestion_updated déclenchent la relecture de
  GET /staff/ai/suggestions/{id} (l'événement ne porte que
  l'identifiant et le statut)
- Interrogation toutes les 90 s si le socket est coupé, arrêtée dès
  un état final
- AI_DISABLED, AI_NO_AGENT, AI_BUSY, AI_RATE_LIMITED (retryAfterMs),
  AI_UNREACHABLE et AI_INVALID_OUTPUT traduits
- Tests portés : ai_api, ai_contract, contrôleur
```

#### C31

```text
feat(ai): reply suggestions in the support thread

- Fil équipe : bouton « Suggérer une réponse » (POST
  /staff/conversations/{id}/ai-suggest, réponse 202) ; état en cours
  avec le fournisseur actif affiché
- Carte de suggestion : réponse, intention, langue, confiance, raisons ;
  bandeau d'alerte si needsHuman ou avertissement (UNVERIFIED_NUMBER)
- Actions : copier dans la saisie, envoyer tel quel ou modifié (approve
  avec editedContent), rejeter avec motif
- Suggestions en attente comptées dans un badge sur l'onglet Support
```

#### C32

```text
feat(ai): AI listing drafts from lots

- Détail d'un lot AVAILABLE : « Rédiger l'annonce avec l'IA » (POST
  /staff/lots/{id}/ai-listing-draft)
- Approuver copie titre et description dans le formulaire de C24 ; rien
  n'est créé tant que l'agent n'enregistre pas l'annonce
```

#### C33

```text
feat(admin): AI engine status, test console and AI agents

- Carte Moteur IA : GET /admin/ai/status (fournisseur, modèle,
  joignable, modèle installé, file, quota Gemini, relais de B3)
- Console de test : POST /admin/ai/test, latence et sortie affichées
- Agents IA : liste, création (nom, ollama, gemini ou claude, modèle,
  autonomie), activation, capacités ; PAYMENT_FOLLOWUP masquée pour
  une fiche IA
- Avertissement : fournisseur et modèle non modifiables après création
```

### Phase 10 — Administration et Root

> Point de contrôle manuel en fin de phase, comme pour la phase 8.

#### C34

```text
feat(admin)!: users, drivers and staff accounts

- Utilisateurs : GET /admin/users (tableau non paginé) filtré par rôle,
  statut, recherche et vérification ; suspendre (le compte reçoit
  session_revoked) et réactiver
- Créer un compte : livreur (avec agence), agent, admin (Root seul)
- Agents humains : capacités (PATCH /admin/agents/{id} remplace toute
  la liste), activation
- Root : l'annuaire du personnel et StaffPermission fictifs deviennent
  ces mêmes écrans ; admin_users_page et super_admin_staff_page fusionnés
```

#### C35

```text
feat(admin)!: statistics dashboard from /admin/stats

- Tableaux de bord Admin et Root : GET /admin/stats sur une période
  (from, to) ; comptes par rôle ; lots, commandes et livraisons par
  statut ; stock ; créances ; reversements et indemnisations en
  attente ; parrainages éligibles ; chiffre d'affaires brut
- admin_analytics_page et super_admin_analytics_page réécrites ;
  AdminStats et PlatformOverview fictifs supprimés
- DemoAdminRepository supprimé ; admin_repository_test et
  admin_analytics_test réécrits
```

#### C36

```text
feat(admin): payouts, compensations and referrals

- Reversements : liste par statut, payer avec référence
- Indemnisations : approuver, rejeter avec note, payer avec référence ;
  les numéros de compte reçus en clair ne sont ni journalisés ni mis
  en cache
- Parrainages : payer ou rejeter
- Actions réservées à un humain : 403 traduit
```

#### C37

```text
feat(admin): reference data, agencies and delivery zones

- Gestion des catégories, unités, produits (périssable, unité,
  catégorie), zones et hubs (adresse, coordonnées)
- Agences de transport : création, modification, zones couvertes
  (PUT et DELETE /admin/agencies/{id}/zones/{zoneId}), livreurs
- Cache des référentiels (C09) vidé après chaque modification
```

#### C38

```text
feat(admin): audit log and legal document versions

- Journal d'audit paginé : type et identifiant d'entité, acteur humain
  ou IA, période
- CGU : nouvelle version d'un document, publication
```

#### C39

```text
feat(root)!: real platform settings

- GET /admin/settings pour Admin et Root, PATCH pour Root seul :
  commission fournisseur (0 à 50 %), frais acheteur (aucun, fixe ou
  pourcentage), majoration transport, primes de parrainage, durée de
  réservation (1 à 168 h), taux d'indemnisation ; devise en lecture
  seule
- Supprimés : registrationsOpen, autoModeration, maintenanceMode,
  supportEmail, maxUploadMb (absents du serveur) et
  DemoSuperAdminRepository
```

### Phase 11 — Notifications et finition

#### C40

```text
feat(notifications)!: notification center fed by socket events

- Entrées créées depuis message:new, delivery:status,
  delivery:available, alert:expiring, conversation:assigned,
  conversation:escalated et ai:suggestion_updated, selon le rôle
- Stockées localement par utilisateur (200 dernières), état lu conservé ;
  un appui ouvre l'écran concerné
- DemoNotificationsRepository supprimé ; notifications_test réécrit
- Limite assumée : rien n'arrive quand l'app est fermée (pas de push
  côté backend)
```

#### C41

```text
chore: remove remaining demo data, assets and dead code

- Supprimés : DemoAssets, assets/images/products, photos de démo du
  tableau de bord fournisseur, UnderConstructionPage si plus atteinte
- test/architecture_test.dart : échoue si lib/ contient « Demo », si
  package:dio est importé hors core/network et data/, ou si un fichier
  de lib/ dépasse 600 lignes
- pubspec : dépendances inutilisées retirées
```

#### C42

```text
docs: end-to-end checklist and project status

- docs/E2E_CHECKLIST.md : 8 parcours contre le backend seedé (lot
  jusqu'à l'annonce, devis jusqu'à la livraison, messagerie sur deux
  appareils, suggestion IA avec relais Gemini, suspension en direct,
  expiration du jeton, profil non vérifié, interactivité des rôles
  staff)
- docs/PROJECT_STATUS.md et README.md : état réel, lancement en local,
  variables --dart-define
```

## 7. Points de contrôle

- Après C08 : le test d'interactivité des rôles staff doit être vert avant d'aller plus loin.
- Fin des phases 8, 9 et 10 : connexion manuelle Admin et Agent sur émulateur ; chaque onglet et un bouton par
  section doivent réagir (`docs/E2E_CHECKLIST.md`, créé en C08).
- Avant la phase 9 : B5 fait, backend relancé, `npm run ai:eval` lancé sur Granite et sur Gemini.
- Fin du plan : checklist E2E complète contre `npm run seed:demo`.
