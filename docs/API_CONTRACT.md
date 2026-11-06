# AgriConnect — Contrat d'API pour le frontend Flutter

> Source de vérité pour tout code qui parle au backend. Établi par lecture du dépôt backend
> (`agriconnect-backend`, branche `feature/mobile-contract`, commit `7581f2b`) et de `docs/openapi.yaml`.
> **Règle** : la spec OpenAPI est exacte sur *quelles routes existent* et sur *ce qu'on peut envoyer*
> (146 opérations, vérifiées une à une contre `src/routes/*.routes.js`). Elle est **inexacte ou vague sur
> ce qui revient** : pour tout modèle Dart, ce document prime.
> Légende : **[code]** = vérifié dans le code du backend ; **[doc]** = repris de `docs/API_REALITY.md` du
> backend, non revérifié ligne à ligne — à confirmer par un test contre le backend réel.

## 1. Transport

| Élément | Valeur |
|---|---|
| Préfixe REST | `/api/v2` |
| Port dev | `4000` |
| Émulateur Android | `http://10.0.2.2:4000/api/v2` |
| Appareil réel | `http://<IP-LAN-du-PC>:4000/api/v2` |
| Socket.io | racine de l'origine (`http://10.0.2.2:4000`), **pas** `/api/v2` |
| Médias publics | l'API renvoie `/uploads/<dossier>/<fichier>` (relatif) → préfixer par l'**origine** (sans `/api/v2`) |
| Santé | `GET /health` → `{status:'ok'}` (hors préfixe) |
| Rate limit | `/auth/register`, `/auth/login` : 10 / 15 min / IP ; `/auth/refresh` : 60 ; `/auth/forgot-password` : 5. 429 `{error}` **sans code** |

## 2. Enveloppes

Erreur (toujours) : `{ "error": "Message FR", "code"?: "MAJUSCULES" }`.
Validation Joi (400) : `{ "error": "Données invalides", "details": [{ "field", "message" }] }`.
Champs d'appoint : `PROFILE_NOT_VERIFIED` (403) ajoute `profileVerificationStatus` ; `UNEXPECTED_FILE_FIELD` (400)
ajoute `expectedField` ; `AI_RATE_LIMITED` peut ajouter `retryAfterMs`.

**Beaucoup d'erreurs n'ont pas de `code`** : 401 « Token invalide ou expiré », 403 « Capacité requise » (code
`CAPABILITY_REQUIRED` côté IA seulement), 403 « Accès refusé pour ce rôle », 403 « Ce compte a été suspendu », 429.
Le client doit donc se replier sur *statut HTTP + message*.

Pagination : `{ items, page, limit, total }`, `page ≥ 1`, `1 ≤ limit ≤ 100`, défaut 20.
**Exceptions non paginées** : `GET /admin/users` (tableau brut), `GET /auth/me/payout-accounts` (tableau),
`GET /auth/me/documents` (tableau), `GET /staff/lots/{id}/quality-checks` (tableau), `GET /catalog/categories` (tableau),
`GET /admin/agents`, `GET /admin/agencies/{id}/drivers` (tableaux).

Nombres : montants 2 décimales, quantités 3 décimales, **toujours des nombres JSON** (jamais des chaînes) →
`double`/`num` en Dart, jamais `int`. Devise : `XAF` (lecture seule). **Tous les identifiants sont des entiers.**
Dates : ISO 8601 UTC.

Codes d'erreur métier rencontrés [code] : `INVALID_STATE_TRANSITION`, `INSUFFICIENT_STOCK`, `PRICE_BELOW_SUPPLIER`,
`ZONE_NOT_COVERED`, `PROFILE_NOT_VERIFIED`, `NOT_VERIFIED`, `LOT_ALREADY_LINKED`, `LOT_NOT_AVAILABLE`,
`TOO_MANY_PENDING_DOCUMENTS`, `INVALID_AMOUNT`, `COMPENSATION_RATE_ZERO`, `DELIVERY_ALREADY_TAKEN`,
`DELIVERY_ALREADY_ACTIVE`, `DELIVERY_NOT_FOUND`, `NOT_DELIVERY_OWNER`, `DELIVERIES_ALREADY_CREATED`,
`INVALID_DELIVERY_MODE`, `INVALID_ORDER_STATUS`, `ORDER_NOT_FOUND`, `FILE_TOO_LARGE`, `FILE_REQUIRED`,
`FILE_CONTENT_MISMATCH`, `UNSUPPORTED_MEDIA_TYPE`, `INVALID_MULTIPART`, `UNEXPECTED_FILE_FIELD`, `FILE_MISSING`,
`PROFILE_MISSING`, `RATE_LIMITED`, `CAPABILITY_REQUIRED`.
Codes IA [code] : `AI_DISABLED`, `AI_BUSY`, `AI_NO_AGENT` (409) ; `AI_RATE_LIMITED` (429) ; `AI_INVALID_KIND` (400) ;
`AI_INVALID_OUTPUT`, `AI_UNREACHABLE`, `AI_MODEL_MISSING`, `AI_AUTH_FAILED` (502 ou état `FAILED` de la suggestion) ;
`CONVERSATION_CLOSED` (409) ; `CONVERSATION_NOT_FOUND`, `LOT_NOT_FOUND` (404).

## 3. Authentification et sessions

- `POST /auth/login {email,password}` → `200 {user, accessToken, refreshToken}`. **Aucun champ rôle** : le client
  lit `user.role.code`. 401 identifiants ; 403 compte suspendu ; 429 trop de tentatives.
- `POST /auth/register` → `201 {user, accessToken, refreshToken}`. **Rôles publics : SUPPLIER ou BUYER uniquement.**
  Un DRIVER est créé par un ADMIN (`POST /admin/users` avec `agencyId`), jamais en auto-inscription.
  Champs : `firstname`(≥2) `lastname`(≥2) `phone`(`^\+?[0-9]{8,15}$`) `email` `password` `role`
  `acceptTerms`(**doit valoir true**) ; optionnels `location`, `referralCode`(≤20), `farmName`(2–120, SUPPLIER),
  `buyerType`(RETAILER|FARMER|WHOLESALER|OTHER), `businessName`(≤120). 409 : email ou téléphone déjà pris (codes distincts).
- **Mot de passe** : `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])(?!.*(.)\1\1\1)[A-Za-z\d@$!%*?&]{8,}$`.
  Seuls `@$!%*?&` sont acceptés comme caractères spéciaux ; 4 caractères identiques d'affilée sont interdits.
- **Access token** : JWT, 1 h par défaut. **Refresh token** : opaque, 30 j, **rotation à chaque refresh** ;
  réutilisation d'un jeton déjà remplacé = vol → session détruite (grâce de 30 s pour deux refresh parallèles).
  Max 5 sessions par compte.
- `POST /auth/refresh {refreshToken}` → `200 {accessToken, refreshToken}` (**pas de `user`**).
- `POST /auth/logout {refreshToken}` (public). `POST /auth/logout-all` : toutes les sessions **sauf la courante**.
- `GET /auth/sessions` → `{ sessions: [{id,userAgent,ip,createdAt,lastActivityAt,expiresAt,isCurrent}] }`.
  `DELETE /auth/sessions/{id}`.
- `POST /auth/forgot-password {email}` → 200 identique dans tous les cas. Le lien email ouvre une **page HTML du
  backend** : l'app n'implémente que le formulaire « mot de passe oublié ». `POST /auth/resend-verification`
  (auth requise, cooldown 5 min).
- **Toute requête protégée recharge l'utilisateur** : compte suspendu → **403** « Ce compte a été suspendu »
  (pas 401). 401 = jeton absent/invalide/expiré.
- **Politique client obligatoire** : sur 401 d'une route protégée → UN refresh (single-flight : les requêtes
  concurrentes attendent le même refresh), rejouer la requête une fois ; si le refresh échoue (401/403) →
  déconnexion locale. Ne jamais boucler.
- `GET /auth/me` → User + `media[]` (l'avatar y figure) + `profile` + `agent`.
  `PATCH /auth/me` [code] : accepte `firstname, lastname, email, location` ; **`latitude`/`longitude` sont ignorés** ;
  changer l'email remet `emailVerified` à false.
  `PATCH /auth/me/profile` : corps selon le rôle (SUPPLIER `{farmName,description,zoneId}`, BUYER
  `{buyerType,businessName,zoneId}`, DRIVER `{vehicleType,plateNumber}`) ; 403 pour ADMIN/AGENT/ROOT.
  `POST /auth/me/avatar` multipart champ **`avatar`** (jpeg/png/webp, 5 Mo) → 201 Media.

## 4. Formes de réponse

### 4.1 User [code : `userToApi`, `profile.dto.js`, `agent.dto.js`, `media.dto.js`]
```
User { id:int, firstname, lastname, email, phone, location:string|null,
       role:{code,label}, userStatus:{code,label}, emailVerified:bool,
       profileVerificationStatus:'UNVERIFIED'|'PENDING'|'VERIFIED'|'REJECTED',
       referralCode:string|null, createdAt }
GET /auth/me et login ajoutent : media:[{id,url,isPrimary,position}], profile, agent
agent: {id, displayName, kind:'HUMAN'|'AI', autonomy|null, capabilities:string[] (triées)} | null   // non nul seulement pour AGENT avec fiche active
profile: SUPPLIER {farmName, description|null, zoneId|null}
       | BUYER    {buyerType, businessName|null, zoneId|null}
       | DRIVER   {vehicleType|null, plateNumber|null, agencyId}
       | null (staff)
role.code ∈ ROOT|ADMIN|AGENT|SUPPLIER|BUYER|DRIVER
```

### 4.2 Lot (vue fournisseur) [code : `lot.dto.js`]
```
{ id, lotCode:'LOT-000123',
  product:{id,name,isPerishable,category:{code,label},unit:{code,label}},
  zone:{id,name}, storageType,
  hub:{id,name,city}|null, pickupAddress, pickupLatitude, pickupLongitude,
  agreedUnitPrice, quantityInitial, quantityAvailable, quantityReserved, quantitySold, quantityLost,
  status, rejectionReason|null, packagingNote|null, qualityNote|null,
  images:[{url,position,isPrimary}], harvestedAt|null, expiresAt|null, createdAt, updatedAt }
storageType ∈ 'SUPPLIER_SITE' | 'HUB'
status ∈ PENDING_VALIDATION | AVAILABLE | FULLY_RESERVED | SOLD_OUT | EXPIRED | RETURNED | REJECTED | WITHDRAWN
Vue staff = + supplier:{id,farmName,profileVerificationStatus}, validatedAt, validatedByAgentId, qualityGrade:'A'|'B'|'C'|null
```
Création `POST /supplier/lots` (multipart) : fichiers dans le champ **`images`** (1 à 5, jpeg/png/webp, 5 Mo chacun,
**au moins 1**), `productId, zoneId, agreedUnitPrice, quantity, storageType` obligatoires ; `hubId` si `HUB` ;
`pickupAddress + pickupLatitude + pickupLongitude` si `SUPPLIER_SITE` ; `expiresAt` obligatoire si
`product.isPerishable` ; `harvestedAt, packagingNote(≤500), qualityNote(≤500)` optionnels.
**Exige `profileVerificationStatus == VERIFIED`** (sinon 403 `PROFILE_NOT_VERIFIED`, renvoyé avant l'écriture des fichiers).
`PATCH` : uniquement en `PENDING_VALIDATION`, champs `agreedUnitPrice, quantity, expiresAt, harvestedAt, packagingNote,
qualityNote` (pas de photos, pas de produit/zone/stockage). `DELETE` : `PENDING_VALIDATION` ou `REJECTED`.
`POST /supplier/lots/{id}/withdraw {reason}` : `AVAILABLE` sans réservation.

### 4.3 Annonce
Vue **acheteur** [code : `listingToBuyerDto`] — *aucun lot, aucun fournisseur, aucun prix convenu* :
```
{ id, reference:'ANN-000456', title, description|null, category:{code,label}, unit:{code,label},
  unitPrice, quantityAvailable, expiresAt|null, zone:{id,name,city}, images:[string (URL relative)],
  qualityGrade:'A'|'B'|'C'|null }
```
`GET /catalog/listings?categoryId&zoneId&q&sort=price|expiry&page&limit` (`productId` est ignoré).
Vue **staff** [code : `listingToStaffDto`] : `{id, reference, title, description, unitPrice, status:'DRAFT'|'ACTIVE'|'SOLD'|'INACTIVE',
publishedAt, product:{id,name,category,unit}, zone:{id,name}, images:[{url,position,isPrimary}], lot:StaffLot|null, createdAt, updatedAt…}`.
Création `POST /staff/listings` multipart : `images` (1–5, **requis**), `lotIds` (UN seul au MVP), `title`(3–140),
`unitPrice?`, `zoneId?`, `description?`.

### 4.4 Commande (devis) [code : `order.dto.js`] — ⚠ la spec OpenAPI (`Order`) est FAUSSE sur cette forme
Vue acheteur :
```
{ id, orderNumber, status, deliveryMode:'HUB_PICKUP'|'AGENCY_DELIVERY'|null,
  items:[{id,listingId,listingReference,listingTitle,quantity,unitPrice,lineTotal}],
  subtotal, buyerFee, deliveryFee, total,
  delivery:{zoneId,address,latitude,longitude}|null, pickup:{id,name,address,city}|null,
  notes|null, reservedUntil|null, confirmedAt|null, completedAt|null, cancelledAt|null,
  cancellationReason|null, createdAt }
status ∈ QUOTED | CONFIRMED | PREPARING | READY_FOR_PICKUP | OUT_FOR_DELIVERY | COMPLETED | CANCELLED
```
Vue staff = + `items[].{lotId,supplierUnitPrice,commissionRate,commissionAmount,supplierNetAmount}`, `commissionTotal`,
`origins[{type,hubId,hubName,address,latitude,longitude,distanceKm,agencyCost,deliveryFee}]`,
`buyer:{id,firstname,lastname}`, `handledByAgentId`, `conversationId`, `paymentStatus:'UNPAID'|'PARTIALLY_PAID'|'PAID'|'REFUNDED'`.
Création du devis **par le staff** (`POST /staff/orders`) : `buyerId, items:[{listingId,quantity,unitPrice?}], deliveryMode`,
`pickupHubId` (HUB_PICKUP) **ou** `delivery:{zoneId,address,latitude,longitude}` (AGENCY_DELIVERY),
`conversationId?, notes?, force?`. `reservedUntil` = échéance du devis (un job libère la réservation après) → **compte à rebours**.
`POST /orders/{id}/confirm` exige un profil `VERIFIED`. **Jamais de calcul de frais/commission/total côté client.**

### 4.5 Livraison
Livreur [code : `deliveryToDriverDto`] — jamais de prix :
```
{ id, status, pickupAddress, pickupLatitude, pickupLongitude, dropoffAddress, dropoffLatitude, dropoffLongitude,
  distanceKm, buyer:{firstname,lastname,phone}|null, items:[{productName,categoryName,quantity}],
  acceptedAt, pickedUpAt, deliveredAt, failureReason }
status ∈ PENDING | ACCEPTED | PICKED_UP | IN_TRANSIT | DELIVERED | FAILED | CANCELLED
```
Staff [code : `deliveryToStaffDto`] : `{id, orderId, agencyId, agencyName, status, pickupHubId, pickupAddress/Latitude/Longitude,
dropoffAddress/Latitude/Longitude, distanceKm, agencyCost, deliveryFee, insuredValue, insurancePolicyNumber, acceptedAt,
pickedUpAt, deliveredAt, createdAt}`.
`/driver/deliveries/available` et `/mine` sont **paginés**.

### 4.6 Conversations / messages [code : `conversation.dto.js`]
Client : `{id, type:'BUYER_SUPPORT'|'SUPPLIER_SUPPORT', status:'OPEN'|'WAITING_CUSTOMER'|'CLOSED', subject|null, listingId|null,
escalatedAt, escalationReason|null, lastMessageAt, createdAt}`.
Message client : `{id, content, senderLabel, createdAt}` avec
**`senderLabel ∈ 'Vous' | 'Équipe AgriConnect' | 'Assistant AgriConnect (IA)'`** (le 3ᵉ manque dans la spec).
Le client ne voit **jamais** l'identité d'un agent ni d'un autre utilisateur ; `lotId` n'est jamais exposé au client.
Staff : conversation `{id,type,status,subject,listingId,lotId,customer:{id,firstname,lastname},assignedAgentId,
assignedAgent:{id,displayName},escalatedAt,escalationReason,lastMessageAt,createdAt}` ;
message `{id,conversationId,senderType:'CUSTOMER'|'AGENT'|'SYSTEM',senderUserId,senderAgentId,content,isInternal,createdAt}`.
Ouverture : `POST /conversations {listingId? | lotId?, content}` — **BUYER → `listingId`, SUPPLIER → `lotId`** ; envoyer les deux = 400.
Messages : paginés, ordre **ascendant** par `createdAt`. **Pas de compteur « non lu » serveur** : à gérer localement.

### 4.7 Paiement / reversement / indemnisation [doc]
Paiement `{id,orderId,amount,method,status:'PENDING'|'CONFIRMED'|'FAILED'|'REFUNDED',reference,idempotencyKey,paidAt,recordedById,createdAt}` [code].
`POST /staff/orders/{id}/payments` exige l'en-tête **`Idempotency-Key`** (UUID v4 généré à l'ouverture du formulaire, conservé tant que le formulaire n'est pas validé).
Reversement fournisseur (paginé) `{id,orderId,grossAmount,commissionAmount,netAmount,status:'ON_HOLD'|'READY'|'PAID'|'CANCELLED',reference,payoutAccountId,paidAt,createdAt}`.
Indemnisation fournisseur (paginé) `{id,lotId,deliveryId,reason,quantity,amount,status:'PENDING_APPROVAL'|'APPROVED'|'PAID'|'REJECTED',note,reference,paidAt,createdAt}` ;
la vue admin ajoute `supplierId, unitPrice, rate, approved*, paid*, supplier{farmName,…,payoutAccount{… accountNumber EN CLAIR}}` → **ne jamais journaliser ni mettre en cache ces numéros**.
Compte de paiement [code] : `{id, method, provider|null, accountName|null, accountNumberMasked:'••••1234', isDefault, createdAt}`.

### 4.8 Vérification de profil
`POST /auth/me/documents` multipart, champ **`file`** (jpeg/png/webp/**pdf**, 8 Mo max) + `type` ∈ `ID_CARD|BUSINESS_REGISTRATION|FARM_PROOF|OTHER`.
Max 5 documents `PENDING` (409 `TOO_MANY_PENDING_DOCUMENTS`). `GET /auth/me/documents` → tableau `{id,type,status,note,createdAt}` **sans URL**.
Staff (`USER_VERIFICATION` ou ADMIN+) : `GET /admin/verifications` paginé (`status,type,role,userId`),
`GET /admin/verifications/{id}` → `{…, signedUrl}` (lien de 10 min **lié au compte du relecteur**),
`PATCH` `{decision:'APPROVE'|'REJECT', note}` (note obligatoire si REJECT ; 409 si déjà examiné).
`GET /admin/files/{token}` exige **l'en-tête `Authorization` du même relecteur** → afficher la pièce via une requête Dio
authentifiée en octets (`ResponseType.bytes`), **pas** via `Image.network` nu. Ne jamais mettre cette réponse en cache disque.

### 4.9 Stats admin [doc] `GET /admin/stats?from&to`
`{usersByRole, lotsByStatus, ordersByStatus, deliveriesByStatus, stock:{available,reserved,sold,lost}, receivables,
receivablesCount, pendingPayouts, pendingCompensations:{count,amount}, eligibleReferrals:{count,amount}, grossRevenue}`
(les `*ByStatus` sont des maps statut → nombre).

### 4.10 Réglages plateforme [doc] `GET/PATCH /admin/settings` (PATCH = ROOT seul)
`{id, supplierCommissionRate(0–0.5), buyerFeeType:'NONE'|'FIXED'|'PERCENT', buyerFeeValue, transportMarkupRate(0–1),
referralBuyerReward, referralSupplierReward, reservationHours(1–168), expiryCompensationRate(0–1), currency}`.
Les réglages du frontend de démo (`registrationsOpen`, `autoModeration`, `maintenanceMode`, `supportEmail`, `maxUploadMb`) **n'existent pas**.

### 4.11 Parrainage `GET /auth/me/referral` [code spec = code]
`{code, totals:{pending,eligible,paid}, referrals:[{status:'PENDING'|'ELIGIBLE'|'PAID'|'REJECTED', kind:'SUPPLIER'|'BUYER', rewardAmount|null, createdAt, referredFirstname}]}`.

## 5. Machines d'états

- **Lot** : `PENDING_VALIDATION → AVAILABLE | REJECTED` ; `AVAILABLE → RETURNED | WITHDRAWN` ; `FULLY_RESERVED → RETURNED` ; `SOLD_OUT`, `EXPIRED`, `RETURNED`, `REJECTED`, `WITHDRAWN` terminaux.
- **Annonce** : `DRAFT|INACTIVE → ACTIVE` (publish, exige lot `AVAILABLE` avec stock) ; `ACTIVE → INACTIVE` ; `SOLD` posé par le système.
- **Commande** : `QUOTED → CONFIRMED | CANCELLED` ; `CONFIRMED → PREPARING (exige paiement) | CANCELLED` ; `PREPARING → READY_FOR_PICKUP (HUB_PICKUP) | OUT_FOR_DELIVERY (livraison agence, posé par le flux livraison) | CANCELLED` ; `READY_FOR_PICKUP|OUT_FOR_DELIVERY → COMPLETED`.
- **Livraison** : `PENDING → ACCEPTED | CANCELLED` ; `ACCEPTED → PICKED_UP | PENDING (release) | CANCELLED` ; `PICKED_UP → IN_TRANSIT | FAILED` ; `IN_TRANSIT → DELIVERED | FAILED` ; `FAILED → PENDING (redispatch) | CANCELLED`. Le livreur ne peut pas annuler : seulement `FAILED` + `failureReason`.
- **Suggestion IA** : `PENDING → APPROVED (brouillon d'annonce) | EXECUTED (réponse publiée) | REJECTED | FAILED | EXPIRED`.
- Toute transition interdite → **409 `INVALID_STATE_TRANSITION`**.

## 6. Rôles, capacités, accès

Niveaux : SUPPLIER/BUYER/DRIVER = 10, AGENT = 30, ADMIN = 50, ROOT = 100.
**9 capacités agent** : `BUYER_SUPPORT, SUPPLIER_SUPPORT, LISTING_MANAGEMENT, ORDER_PROCESSING, STOCK_VALIDATION, PAYMENT_FOLLOWUP, DISPATCH_COORDINATION, USER_VERIFICATION, DISPUTE_HANDLING`.
ADMIN et ROOT passent toutes les capacités **sans fiche agent** : le client doit leur attribuer l'ensemble des 9 capacités.
Un agent **IA** ne peut jamais avoir `PAYMENT_FOLLOWUP` ; `requireHumanActor` lui interdit paiements, reversements, parrainages, indemnisations, remboursements (403).

| Zone d'API | Qui |
|---|---|
| `/supplier/*` | SUPPLIER (écritures : profil VERIFIED) |
| `/catalog/*` | BUYER, AGENT, ADMIN, ROOT |
| `/orders/*` | BUYER (confirm : profil VERIFIED) |
| `/conversations/*` | tout compte authentifié (côté client) |
| `/driver/*` | DRIVER |
| `/staff/lots*`, `/staff/stock-movements` | STOCK_VALIDATION |
| `/staff/listings*` | LISTING_MANAGEMENT |
| `/staff/conversations*` | BUYER_SUPPORT ou SUPPLIER_SUPPORT (agit sur son type seulement) |
| `/staff/orders*` (hors paiements/livraisons) | ORDER_PROCESSING |
| `/staff/orders/{id}/payments`, `/staff/payments/{id}/refund` | PAYMENT_FOLLOWUP (humain) ; refund = ADMIN humain |
| `/staff/orders/{id}/deliveries`, `/staff/deliveries*` | DISPATCH_COORDINATION |
| `/staff/compensations` | DISPUTE_HANDLING |
| `/admin/verifications*`, `/admin/files/{token}` | USER_VERIFICATION ou ADMIN+ |
| `/staff/ai/*`, `/staff/conversations/{id}/ai-suggest`, `/staff/lots/{id}/ai-listing-draft` | capacité du type de conversation / LISTING_MANAGEMENT ; ADMIN+ passent |
| `/admin/ai/*` | niveau ≥ 50 (ADMIN, ROOT) |
| `/admin/*` (reste) | ADMIN, ROOT ; `PATCH /admin/settings` ROOT seul ; créer un ADMIN : ROOT seul |
| `/reference/*` | SUPPLIER, BUYER, AGENT, ADMIN, ROOT (DRIVER exclu) |

## 7. Temps réel (Socket.io) — **absent de la spec OpenAPI**

Connexion [code] : `io(origin, {auth:{token:<accessToken>}, transports:['websocket']})`. Refus : `connect_error`
(« Authentification requise », « Token invalide », « Ce compte a été suspendu »). Le token du handshake expire
(1 h) : à chaque reconnexion, **relire un access token frais** et rejoindre à nouveau les conversations ouvertes.
Rooms automatiques à la connexion : `user:{id}` ; `staff` (ADMIN, ROOT, AGENT actif) ; `agency:{id}` (livreur).

Client → serveur : `join_conversation(id, ack({ok}))` (attendre l'ack avant d'émettre autre chose) ;
`leave_conversation(id)` ; `send_message({conversationId, content})` — **préférer REST** pour l'envoi, le socket pour la réception.

| Événement serveur → client | Destinataires | Charge utile |
|---|---|---|
| `message:new` | room de la conversation (client) / room `staff` | MessageClient / MessageStaff |
| `conversation:assigned`, `conversation:escalated` | staff | ConversationStaff |
| `delivery:available` | livreurs de l'agence | course disponible |
| `delivery:status` | acheteur concerné + staff | statut de livraison |
| `alert:expiring` | staff | alerte de péremption de lot |
| `ai:suggestion` | staff | `{id, kind, status, conversationId}` (suggestion créée) |
| `ai:suggestion_updated` | staff | `{id, kind, status, conversationId}` → **recharger** via `GET /staff/ai/suggestions/{id}` |
| `session_revoked` | l'utilisateur | `{reason}` → **fermer le socket et déconnecter localement** |
| `error_message` | l'émetteur | `{error}` |

**Pas d'événement de changement de statut de commande** : rafraîchir par REST (pull-to-refresh) et sur `delivery:status`.
**Il n'existe ni endpoint « notifications » ni push** : tout centre de notifications côté app est construit à partir de ces événements.

## 8. Agent IA — le frontend ne parle JAMAIS à Ollama, Gemini ou Claude

Tout passe par le backend (clés API et prompts restent côté serveur). Fournisseurs : `ollama` (local, `granite4.2:3b`), `gemini` (cloud, relais actuel) et `claude` (cloud, prêt, activable par variables d'environnement après le commit backend B2). Le relais automatique entre fournisseurs arrive avec B3. Endpoints [code] :

| Action | Endpoint | Réponse |
|---|---|---|
| Demander une réponse suggérée | `POST /staff/conversations/{id}/ai-suggest` | `202 {suggestionId, status:'PENDING'}` ; 409 `AI_DISABLED`/`AI_NO_AGENT`/`AI_BUSY`/`CONVERSATION_CLOSED` ; 429 `AI_RATE_LIMITED` |
| Demander un brouillon d'annonce | `POST /staff/lots/{id}/ai-listing-draft` | `202` ; mêmes erreurs |
| Lister / lire | `GET /staff/ai/suggestions?status&kind&conversationId&page&limit`, `GET /staff/ai/suggestions/{id}` | paginé / objet |
| Approuver | `POST /staff/ai/suggestions/{id}/approve {editedContent?}` | REPLY → message publié, statut `EXECUTED` ; LISTING_DRAFT → statut `APPROVED` (aucune annonce créée : l'agent copie titre/description dans le formulaire d'annonce) |
| Rejeter | `POST /staff/ai/suggestions/{id}/reject {reason?}` | suggestion `REJECTED` |
| État du moteur | `GET /admin/ai/status` | voir ci-dessous (ADMIN+) |
| Test du moteur | `POST /admin/ai/test {prompt?}` | `{ok, latencyMs, output:{intent,language,confidence,needs_human,reply,reasons,warnings}}` ; 409 `AI_DISABLED` ; 429 ; 502 |

Suggestion : `{id, kind:'REPLY'|'TRIAGE'|'LISTING_DRAFT', status, conversationId|null, lotId|null, agent:{id,displayName}, model,
latencyMs|null, payload|null, error|null, decidedAt|null, executedAt|null, createdAt}`.
`payload` est `null` tant que le modèle génère. Ensuite :
- REPLY : `{intent:'PRODUCT_QUESTION'|'PRICE_QUOTE_REQUEST'|'DELIVERY_QUESTION'|'VERIFICATION_STATUS'|'COMPLAINT'|'OTHER', language:'fr'|'en', confidence:0..1, reply, needsHuman:bool, reasons:string[], warnings:string[]}`
- LISTING_DRAFT : `{listing:{title(≤140), description(≤2000)}}`
`error` contient un code (`AI_UNREACHABLE`, `AI_INVALID_OUTPUT`, `AI_RATE_LIMITED`, `AI_AUTH_FAILED`, `AI_MODEL_MISSING`, `AI_DISABLED`, `EXPIRED_ON_RESTART`).
**Règle de sécurité** : si `payload.needsHuman` est vrai ou si `warnings` n'est pas vide, afficher un avertissement visible avant d'activer « Envoyer ».

`GET /admin/ai/status` : `{enabled, provider:'ollama'|'gemini'|'claude', baseUrl|null, model, reachable, modelInstalled, authenticated|null,
capabilities:string[], lastLatencyMs|null, queue:{pending,running}, autonomousEnabled, quota:{maxRpm,dailyBudget,usedToday,resetsAt}|null, fallback:{provider,model,afterMs,available}|null}` (`quota` vérifié dans `ai.throttle.js` ; `fallback` arrive avec B3).

Fiche agent IA : `POST /admin/agents/ai {displayName, aiProvider, aiModel, aiConfig?, autonomy?}` ; `PATCH /admin/agents/{id}`
`{displayName?, isActive?, capabilities? (REMPLACE toutes), autonomy?}` — **`aiProvider` et `aiModel` ne sont pas modifiables** après création.

## 9. Écarts spec ↔ code à connaître (corrigés par ce document)

| # | Constat | Vérifié |
|---|---|---|
| D1 | Schéma `Order` de la spec (`reference`, `totalPrice`, `items[].lotId` pour l'acheteur) ≠ DTO réel (§4.4) | [code] |
| D2 | `Message.senderLabel` : la spec omet `'Assistant AgriConnect (IA)'` | [code] |
| D3 | `$ref: AdminUser` pointe vers un schéma inexistant (erreur d'indentation dans `Agent.user.properties`) → casse les générateurs de client | [code] |
| D4 | `PATCH /auth/me` : `email` accepté (non documenté), `latitude/longitude` ignorés | [code] |
| D5 | Les événements Socket.io (dont `ai:suggestion`, `ai:suggestion_updated`) ne figurent pas dans la spec | [code] |
| D6 | `Paginated.items` est typé `object` pour lots, annonces, commandes, paiements, reversements, audit… : les formes réelles sont dans ce document | [code]/[doc] |
| D7 | `docs/API_REALITY.md` (backend) est partiellement périmé : annonce 133 routes (il y en a 146) et « aucun runtime IA » (le runtime existe depuis `7581f2b`) | [code] |
| D8 | L'agent IA de démo est figé sur `aiProvider:'ollama'` : `AI_PROVIDER=gemini` dans `.env` n'affecte que `GET /admin/ai/status` et `/admin/ai/test`, **pas** la génération des suggestions | [code] |

## 10. Manques du contrat (assumés par la conception — ne pas « corriger » côté client)

- Aucun endpoint de commandes côté fournisseur (le fournisseur ne voit jamais l'acheteur).
- Aucun panier / checkout : le **staff émet un devis**, l'acheteur le confirme ou l'annule.
- Aucun paiement côté acheteur : paiements saisis manuellement par le staff.
- Aucune livraison côté acheteur : il reçoit `delivery:status` par socket et le statut de commande.
- Aucune assignation de livreur par le staff : dispatch en **pull** (le livreur accepte une course disponible).
- Aucun compteur de messages non lus côté serveur.
