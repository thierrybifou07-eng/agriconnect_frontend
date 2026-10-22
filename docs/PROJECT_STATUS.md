# AgriConnect — Document central de suivi et de transmission

> **Ce document est la source de vérité de l'avancement du projet.**
> Tout assistant IA intervenant sur AgriConnect doit le lire **avant** de commencer
> toute nouvelle tâche, puis vérifier l'état réel du code et de Git (les chiffres
> ci-dessous sont datés et peuvent être périmés).
>
> **Dernière mise à jour : 2026-10-21** — audit de reprise, création de ce document, puis
> **push vérifié** des commits de documentation sur `origin/master` (cf. § 11.1 et § 11.2).
> **Prochaine étape prioritaire :** reprendre la refonte UI/UX sur **Buyer** (ordre : Buyer → Supplier → Driver → Agent → Admin → Root/Super-admin).

---

## Légende des statuts

| Statut | Signification |
|---|---|
| **TERMINÉ ET VÉRIFIÉ** | Réalisé, et le résultat est étayé par du code, des tests ou un commit **et** a été vérifié (tests + analyse + contrôle visuel si possible). |
| **PARTIELLEMENT TERMINÉ** | Une partie est réalisée et prouvée ; il reste du travail identifiable. |
| **À FAIRE** | Non réalisé, ou non repris dans la vague en cours. |
| **À CONFIRMER** | L'information est incohérente, absente ou non vérifiable en l'état ; quelqu'un doit trancher. |

> ⚠️ Un dashboard n'est **jamais** déclaré visuellement terminé au seul motif que ses tests
> automatisés passent. Les tests prouvent des invariants, pas un rendu.

---

## 1. Présentation du projet

### 1.1 Objetif

AgriConnect est une application Flutter de **gestion agricole et de mise en relation
entre acheteurs et fournisseurs**. Elle couvre six espaces de travail (rôles) :
**Buyer** (acheteur), **Supplier** (fournisseur/agriculteur), **Driver** (chauffeur),
**Agent** (agent de terrain), **Admin** (administrateur) et **Root/Super-admin**
(console plateforme).

Le backend est **développé séparément par un camarade**. Le travail côté assistant porte
actuellement sur le **frontend** (refonte visuelle et responsive des six dashboards),
**avant** toute intégration backend.

### 1.2 Technologies (vérifiées dans `pubspec.yaml`)

| Élément | Valeur |
|---|---|
| SDK Dart | `^3.12.2` (installé : 3.12.2 stable, windows_x64) |
| State management | `flutter_riverpod: ^3.4.3` |
| Navigation | `go_router: ^18.0.1` (résolu : 18.0.1) |
| HTTP | `dio: ^5.11.1` — **déclaré mais jamais importé** (voir § 5) |
| Persistance | `shared_preferences: ^2.5.5` |
| Images | `image_picker: ^1.1.2` |
| Localisation | `flutter_localizations` + `intl`, ARB `fr` / `en` |
| Lints | `flutter_lints: ^6.0.0` |

### 1.3 Architecture (feature-first, en couches)

```
lib/
├── app/            app.dart, router/ (app_router.dart, redirect_policy.dart), theme/
├── core/           constants/, errors/, localization/, media/, network/ (VIDE), storage/, utils/
├── features/<rôle>/
│   ├── domain/         modèles, interfaces de dépôt, règles métier pures
│   ├── application/    contrôleurs Riverpod (état, cas d'usage)
│   ├── data/           implémentations Demo*Repository (en mémoire)
│   └── presentation/   pages/, widgets/, extensions/
└── shared/        loaders/, widgets/ (design system transverse)
```

Rôles de l'application : `buyer`, `supplier`, `driver`, `agent`, `admin`, `onboarding`,
`chat`, `notifications`, `auth`.

### 1.4 Conventions confirmées

- **Rôles** : `UserRole` (`lib/features/auth/domain/user_role.dart`) est l'unique source
  de vérité. Les six rôles : `buyer`, `supplier`, `driver`, `agent`, `admin`, `root`.
  `farmer` → `supplier` et `superAdmin` → `root` sont mappés pour les sessions V1 persistées.
- **Sections de navigation** : `RoleSection` (`lib/core/constants/role_section.dart`),
  source canonique des identifiants de section, partagées par le routeur et les coquilles de rôle.
- **Capacités** : `UserCapability` (`lib/features/auth/domain/capability.dart`) —
  `buyerSupport`, `stockValidation`, `orderProcessing`, `paymentFollowup`.
  La **session porte les capacités réellement accordées** ; le rôle ne fournit qu'un
  paquet par défaut (fallback démo). Une section masquée reste re-vérifiée par la page.
- **Garde de navigation** : `RedirectPolicy` (`lib/app/router/redirect_policy.dart`) est une
  **fonction pure** (testable sans routeur) qui concentre 4 couches : AuthGuard, SessionGuard,
  RoleGuard, RedirectPolicy. Le routeur ne garde que les effets de bord.
- **Navigation par rôle** : `StatefulShellRoute.indexedStack` par rôle, une branche par section.
- **Localisation** : ARB dans `lib/core/localization/l10n/`, générés dans
  `lib/core/localization/generated/`. `l10n.yaml` à la racine.
- **Design** : `lib/app/theme/` (`AppColors`, `AppTheme`, `AppTypography`) + design system
  transverse dans `lib/shared/widgets/`.
- **Responsive** : `AppBreakpoints.compactWidth = 360`, `AppBreakpoints.narrowContent = 380`
  (`lib/core/constants/app_constants.dart`), complétés par `MediaQuery` / `LayoutBuilder` /
  `ConstrainedBox(maxWidth: …)` par page.
- **Identité visuelle** : vert et blanc. `AppColors.primary = #2E7D32`,
  `primaryDark = #1B5E20`, `primaryDeep = #123018`, `primarySoft = #DCEBDD`,
  `background = #F7FAF5` (blanc cassé), `surfaceElevated = #FFFFFF`, accent ambre `#FFB300`.

### 1.5 Chemins et pièges d'environnement (IMPORTANT)

Le dépôt est situé à : `D:\␠\Agri_Connect\agri_connect`
où `␠` est un **espace insécable U+00A0**, **pas** une espace normale.

Conséquences vérifiées le 2026-10-21 :

| Problème | Contournement vérifié |
|---|---|
| `flutter analyze` **échoue** : le serveur d'analyse Dart crash (`FormatException: Unexpected end of input`) car le caractère U+00A0 corrompt le flux LSP. | Utiliser `dart analyze` (mêmes diagnostics). Ou travailler depuis une copie sur un chemin sans U+00A0. |
| PowerShell `Set-Location` / `Push-Location` **échoue** sur ce chemin (« object at the specified path … does not exist »). | `cmd /c "cd /d \"D:␠\Agri_Connect\agri_connect\" && …"`, ou `git -C "D:␠\…"`. |
| `flutter pub get` échoue sur un lecteur substitué (`subst R:`) : « Unable to delete file … macos/Flutter/ephemeral/Packages/.packages ». | Lancer `pub get` sur le **chemin réel**. |
| Les outils de fichiers de l'agent (Read/Write/Glob) n'ouvrent pas ce chemin. | Passer par le shell (`Get-Content -LiteralPath`, `Copy-Item -LiteralPath`), ou copier le projet dans un dossier temporaire à chemin normal. |

`subst R:` → `D:\␠\Agri_Connect\agri_connect` est pratique pour `flutter test` / `dart analyze`
(le lecteur substitué a fonctionné pour les deux). À **défaire** en fin de session :
`subst R: /D`.

---

## 2. État Git (vérifié le 2026-10-21)

| Élément | Valeur |
|---|---|
| Dépôt | `https://github.com/kodjohoza-hash/agri-connect.git` (remote `origin`) |
| Branche | `master` (suivi : `origin/master`) |
| **Commit de référence** | **`c692cd9`** — `fix(supplier): count only published products as on sale` (2026-10-19) |
| Alignement remote | `git fetch origin` → **aucun nouveau commit**. `master` == `origin/master` == `c692cd9` au début de la mission. Aucun divergence. **À la fin de la mission de documentation : `master` == `origin/master`** (alignement rétabli par le push vérifié, cf. § 11.1 et § 11.2). |
| Commit de documentation | `b3e2d1c` — `docs: add central project status document` (ajout de `docs/PROJECT_STATUS.md`) — **pousé et vérifié** le 2026-10-21 (`git ls-remote` → `b3e2d1c…`), cf. § 11.1 |
| Index (staged) | **vide** (au début de la mission) |
| Non suivis (untracked) | **aucun** |
| `git diff --check` | **code de sortie 0**, uniquement des avertissements `LF will be replaced by CRLF` (fins de ligne Windows) |

### 2.1 WIP Buyer — modifications locales préexistantes (**résolu le 2026-10-21**)

Ces modifications existaient **avant** la mission de documentation et n'ont **rien à voir**
avec elle. Elles n'ont été ni écrasées ni supprimées. Elles ont été **résolues puis
commitées** le 2026-10-21 (cf. § 11.5 et § 11.6).

| Fichier | Nature |
|---|---|
| `lib/features/buyer/presentation/widgets/catalog_filter_bar.dart` | WIP Buyer : indice visuel de scroll horizontal sur la barre de catégories du catalogue (dégradé + chevron `Icons.chevron_right_rounded`), piloté par un `ScrollController` et recalculé au redimensionnement. |
| `test/buyer_space_test.dart` | WIP Buyer : 3 nouveaux tests (`the dashboard signals when more categories are off-screen`, `the category hint tracks viewport resizing`, `the English buyer dashboard fits a narrow mobile viewport`) + paramétrage `languageCode` de `_pumpBuyer` + ajustement des largeurs testées. |

**État de ce WIP : résolu le 2026-10-21.** Les 3 nouveaux tests passent ;
`test/buyer_space_test.dart` atteint **65 réussis / 0 échec** et la suite complète
**675 réussis / 0 échec** (cf. § 11.5). Le test qui échouait
(`the category hint tracks viewport resizing`) a été **corrigé dans sa prémisse** — le
widget, lui, était correct (diagnostic chiffré en § 11.5).

### 2.2 Historique récent (fenêtre de refonte, 2026-10-07 → 2026-10-19)

```
c692cd9 2026-10-19  fix(supplier): count only published products as on sale
9e6e273 2026-10-19  fix(navigation): stabilize agent tests and root touch targets
3a073e4 2026-10-19  feat(buyer): improve responsive buyer dashboard
99acdcc 2026-10-19  feat: complete role navigation and notifications
c876895 2026-10-19  feat(ui): polish authentication and onboarding experience
1c2b110 2026-10-18  Clarify explicit product publication policy
b316fb4 2026-10-17  fix(buyer): secure publication defaults and add welcome panel
85941ff 2026-10-17  feat(supplier): add declaration workflow with draft vs publication
1a27f85 2026-10-16  feat(supplier): redesign supplier products UI
eaee225 2026-10-16  feat(supplier): redesign supplier dashboard UI
6f527d5 2026-10-16  feat(supplier): improve supplier workspace
b3fbb24 2026-10-16  chore(admin): consolidate admin workspace
8425567 2026-10-13  fix(admin): adapt navigation for mobile screens
d229e35 2026-10-14  feat(admin): add order management workspace
d47affb 2026-10-14  fix(admin): harden delivery workflow
225fdb8 2026-10-14  fix(admin): persist demo repository mutations
ff5fa71 2026-10-14  feat(admin): implement analytics dashboard
c8ac19a 2026-10-14  fix(admin): correct dashboard labels and status consistency
22e1f4e 2026-10-14  feat(agent): redesign responsive agent workspace
70c25f9 2026-10-11  feat(ui): implement shared AgriConnect design system
3bca8c6 2026-10-11  fix(v2): harden session storage persistence and restore cleanup
b9ef591 2026-10-09  feat(v2): centralized authN/authZ policy - guards, not-found page, capability invariants
0d2500b 2026-10-09  chore(git): secure pre-existing work before PHASE 2 - super_admin console wiring, admin rework, farmer navigation and accessibility fixes, mobile audits, l10n console keys
19c89b4 2026-10-07  chore(git): secure pre-existing work before v2 phases - super_admin feature, admin rework, driver/buyer refinements, mobile audits
f79b2e1 2026-10-02  feat(driver): final audit of the driver workspace
```

> **Lecture clé de cet historique :** la vague de refonte du 14–19 octobre a touché
> **supplier, buyer, agent, admin**. Elle **n'a pas touché `driver`** (dernier commit
> dédié : 2026-10-02) ni **`super_admin`** (dernier commit : 2026-10-19, mais limité à la
> navigation et aux cibles tactiles). C'est le fondement de la priorisation du § 8.

---

## 3. État des six dashboards

Légende des statuts : cf. § « Légende des statuts ».
**Aucun dashboard n'est `TERMINÉ ET VÉRIFIÉ` visuellement.** Le 2026-10-21, un contrôle de
**contenu et de géométrie** a été effectué sur le **build web** des six espaces, en viewport
téléphone 390 × 844 (§ 7.5) : cela prouve **ce qui est affiché et ses dimensions réelles**,
**pas** le rendu graphique. Aucun contrôle sur **appareil réel ou émulateur Android** n'a
été fait, et les six espaces n'ont pas été revus écran par écran (états vide / erreur /
chargement compris).

### 3.1 Buyer — `lib/features/buyer/` — **PARTIELLEMENT TERMINÉ**

| | |
|---|---|
| **Fonctionnalités confirmées** | Dashboard (`buyer_dashboard_page.dart`) ; catalogue (`catalog_page.dart`) avec recherche, filtre par catégorie, grille adaptative ; fiche produit ; panier (`cart_page.dart`) ; checkout (`checkout_page.dart`) ; commandes (`buyer_orders_page.dart`, `order_detail_page.dart`, `order_confirmation_page.dart`) ; messages (réutilise `ChatInboxPage`) ; profil ; panneau de bienvenue persistant (`buyer_welcome_panel.dart`) ; actions rapides (`buyer_quick_actions.dart`) ; suivi de commande (`tracking_timeline.dart`) ; stepper de quantité. |
| **Tests existants** | `test/buyer_space_test.dart` → **62 exécutions** à HEAD. Couverture transversale : audits mobiles, `access_policy_test.dart`, `notifications_test.dart`. |
| **Améliorations visuelles réellement réalisées** | `3a073e4` « feat(buyer): improve responsive buyer dashboard » (2026-10-19) ; `b316fb4` « fix(buyer): secure publication defaults and add welcome panel » (2026-10-17) ; `c876895` « feat(ui): polish authentication and onboarding experience » (2026-10-19) ; `19c89b4` « driver/buyer refinements » (2026-10-07). Mécanismes : `maxWidth 720` sur le dashboard, `LayoutBuilder` 4/3/2 colonnes sur le catalogue (seuils 960/640), actions rapides 4→2 colonnes sous 360 px, barre de catégories scrollable. |
| **Travail restant** | Le WIP de la barre de catégories (§ 2.1) est **résolu et commité** (2026-10-21, § 11.5). Reste la **relecture visuelle** : aucune depuis le 2026-10-19, et l'indice de scroll des catégories n'a pas été contrôlé sur écran (anomalie A6, § 7.7). |
| **Statut refonte UI/UX** | **PARTIELLEMENT TERMINÉ** |

### 3.2 Supplier — `lib/features/supplier/` — **PARTIELLEMENT TERMINÉ**

| | |
|---|---|
| **Fonctionnalités confirmées** | Dashboard (`supplier_dashboard_page.dart`) avec métriques réelles et actions rapides ; gestion produits (`supplier_products_page.dart`, `supplier_product_detail_page.dart` en lecture seule, `supplier_product_form_page.dart`) avec photos ; commandes (`supplier_orders_page.dart`, `supplier_order_detail_page.dart`) ; profil ; **workflow de déclaration** draft → pendingReview → … → approvedForPublication ; **métrique « Produits actuellement en vente » = produits publiés ET en stock** (`c692cd9`). |
| **Tests existants** | `test/supplier_space_test.dart` → **51 exécutions** ; `test/product_publication_policy_test.dart` → **4 exécutions** (politique de publication). |
| **Améliorations visuelles réellement réalisées** | `eaee225` « redesign supplier dashboard UI », `1a27f85` « redesign supplier products UI », `6f527d5` « improve supplier workspace » (2026-10-16) ; `85941ff` « add declaration workflow with draft vs publication » (2026-10-17) ; `c692cd9` (2026-10-19). Mécanismes : `maxWidth 1080`, hauteur de tuile ajustée au `textScaler`, reflow testé 320 px → desktop. |
| **Travail restant** | Aucun écran de validation côté fournisseur : l'approbation/rejet n'existe que comme **état de démonstration**, sans interface pour statuer. Aucune validation visuelle sur appareil réel. |
| **Statut refonte UI/UX** | **PARTIELLEMENT TERMINÉ** (le plus avancé des six) |

### 3.3 Driver — `lib/features/driver/` — **À FAIRE**

| | |
|---|---|
| **Fonctionnalités confirmées** | Dashboard (`driver_dashboard_page.dart`) ; livraisons (`driver_deliveries_page.dart`, `driver_delivery_detail_page.dart`) ; trajets (`driver_trips_page.dart`) ; profil ; barre d'action de livraison (`delivery_summary.dart`) ; progression (`delivery_progress.dart`) ; sections de livraison (`delivery_sections.dart`) ; hero (`driver_hero.dart`). |
| **Tests existants** | `test/driver_space_test.dart` → **11** ; `test/driver_lists_test.dart` → **11** ; `test/driver_delivery_detail_test.dart` → **10**. |
| **Améliorations visuelles réellement réalisées** | `f79b2e1` « feat(driver): final audit of the driver workspace » (2026-10-02) ; `19c89b4` « driver/buyer refinements » (2026-10-07). **Aucune refonte dans la vague du 14–19 octobre**, contrairement à buyer/supplier/agent/admin. Mécanismes : `DriverContent.maxContentWidth = 720`, appliqué dans 8 fichiers. |
| **Travail restant** | **Reprendre la refonte visuelle/responsive du dashboard Driver** : c'est le seul des six espaces sans refonte récente. Vérifier aussi la cohérence avec le nouveau design system (`70c25f9`, 2026-10-11). |
| **Statut refonte UI/UX** | **À FAIRE** |

### 3.4 Agent — `lib/features/agent/` — **PARTIELLEMENT TERMINÉ**

| | |
|---|---|
| **Fonctionnalités confirmées** | Dashboard (`agent_dashboard_page.dart`) ; 4 files métier : support acheteurs (`agent_support_page.dart`), validation de stock (`agent_stock_page.dart`), traitement des commandes (`agent_orders_page.dart`), suivi des paiements (`agent_payments_page.dart`) ; `AgentCapabilityGate` (contrôle fin des actions) ; profil. |
| **Tests existants** | `test/agent_space_test.dart` → **17 exécutions**. **Pas de `agent_repository_test.dart`** (contrairement à `admin_repository_test.dart`) : le dépôt de démonstration de l'agent n'est pas testé isolément. |
| **Améliorations visuelles réellement réalisées** | `22e1f4e` « feat(agent): redesign responsive agent workspace » (2026-10-14) ; `99acdcc` « feat: complete role navigation and notifications » (2026-10-19) ; `9e6e273` « fix(navigation): stabilize agent tests and root touch targets » (2026-10-19). Mécanismes : `AgentContent.maxContentWidth = 720`, `LayoutBuilder` sur `AppBreakpoints.compactWidth`, `agent_case_card` à largeur de badge proportionnelle. |
| **Travail restant** | Aucune validation visuelle sur appareil réel. Ajouter un test de dépôt pour l'agent (parité avec admin). |
| **Statut refonte UI/UX** | **PARTIELLEMENT TERMINÉ** |

### 3.5 Admin — `lib/features/admin/` — **PARTIELLEMENT TERMINÉ**

| | |
|---|---|
| **Fonctionnalités confirmées** | Dashboard (`admin_dashboard_page.dart`) ; modération produits (`admin_products_page.dart`) ; commandes (`admin_orders_page.dart`) ; livraisons (`admin_deliveries_page.dart`) ; utilisateurs (`admin_users_page.dart`) ; analytics (`admin_analytics_page.dart`) ; profil ; extensions de localisation (`admin_*_l10n.dart`). |
| **Tests existants** | `admin_dashboard_test.dart` → **20** ; `admin_repository_test.dart` → **34** ; `admin_localization_test.dart` → **25** ; `admin_orders_test.dart` → **20** ; `admin_analytics_test.dart` → **14** ; `admin_delivery_workflow_test.dart` → **11**. **Total admin ≈ 124 exécutions** (le rôle le plus couvert). |
| **Améliorations visuelles réellement réalisées** | `ff5fa71` « implement analytics dashboard », `d229e35` « add order management workspace », `d47affb` « harden delivery workflow », `225fdb8` « persist demo repository mutations », `c8ac19a` « correct dashboard labels and status consistency » (2026-10-14) ; `8425567` « adapt navigation for mobile screens » (2026-10-13) ; `b3fbb24` « consolidate admin workspace » (2026-10-16). Mécanismes : `maxWidth 1080`, `LayoutBuilder` seuils 760 / 900. |
| **Travail restant** | Aucune validation visuelle sur appareil réel. |
| **Statut refonte UI/UX** | **PARTIELLEMENT TERMINÉ** |

### 3.6 Root / Super-admin — `lib/features/super_admin/` — **PARTIELLEMENT TERMINÉ**

| | |
|---|---|
| **Fonctionnalités confirmées** | Dashboard (`super_admin_dashboard_page.dart`) ; annuaire du personnel (`super_admin_staff_page.dart`) + feuille de permissions (`staff_permissions_sheet.dart`) ; console plateforme / réglages (`super_admin_platform_page.dart`) ; analytics (`super_admin_analytics_page.dart`) ; profil ; journal d'activité (`super_admin_activity_card.dart`). |
| **Tests existants** | `test/super_admin_space_test.dart` → **45 exécutions** (2e fichier le plus lourd). |
| **Améliorations visuelles réellement réalisées** | `0d2500b` « super_admin console wiring, … mobile audits, l10n console keys » (2026-10-09) ; `9e6e273` « fix(navigation): stabilize agent tests and root touch targets » (2026-10-19). **Pas de refonte visuelle dédiée** dans la vague récente : uniquement navigation, cibles tactiles et libellés. Mécanismes : `maxWidth` 1080 / 900 / 760 / 560 / 380, `LayoutBuilder` seuils 760 / 860. |
| **Travail restant** | Refonte visuelle de la console Root à faire (elle a été câblée, pas redessinée). Aucune validation visuelle sur appareil réel. |
| **Statut refonte UI/UX** | **PARTIELLEMENT TERMINÉ** |

> **Note de nommage (source de confusion) :** la route est `/root`, le rôle est `UserRole.root`,
> mais le dossier de feature est `super_admin` et l'interface affiche « Super Admin ».
> `UserRole.fromName` mappe `'superAdmin'` → `root` pour la rétro-compatibilité V1.

### 3.7 Sections et onglets par espace (extrait de `app_router.dart`)

| Espace | Sections (onglets) |
|---|---|
| Supplier | dashboard, products, orders, profile |
| Buyer | dashboard, catalog, orders, profile |
| Driver | dashboard, deliveries, trips, profile |
| Agent | dashboard, buyerSupport, stockValidation, orderProcessing, paymentFollowup, profile |
| Admin | dashboard, products, orders, users, deliveries, analytics, profile |
| Root | dashboard, users, platform, analytics, profile |

**Toutes** les sections sont mappées vers une page réelle dans `_sectionPage()`.
`UnderConstructionPage` n'est qu'un **filet de sécurité** (jamais atteint à HEAD).

**Libellé de navigation :** la section `dashboard` s'appelle **« Accueil » / « Home »**
dans les surfaces de navigation (barre basse, sidebar staff, feuille « Plus ») ; son
**titre de page** reste « Tableau de bord » / « Dashboard » (`sectionDashboard`).
Cf. § 11.3.

---

## 4. Fonctionnalités déjà terminées

Éléments **étayés** par du code, des tests ou un commit. Statut : `TERMINÉ ET VÉRIFIÉ`
pour la logique métier couverte par des tests ; l'aspect visuel reste traité en § 3.

| Fonctionnalité | Preuve |
|---|---|
| Authentification, session persistée, restauration au lancement, expiration de session | `lib/core/storage/session_storage.dart`, `test/auth_session_test.dart` (11), `test/widget_test.dart` (16) |
| Garde de rôle centralisée et déterministe (`RedirectPolicy`, fonction pure) | `lib/app/router/redirect_policy.dart`, `test/access_policy_test.dart` (32) |
| Autorisation fine par capacité portée par la session (4 capacités opérationnelles) | `lib/features/auth/domain/capability.dart`, `test/v2_role_foundation_test.dart` (13), `test/user_role_test.dart` (6) |
| Onboarding / parcours d'accueil FR+EN | `lib/features/onboarding/`, `test/welcome_responsive_presentation_test.dart` (10) |
| Design system transverse (thème, couleurs, typographie, widgets partagés) | `lib/app/theme/`, `lib/shared/widgets/`, commit `70c25f9` |
| **Politique de publication des produits** (approbation ≠ publication) | `lib/features/supplier/domain/product.dart`, `test/product_publication_policy_test.dart` (4) |
| Workflow de déclaration fournisseur (brouillon → revue) | commit `85941ff`, `test/supplier_space_test.dart` (51) |
| Métrique « Produits actuellement en vente » = publiés + en stock | commit `c692cd9`, test `dashboard sale metric counts only published in-stock products in FR and EN` |
| Panneaux de bienvenue Buyer et Supplier, mémorisation du dismissal | `buyer_welcome_storage.dart`, `supplier_welcome_storage.dart`, tests dédiés |
| Navigation par rôle complète + centre de notifications | commit `99acdcc`, `test/notifications_test.dart` (22) |
| Libellé de navigation « Accueil » / « Home » pour la section dashboard (six espaces) | `lib/core/localization/locale_x.dart` (`RoleSectionNavLabelX.navLabel`), `lib/shared/widgets/role_shell.dart` (barre basse, sidebar staff, feuille « Plus »), clé `navHome` ; 15 tests dans `test/role_shell_responsive_navigation_test.dart` — cf. § 11.3 |
| Persistance des mutations du dépôt de démonstration Admin | commit `225fdb8`, `test/admin_repository_test.dart` (34) |
| Localisation FR/EN de l'espace Admin | `test/admin_localization_test.dart` (25) |
| Refonte UI de l'authentification et de l'onboarding | commit `c876895`, `test/auth_responsive_presentation_test.dart` (11) |
| 5 audits mobiles dédiés (mise en page, global, secondaire, navigation, clavier) | `test/mobile_*_audit_test.dart` — 38 + 41 + 18 + 18 + 37 exécutions |

---

## 5. État backend

### 5.1 Ce qui est connecté au backend

**Rien.** Vérifié le 2026-10-21 :

- `lib/core/network/` est un **dossier vide** (aucun fichier).
- `dio: ^5.11.1` est déclaré dans `pubspec.yaml` mais **n'est importé nulle part** dans
  `lib/` ni dans `test/` (recherche `package:dio` / `package:http` → 0 occurrence).
- `ApiConfig` (`lib/core/constants/app_constants.dart`) — `baseUrl`, `connectTimeout`,
  `receiveTimeout` — est du **code mort**, non référencé.

### 5.2 Ce qui reste en démonstration

Les **9 dépôts** sont des implémentations `Demo*Repository` en mémoire, à seeds codés en dur,
avec latence simulée (9 fichiers `demo_*_repository.dart` sous `lib/features/*/data/`) :

| Espace | Dépôt | Fichier |
|---|---|---|
| Auth | `DemoAuthRepository` | `lib/features/auth/data/demo_auth_repository.dart` |
| Buyer | `DemoBuyerRepository` | `lib/features/buyer/data/demo_buyer_repository.dart` |
| Supplier | `DemoSupplierRepository` | `lib/features/supplier/data/demo_supplier_repository.dart` |
| Driver | `DemoDriverRepository` | `lib/features/driver/data/demo_driver_repository.dart` |
| Agent | `DemoAgentRepository` | `lib/features/agent/data/demo_agent_repository.dart` |
| Admin | `DemoAdminRepository` | `lib/features/admin/data/demo_admin_repository.dart` |
| Super Admin | `DemoSuperAdminRepository` | `lib/features/super_admin/data/demo_super_admin_repository.dart` |
| Chat | `DemoChatRepository` | `lib/features/chat/data/demo_chat_repository.dart` |
| Notifications | `DemoNotificationsRepository` | `lib/features/notifications/data/demo_notifications_repository.dart` |

Les doublures de test (`test/support/fakes.dart`) portent les mêmes noms en `Fake*` :
`FakeBuyerRepository`, `FakeSupplierRepository`, `FakeDriverRepository`,
`FakeAdminRepository`, `FakeSuperAdminRepository`, `FakeAgentRepository`, `FakePhotoPicker`.

### 5.3 Persistance

Uniquement `shared_preferences` : session (`auth_user_v1`, `auth_token_v1`,
`auth_token_expires_at_v1`), onboarding (`welcome_onboarding_completed_v1`,
`welcome_language_code_v1`, `welcome_selected_role_v1`), panneaux de bienvenue
(`buyer_welcome_seen_v1`, `supplier_welcome_seen_v1`).
**Les données métier (produits, commandes, livraisons, personnel, réglages plateforme) ne sont
pas persistées** : elles sont perdues au redémarrage de l'application.

**Persistence vérifiée le 2026-10-21** (build web, rechargement complet de la page) : la
session, l'indicateur d'onboarding, la **langue** et le rôle sont bien **écrits puis
relus** — l'app redémarre directement sur le dashboard Buyer, dans la langue choisie
(§ 7.6). Un nom de rôle invalide, en revanche, annule toute la restauration (faiblesse
documentée au § 7.6).

### 5.4 Inconnues (à confirmer avec le camarade backend)

- Contrat d'API : URL de base réelle, versionnement, format des enveloppes de réponse.
- Authentification réelle : format du jeton, source des capacités accordées au compte.
  Le code porte déjà l'avertissement `BACKEND → CONFIRMER` dans `capability.dart` :
  *« the production sign-in payload must return the capabilities granted to the account
  itself; this table only mirrors the demo roles and must never become the authority in
  production. »*
- Sémantique serveur des transitions de statut d'un produit (qui décide de publier ?).
- Gestion des erreurs réseau et reprise (l'UI gère déjà des états d'erreur/retry en démo).
- Upload des photos : `image_picker` produit des `PreparedPhoto` « prepared for a future
  upload » ; la cible (Cloudinary ou autre) n'est pas décidée — `Product.imageUrl` accepte
  déjà une URL `https://` Cloudinary.

---

## 6. Règles métier critiques

**Ces règles ne doivent jamais être relâchées pendant la refonte visuelle.**
Elles sont codées dans `lib/features/supplier/domain/product.dart` et verrouillées par
`test/product_publication_policy_test.dart`.

1. **Une déclaration n'est pas une publication.**
   `Product` est le modèle **interne** du workspace fournisseur. Le catalogue acheteur est
   alimenté par **une source de données distincte** et ne lit jamais une déclaration
   directement.
2. **« Approuvé pour publication » ≠ « Publié ».**
   `DeclarationStatus.approvedForPublication` ne rend rien public.
3. **Publication = approbation ET statut de publication explicite.**
   ```dart
   bool get isPublished =>
       declaration.isApprovedForPublication &&
       publicationStatus == ProductPublicationStatus.published;
   ```
4. **Un produit sans drapeau explicite n'est jamais affiché.**
   `publicationStatus` vaut `unpublished` par défaut : un produit ne devient public que par
   une décision humaine/explicite. Verrouillé par le test
   « a product with no explicit publication flag is never shown » (commit `b316fb4`).
5. **Rejeté / suspendu / archivé ⇒ invisible du catalogue public.**
   `DeclarationStatus.rejected` et `ProductPublicationStatus.suspended` / `archived` ne
   peuvent pas être publiés.
6. **Le fournisseur ne publie jamais seul.**
   Sa déclaration suit `draft → pendingReview → additionalInfoRequired | underDiscussion →
   approvedForPublication | rejected`. La publication est ensuite **une décision distincte**.
7. **« Produits actuellement en vente » = produits publiés ET en stock.**
   Corrigé par `c692cd9` : un produit approuvé mais non publié, ou publié mais en rupture,
   ne compte pas.
8. **Rôles, routes et permissions sont à préserver.**
   Les 6 `UserRole`, les `RoutePaths`, les `RoleSection` et les `UserCapability` sont le
   contrat de la plateforme. Une refonte visuelle ne doit ni les renommer, ni les contourner.
9. **La capacité portée par la session est autoritaire.**
   Le paquet par défaut du rôle n'est qu'un fallback démo ; il ne doit jamais ré-accorder
   implicitement une autorisation à une session restaurée.
10. **Aucune action de l'UI ne doit simuler une réussite.**
    Les écrans d'erreur/retry existent déjà dans les six espaces : les conserver.

---

## 7. Résultats de validation

### 7.1 Commit de référence `c692cd9` (arbre propre, copie isolée)

Vérifié le **2026-10-21** sur une extraction propre de HEAD (`git archive HEAD` vers un
dossier temporaire à chemin normal, sans toucher l'arbre de travail) :

| Vérification | Commande | Résultat |
|---|---|---|
| Suite complète | `flutter test` | **654 réussis / 0 échec / 0 ignoré** (~13 min) |
| Analyse statique | `dart analyze` | **1 seule issue**, de niveau `info` : `unnecessary_lambdas` — `test/admin_repository_test.dart:68:28`. **0 erreur, 0 avertissement.** |
| Espaces de travail (6 fichiers ciblés) | `flutter test test/buyer_space_test.dart test/supplier_space_test.dart test/driver_space_test.dart test/agent_space_test.dart test/admin_dashboard_test.dart test/super_admin_space_test.dart` | **206 réussis / 0 échec** |
| Espace Buyer ciblé | `flutter test test/buyer_space_test.dart` | **62 réussis / 0 échec** |
| Intégrité du diff | `git diff --check` | code 0 |

Répartition exacte des 654 exécutions à HEAD :

```
  62  buyer_space_test.dart            25  admin_localization_test.dart
  51  supplier_space_test.dart         23  role_shell_responsive_navigation_test.dart
  45  super_admin_space_test.dart      22  notifications_test.dart
  41  mobile_secondary_audit_test.dart 20  admin_dashboard_test.dart
  38  mobile_global_audit_test.dart    20  admin_orders_test.dart
  37  mobile_keyboard_audit_test.dart  18  mobile_layout_audit_test.dart
  34  admin_repository_test.dart       18  mobile_navigation_audit_test.dart
  32  access_policy_test.dart          17  agent_space_test.dart
                                       16  widget_test.dart
                                       14  admin_analytics_test.dart
                                       13  role_profile_test.dart
                                       13  v2_role_foundation_test.dart
                                       11  admin_delivery_workflow_test.dart
                                       11  auth_responsive_presentation_test.dart
                                       11  auth_session_test.dart
                                       11  driver_lists_test.dart
                                       11  driver_space_test.dart
                                       10  driver_delivery_detail_test.dart
                                       10  welcome_responsive_presentation_test.dart
                                       10  workspace_state_test.dart
                                        6  user_role_test.dart
                                        4  product_publication_policy_test.dart
```

> Ces trois chiffres (654 / 62 / 206) **confirment** l'audit historique rapporté :
> ils ont été recalculés de façon indépendante le 2026-10-21.

### 7.2 Arbre de travail (WIP Buyer résolu le 2026-10-21)

Vérifié le **2026-10-21**, après résolution du WIP Buyer :

| Vérification | Résultat |
|---|---|
| `flutter test` (suite complète) | **675 réussis / 0 échec** |
| `test/buyer_space_test.dart` | **65 réussis / 0 échec** |
| `dart analyze` | **identique à HEAD** : 1 seule info (`unnecessary_lambdas`, `test/admin_repository_test.dart:68:28`), 0 erreur |
| `git diff --check` | code **0** |

> **Échec résolu, pour mémoire :** avant correction,
> `the category hint tracks viewport resizing` échouait (`Expected: no matching
> candidates`). Le diagnostic (§ 11.5) a montré que le **widget était correct** et que la
> **prémisse du test était fausse** : le dashboard plafonne la barre de filtres à 720 px,
> donc les catégories débordent à **toutes** les largeurs. Le test a été corrigé dans sa
> prémisse (et non affaibli) ; le widget n'a pas été modifié.

### 7.3 Vérifications Git

| Vérification | Résultat (2026-10-21) |
|---|---|
| `git status` | 2 fichiers modifiés non indexés, 0 indexé, 0 non suivi, 0 fichier supprimé |
| `git diff --check` | code 0 — uniquement des avertissements de fin de ligne `LF → CRLF` |
| `git fetch origin` | aucun nouveau commit ; `master` == `origin/master` == `c692cd9` — **état mesuré avant le push de documentation** (état final et vérifié : § 11.1) |
| Historique | aucun `rebase`/`reset`/`force-push` ; commits linéaires |

### 7.4 Vérifications visuelles — **LIMITES À CONNAÎTRE**

- **Historiquement** (audit rapporté du 2026-10-19) : *aucun rendu visuel réel sur
  émulateur Android ni navigateur n'avait été réalisé*. Les dashboards n'ont donc été validés
  que par des assertions automatisées.
- **2026-10-21 (cette mission)** : un contrôle **de contenu et de géométrie** a été effectué
  sur le **build web** de l'arbre de travail, au format téléphone (390 × 844), sur les six
  espaces, en FR et partiellement en EN. **Ce n'est pas une revue de capture d'écran** et
  **ce n'est pas un rendu Android** : voir § 7.5 pour le détail de la méthode et de ses
  limites.

### 7.5 Contrôle du build web (2026-10-21) — contenu et géométrie

| Élément | Valeur |
|---|---|
| Méthode | `flutter build web --release` depuis l'arbre de travail, servi en HTTP local (`127.0.0.1:8765`), puis rendu dans un navigateur à **390 × 844 px** (format téléphone Android) via un `<iframe>` de 390 × 844 — Flutter lit le viewport de l'iframe. |
| **Ce que la vérification prouve** | Le **contenu réellement affiché** (arbre de sémantique Flutter : libellés, titres, compteurs, onglets) et la **géométrie réelle** (rectangles DOM : largeur, hauteur, position de chaque élément). |
| **Ce qu'elle ne prouve PAS** | Ce n'est **pas** une revue de capture d'écran : l'agent ne peut pas inspecter d'image. **Couleurs, ombres, typographie, espacements fins, animations et rendu Android** ne sont **pas** validés. |
| Portée | Parcours complet (onboarding → langue → rôle → connexion), puis dashboards **Buyer, Supplier, Driver, Agent, Admin, Root** en **FR** ; puis Buyer, catalogue, Driver et connexion en **EN**. |
| Limite | Le rendu web **ne vaut pas** rendu Android : polices, densité, safe areas, clavier virtuel et scrolling natif diffèrent. Un **émulateur Android** reste nécessaire pour valider la priorité « téléphone Android ». |
| Limite | Les données affichées sont celles des dépôts de **démonstration** ; aucun backend n'est joignable. |
| Limite | Vérification **ponctuelle** (2026-10-21) : ni revue exhaustive de chaque écran, ni de chaque état (vide / erreur / chargement). |

#### 7.5.1 Contenus constatés en FR (390 × 844)

| Écran | Contenu constaté |
|---|---|
| Onboarding | 3 diapositives (« Un marché agricole connecté », « Des livraisons de confiance », « Une communauté qui vous connecte »), actions « Passer » et « Suivant » / « Commencer ». |
| Connexion | « Bon retour parmi nous », « Connectez-vous pour accéder à votre espace », champs **e-mail + mot de passe**, « Afficher le mot de passe », « Se connecter », « Changer de rôle », 6 comptes de démonstration (« Comptes de démonstration »), « Pas encore de compte ? ». |
| Choix du rôle | 3 rôles proposés : Fournisseur, Acheteur, Chauffeur — **Agent, Admin et Root ne sont pas sélectionnables à l'inscription** (`UserRole.onboardingRoles`). |
| **Buyer** | « Bonjour, Marie », panneau de bienvenue, **2 colonnes** d'actions rapides, **4 onglets**, 3 tuiles de commande (**3** commandes actives, **2** En transit, **2** Livrées). |
| Buyer — catalogue | Grille **2 colonnes**, barre de catégories scrollable, 12 produits avec « Ajouter au panier ». |
| **Supplier** | Panneau de bienvenue, **3 tuiles** de métriques (« Produits déclarés 10 », « En attente 3 », « Confirmées 2 »). |
| **Driver** | Bandeau d'accueil, actions rapides, **3 pastilles** de statut (À livrer / En transit / Livrées), section « À ramasser », carte de trajet (« Adjamé → Yopougon », « Fourgonnette · CD-456-EF »). |
| **Agent** | **4 cartes** de capacités, navigation basse avec onglet « Plus ». |
| **Admin** | Statistiques en **2 × 2**, navigation basse avec onglet « Plus ». |
| **Root** | **2 tuiles** (« Utilisateurs 10 », « Équipe 4 »), navigation basse avec onglet « Plus ». |

> **Comptes de démonstration** : `{supplier, buyer, driver, agent, admin, root}@agriconnect.app`
> / `demo1234`.
> **Piège vérifié** : appuyer sur un compte de démonstration **pré-remplit l'e-mail mais ne
> change pas le rôle sélectionné** → il faut d'abord passer par « Changer de rôle », sinon
> l'erreur « Cette adresse e-mail n'est pas associée au rôle sélectionné » apparaît.

#### 7.5.2 Contenus constatés en EN (390 × 844)

| Écran | Contenu constaté (anglais) |
|---|---|
| Choix du rôle | « What is your profile? », « Pick the role that matches you to personalize your experience. » |
| Connexion | « Welcome back », « Sign in to access your workspace », « Show password », « Sign in », « Demo accounts — Tap an account to pre-fill the form. » |
| Déconnexion | Dialogue « Sign out — Are you sure you want to sign out? » avec « Cancel / Confirm ». |
| **Buyer** | « Hello, Marie », « The finest produce from the farm, delivered to you. », « Empty cart », « Browse the catalog », « Explore products / My cart / My orders / Messages », « Active orders » = **3**, « 2 In transit », « 2 Delivered ». |
| Buyer — catalogue | 12 × « Add to cart ». |
| **Driver** | « Hello, Ibrahim », « Your routes and deliveries, all in one place. », « 4 ongoing delivery(ies) », « To deliver 2 », « In transit 2 », « Delivered 3 », « To collect », « Adjamé → Yopougon ». |

### 7.6 Locale FR/EN — vérifié le 2026-10-21

**Mécanisme (code)** : `localeProvider`
(`lib/features/onboarding/application/welcome_controller.dart`) lit
`welcomeControllerProvider.state.languageCode` → `Locale(code)` → `MaterialApp.locale`.
La valeur est persistée par `LocalWelcomeStorage` (clé `welcome_language_code_v1`).
Codes supportés : `AppLanguage.supportedCodes = ['fr', 'en']`, défaut `fr`.

| Vérification | Résultat |
|---|---|
| Choix « Anglais » sur la page de langue | **Bascule immédiate de toute l'UI en anglais** (page rôle, connexion, dashboard Buyer, catalogue, dashboard Driver) → **TERMINÉ ET VÉRIFIÉ** |
| Persistance après rechargement complet de la page | **Conservée** : rechargement → `#/buyer/home` toujours en anglais (`flutter.welcome_language_code_v1 = "en"`) → **TERMINÉ ET VÉRIFIÉ** |
| Restauration de l'état d'accueil (onboarding + langue + rôle) | **Fonctionnelle** : avec `welcome_onboarding_completed_v1 = true`, `welcome_language_code_v1 = "en"`, `welcome_selected_role_v1 = "buyer"` → rechargement → `#/login` en anglais, onboarding et page rôle sautés → **TERMINÉ ET VÉRIFIÉ** |
| Session (auth) après rechargement | Restaurée : rechargement → dashboard Buyer directement, sans reconnexion → **TERMINÉ ET VÉRIFIÉ** |
| Rôle enregistré **invalide** | **FAIBLESSE DE ROBUSTESSE** : `UserRole.fromName()` → `UserRole.values.byName()` lève une `ArgumentError` sur un nom inconnu ; `_restore()` l'attrape (`catch (_)`) et **remet à zéro tout l'état d'accueil** → onboarding rejoué **et** langue retombée sur `fr`. Reproduit le 2026-10-21 (rôle stocké = `"buyer"` avec guillemets littéraux) → **À CONFIRMER / à corriger** |

> **Conséquence pratique** : un seul nom de rôle corrompu (renommage de rôle entre deux
> versions, écriture manuelle, jeu de données de test) fait perdre à l'utilisateur son
> onboarding **et** son choix de langue. Correctif suggéré : isoler l'erreur de parsing du
> rôle (`try { UserRole.fromName(name) } catch (_) { null }`) au lieu de la laisser remonter
> au `catch` global de `_restore()`.

### 7.7 Anomalies relevées pendant le contrôle (à confirmer sur appareil)

| # | Anomalie | Mesure | Statut |
|---|---|---|---|
| A1 | Actions de l'AppBar (« Notifications », « Se déconnecter ») **sous le minimum tactile de 48 dp** | rectangle DOM **40 × 40 px**, mesuré sur Buyer et Driver | **À CONFIRMER** — élargir la zone cliquable, pas seulement l'icône |
| A2 | Bouton « Afficher le mot de passe » de la page de connexion sous 48 dp | **40 × 40 px** | **À CONFIRMER** |
| A3 | Chip d'en-tête de section **effondré** sur le dashboard Driver (1ʳᵉ section « À ramasser ») | chip **68,6 × 5 px** alors que les chips équivalents (« En transit », 2ᵉ « À ramasser ») mesurent **24 px** ; la section est à y = 734, juste au-dessus de la navigation basse (y = 764) | **À CONFIRMER** — suspicion : section comprimée par la barre basse ; la géométrie de sémantique peut être influencée par le rognage |
| A4 | Boutons texte « Changer de rôle » / « Pas encore de compte ? » de 32 px de haut | 99,4 × 32 et 139 × 32 | **À CONFIRMER** — les audits mobiles du dépôt ne couvrent pas le web |
| A5 | Agent / Admin / Root regroupent leurs onglets sous un onglet « Plus » | navigation basse : 4 onglets visibles + « Plus » | **INFORMATIONNEL** — choix produit à confirmer |
| A6 | Le hint de scroll des catégories (WIP § 2.1) est enveloppé dans `ExcludeSemantics` | invisible dans l'arbre de sémantique | **À CONFIRMER** — son aspect réel ne peut pas être validé sans un rendu visuel |

> **À CONFIRMER** : la priorité produit étant « téléphone Android d'abord », une campagne de
> validation sur **émulateur Android** reste **à faire** avant de déclarer la refonte terminée.

---

## 8. Prochaine priorité

**Reprendre la refonte UI/UX au premier dashboard non finalisé, dans cet ordre :**
**Buyer → Supplier → Driver → Agent → Admin → Root/Super-admin.**

### 8.1 Étape immédiate — Buyer (**WIP résolu le 2026-10-21**)

Le WIP décrit au § 2.1 a été **terminé et commité** le 2026-10-21 (cf. § 11.5 et § 11.6) :
`test/buyer_space_test.dart` est à **65 réussis / 0 échec** et la suite complète à
**675 réussis / 0 échec**. Le widget n'a pas eu à être modifié : le recalcul de l'indice
lors d'un redimensionnement était déjà correct — c'est la prémisse du test qui était fausse.

Ce qui reste à faire sur Buyer :

1. **Contrôle visuel** sur viewport étroit (320 px) : vérifier que l'indice n'apparaît que
   s'il reste réellement des catégories hors écran — **non réalisé à ce jour** ; l'anomalie
   A6 (§ 7.7) reste **À CONFIRMER**.
2. Revue visuelle complète du dashboard Buyer (aucune depuis le 2026-10-19).
3. *(Annexe, hors périmètre Buyer)* Corriger la robustesse de `_restore()`
   (`lib/features/onboarding/application/welcome_controller.dart`) : un nom de rôle invalide
   ne doit pas annuler l'onboarding **et** la langue de l'utilisateur (cf. § 7.6).

### 8.2 Ordre de la refonte

| Rang | Espace | Statut | Action |
|---|---|---|---|
| 1 | **Buyer** | PARTIELLEMENT TERMINÉ | Terminer le WIP ci-dessus ; puis revue visuelle complète. |
| 2 | **Supplier** | PARTIELLEMENT TERMINÉ | Revue visuelle ; ajouter un écran de validation de déclaration côté fournisseur. |
| 3 | **Driver** | **À FAIRE** | **Refonte visuelle non reprise depuis le 2026-10-02.** Point de départ recommandé. |
| 4 | **Agent** | PARTIELLEMENT TERMINÉ | Revue visuelle ; ajouter `agent_repository_test.dart` (parité admin). |
| 5 | **Admin** | PARTIELLEMENT TERMINÉ | Revue visuelle. |
| 6 | **Root/Super-admin** | PARTIELLEMENT TERMINÉ | Refonte visuelle de la console (câblée mais pas redessinée). |

---

## 9. Plan de travail

### 9.1 Principes

- **Une seule étape fonctionnelle à la fois.** Ne pas mélanger refonte et intégration backend.
- **Preserver l'existant.** Toute modification locale antérieure est sacrée (§ 2.1).
- **Le vert est un prérequis**, pas une finalité : tests **et** contrôle visuel.

### 9.2 Critères d'acceptation (par dashboard)

Un dashboard n'est `TERMINÉ ET VÉRIFIÉ` que si **tous** les points suivants sont satisfaits :

| # | Critère | Vérification |
|---|---|---|
| 1 | Aucun test en échec sur l'espace concerné **et** sur la suite complète | `flutter test` |
| 2 | Analyse statique sans erreur ni avertissement nouveau | `dart analyze` (voir § 1.5 pour `flutter analyze`) |
| 3 | Aucun problème de mise en page ni de débordement aux largeurs 320 / 360 / 390 / 412 / 600 / 900 / 1200 px | audits mobiles existants + nouveaux cas |
| 4 | Aucun débordement ni AppBar empilée à 320 px, et à 1.5× d'échelle de police | `mobile_layout_audit_test.dart`, `mobile_global_audit_test.dart` |
| 5 | Cibles tactiles ≥ 48 dp et contenu scrollable sur chaque onglet | `mobile_secondary_audit_test.dart` |
| 6 | Clavier virtuel : aucun champ masqué sur les formulaires | `mobile_keyboard_audit_test.dart` |
| 7 | **Contrôle de rendu** sur au moins un viewport téléphone, pour chaque écran et chaque état (nominal / vide / erreur / chargement) | émulateur Android ou navigateur — un contrôle par **sémantique + géométrie** suffit à valider la **mise en page** (§ 7.5) mais **ne remplace pas** une revue visuelle sur appareil ; **à ne pas déclarer fait s'il ne l'a pas été** |
| 8 | Rendu en FR **et** EN vérifié (longueurs de texte, troncature) | `admin_localization_test.dart` et équivalent |
| 9 | Règles métier du § 6 intactes | `product_publication_policy_test.dart` + relecture |
| 10 | Routes, rôles et permissions inchangés | `access_policy_test.dart`, `v2_role_foundation_test.dart` |
| 11 | `git diff --check` propre, diff relu ligne à ligne | § 10 |

### 9.3 Tests à effectuer

```bash
# analysing statique (OBLIGATOIRE : utiliser dart analyze, cf. § 1.5)
dart analyze

# suite complète
flutter test

# espace ciblé
flutter test test/buyer_space_test.dart
flutter test test/supplier_space_test.dart
flutter test test/driver_space_test.dart
flutter test test/driver_lists_test.dart
flutter test test/driver_delivery_detail_test.dart
flutter test test/agent_space_test.dart
flutter test test/admin_dashboard_test.dart
flutter test test/admin_repository_test.dart
flutter test test/admin_orders_test.dart
flutter test test/admin_analytics_test.dart
flutter test test/admin_localization_test.dart
flutter test test/admin_delivery_workflow_test.dart
flutter test test/super_admin_space_test.dart

# règles métier à ne jamais casser
flutter test test/product_publication_policy_test.dart
flutter test test/access_policy_test.dart

# audits responsive (tous rôles)
flutter test test/mobile_layout_audit_test.dart
flutter test test/mobile_global_audit_test.dart
flutter test test/mobile_secondary_audit_test.dart
flutter test test/mobile_navigation_audit_test.dart
flutter test test/mobile_keyboard_audit_test.dart
```

> Sur le chemin `D:\␠\…`, passer par `cmd /c "cd /d R:\ && …"` (lecteur substitué) ou par le
> chemin réel ; `flutter analyze` échoue à cet emplacement (§ 1.5).

### 9.4 Validations visuelles

1. **Priorité 1 — Android téléphone.** Émulateur ou appareil réel, largeur 360–412 px.
   C'est la priorité produit déclarée.
2. **Priorité 2 — Tablette** (600–900 px) puis **ordinateur** (≥ 1200 px) : vérifier que la
   largeur de lecture reste bornée et centrée.
3. **Portrait et paysage**, et à 1.3× / 1.5× d'échelle de police.
4. **États à contrôler** : nominal, chargement (skeletons), vide, erreur + retry, et
   « contenu tronqué qui déborde ».
5. Pour chaque écran : FR et EN.
6. **Ne jamais écrire « visuellement validé » sans l'avoir fait.** Si l'environnement ne
   permet pas le rendu, écrire explicitement « contrôle visuel non réalisé » et le laisser
   comme `À FAIRE`/`À CONFIRMER`.

### 9.5 Conditions de fin de la refonte des six dashboards

La refonte est **TERMINÉE** quand :

- les 6 espaces satisfont les 11 critères du § 9.2 ;
- la suite complète est verte (≥ 654 tests à HEAD, + les nouveaux) ;
- `dart analyze` est sans erreur ni avertissement nouveau ;
- un **contrôle visuel réel sur emulator Android** a été effectué pour les 6 espaces, en FR et EN ;
- le § 11 (historique) est à jour ;
- **et seulement ensuite**, l'intégration backend peut être abordée.

---

## 10. Règles Git impératoires

### 10.1 Protéger le travail local

- **Ne jamais** exécuter `git reset --hard`, `git checkout -- .`, `git clean -fd`,
  `git stash drop`, `git rebase` ou `git push --force` sur ce dépôt.
- **Avant toute écriture**, lancer `git status` et **lire** `git diff` en entier.
- Les modifications locales préexistantes (§ 2.1) sont **intouchables** tant qu'elles ne
  sont pas explicitement reprises.
- Ne pas supprimer de fichier sans avoir vérifié qu'il est suivi **et** sans rapport avec la
  tâche en cours.
- `git stash` est à éviter : il déplacerait le travail d'autrui hors de l'arbre visible.

### 10.2 Stage sélectif

- **Toujours** `git add <chemin exact>` — **jamais** `git add .` ni `git add -A`.
- Vérifier `git diff --cached --stat` **avant** de commiter : la liste doit correspondre
  exactement au périmètre annoncé.
- `git diff --cached` doit être relu ligne à ligne.

### 10.3 Commits explicites

- Un commit = une étape fonctionnelle cohérente.
- Message au format déjà en usage dans le dépôt :
  `type(scope): description` — ex. `feat(buyer): improve responsive buyer dashboard`,
  `fix(supplier): count only published products as on sale`.
- Types observés : `feat`, `fix`, `chore`, `docs`.
- Ne jamais commiter un travail en échec ou un test rouge.

### 10.4 Push vérifié

1. `git fetch origin` puis `git log --oneline origin/master -3` et
   `git rev-parse master origin/master` — vérifier l'alignement **avant** de pousser.
2. `git push origin master` — **jamais** `--force`.
3. **Vérifier le résultat réel** de la commande (code de sortie + message), puis
   `git status -sb` et `git log --oneline -1 origin/master`.
4. **Ne jamais déclarer un push réussi sans en avoir vérifié le résultat.**
5. Ne pas pousser si l'arbre de travail contient des modifications étrangères non
   intentionnelles, si l'historique a été réécrit, ou si le push risque d'écraser le
   travail d'autrui (remote avancé, branche distante non fusionnée). Dans ce cas :
   **s'arrêter et expliquer précisément pourquoi.**
   - *Exception encadrée* : une autorisation **explicite** de l'utilisateur peut lever ce
     refus, à condition que (a) le commit poussé ne contienne **aucun** fichier étranger,
     (b) le push soit un **fast-forward** vérifiable (`git merge-base --is-ancestor`),
     (c) les modifications étrangères restent **intactes** (empreintes SHA256 et dates de
     modification inchangées) avant **et** après le push, et (d) le résultat réel du push
     soit contrôlé par `git ls-remote origin refs/heads/master`. C'est ce qui a été fait le
     2026-10-21 pour le commit de documentation, cf. § 11.1.

### 10.5 Points d'attention propres à ce dépôt

- Le chemin contient un U+00A0 : les commandes qui reconstruisent un chemin depuis une
  variable shell peuvent le tronquer silencieusement. **Toujours** utiliser `-LiteralPath`,
  `git -C`, ou `cmd /c "cd /d …"`.
- Les fins de ligne sont en LF dans Git et CRLF en local : `git diff --check` remonte des
  avertissements `LF will be replaced by CRLF`. **Ce ne sont pas des erreurs**, mais il faut
  éviter de normaliser les fins de ligne dans le diff (ça noierait la relecture).
- `build/`, `.dart_tool/`, `*.log` et `/agri connect/` sont ignorés par Git
  (`.gitignore`) : un `flutter build` ou un `flutter test` ne doit pas polluer le diff.
- Le dossier `/agri connect/` est un **ancien dépôt Git imbriqué**, ignoré par Git. Il est
  conservé tel quel : **ne pas le supprimer, ne pas l'ajouter**.

---

## 11. Historique de progression

> Section **datée**, à mettre à jour **après chaque étape réellement terminée** :
> date, espace concerné, ce qui a été fait, **tests**, **analyse**, **contrôle visuel**
> (réel ou non), **commit**, **résultat du push vérifié**.

### 2026-10-21 — Audit de reprise + création du document central

- **Périmètre** : documentation uniquement. **Aucune refonte de dashboard.**
- **Constats** :
  - dépôt `master` sur `c692cd9`, aligné `origin/master`, `git fetch` sans nouveau commit ;
  - **2 fichiers modifiés non commités** (WIP Buyer, § 2.1) — **préservés intacts** ;
  - aucun document d'avancement préexistant (`README.md` = gabarit Flutter par défaut ;
    aucun `STATUS/ROADMAP/HANDOFF/TODO/CHANGELOG` dans le dépôt) → **création** de
    `docs/PROJECT_STATUS.md` ;
  - `lib/core/network/` **vide**, `dio` jamais importé → backend non intégré (confirmé) ;
  - politique de publication confirmée par le code et `product_publication_policy_test.dart`.
- **Tests** : `flutter test` sur HEAD (copie isolée) → **654 réussis / 0 échec** ;
  `flutter test` sur l'arbre de travail → **656 réussis / 1 échec**
  (`the category hint tracks viewport resizing`, test WIP).
- **Analyse** : `dart analyze` → **1 info** (`unnecessary_lambdas`,
  `test/admin_repository_test.dart:68:28`), **0 erreur**, identique à HEAD.
- **Diff** : `git diff --check` → code 0.
- **Contrôle de rendu (build web, 390 × 844)** : parcours onboarding → langue → rôle →
  connexion, puis les **six dashboards** ; **FR** pour les six, **EN** pour Buyer, Driver,
  catalogue et connexion (§ 7.5). Méthode = **arbre de sémantique + géométrie DOM** :
  **contenu et dimensions vérifiés ; rendu graphique non vérifié** (ni capture d'écran,
  ni Android).
- **Locale FR/EN** : bascule EN vérifiée et **persistante** après rechargement ; une
  faiblesse de robustesse a été identifiée dans la restauration du rôle (§ 7.6).
- **Anomalies relevées** : **6 anomalies** de mise en page / cibles tactiles (A1 → A6)
  consignées au § 7.7.
- **Commit** : `b3e2d1c` — `docs: add central project status document` — **1 fichier ajouté**
  (`docs/PROJECT_STATUS.md`), aucun autre fichier touché.
  Le hash n'est **pas** inscrit dans le fichier lui-même (il change à chaque amendement) :
  le lire via `git log --oneline -1`.
- **Push** : **effectué et vérifié** le 2026-10-21 — `c692cd9..b3e2d1c  master -> master`,
  code de sortie **0**, preuve distante `git ls-remote origin refs/heads/master` →
  `b3e2d1c9de8b427d603c8dd68664850444858bd5`. Détail complet au § 11.1.

#### 11.1 Push du commit de documentation (2026-10-21) — effectué et vérifié

Le push a été **explicitement autorisé par l'utilisateur** sous conditions strictes
(push du seul commit de documentation, sans toucher aux deux fichiers WIP), puis
**effectué** et **vérifié**. Déroulé réel, avec les sorties observées :

| Étape | Commande | Résultat observé |
|---|---|---|
| État avant | `git status --short --branch` | `## master...origin/master [ahead 1]` — index vide, 2 fichiers WIP modifiés **non indexés**, aucun fichier non suivi |
| Remote | `git remote -v` | `origin https://github.com/kodjohoza-hash/agri-connect.git` (fetch + push) |
| Historique distant | `git fetch origin` | `= [up to date] master -> origin/master` — **aucun commit distant nouveau** |
| Divergence | `git rev-list --left-right --count master...origin/master` | `1  0` → 1 commit devant, **0 derrière** |
| Compatibilité | `git merge-base --is-ancestor origin/master master` | code **0** → **fast-forward possible**, aucun écrasement possible |
| Contenu à pousser | `git diff --name-status c692cd9..master` | `A  docs/PROJECT_STATUS.md` → **1 seul fichier**, aucun WIP, aucun fichier étranger |
| Indexation | `git add -- docs/PROJECT_STATUS.md` | idempotente (le fichier était déjà commité) — `git diff --cached --name-only` **vide**, `git diff --cached --check` code **0** |
| Push | `git push origin master` | `c692cd9..b3e2d1c  master -> master` — code de sortie **0** |
| Preuve distante | `git ls-remote origin refs/heads/master` | `b3e2d1c9de8b427d603c8dd68664850444858bd5` |
| Alignement après | `git rev-list --left-right --count master...origin/master` | `0  0` |
| WIP préservés | SHA256 + `LastWriteTime` des 2 fichiers | **identiques avant et après** le push (cf. § 2.1) |

Le push **n'a ni embarqué ni exposé** le travail en cours : `git push` ne transmet que les
commits, et le commit poussé ne contient que l'ajout de `docs/PROJECT_STATUS.md`. Les deux
fichiers WIP sont restés **modifiés, non indexés, non commités**, avec des empreintes
SHA256 et des dates de modification **inchangées**.

> Point de méthode : ce push a été une **exception explicite** à la règle § 10.4 point 5
> (arbre de travail contenant des modifications étrangères). L'utilisateur a autorisé le
> push du seul commit de documentation, sous réserve que les deux fichiers WIP ne soient
> ni modifiés, ni restaurés, ni supprimés, ni inclus dans le commit. Ces conditions ont
> été vérifiées **avant** le push (empreintes + mtime + contenu du commit) et **après**
> (empreintes + mtime + `git status --short --branch`).

```bash
# contrôle de l'état réel par un assistant futur
git ls-remote origin refs/heads/master   # doit renvoyer le hash de HEAD
git status -sb                           # doit afficher "## master...origin/master" sans écart
git rev-list --left-right --count master...origin/master   # doit afficher "0  0"
```

#### 11.2 Mises à jour ultérieures de ce document (2026-10-21)

Après le push de `b3e2d1c`, ce document a été **amendé** par des commits de documentation
supplémentaires (mise à jour du § 2, de la § 10.4, des § 11 / 11.1, correction des chiffres
et des libellés) :

- **Périmètre** : documentation uniquement. **Aucune refonte de dashboard.**
- **Contenu** : § 2 (tableau d'état Git), § 10.4 (exception encadrée au point 5), § 11 et
  § 11.1 mis à jour avec le **résultat vérifié** du push du commit `b3e2d1c` ; puis
  correction de chiffres devenus obsolètes (nombre de dépôts, nombre d'anomalies) et de
  formulations datées.
- **Fichiers de chaque commit** : `docs/PROJECT_STATUS.md` **uniquement** — aucun fichier
  WIP, aucun fichier étranger (`git diff --cached --name-only` contrôlé avant chaque commit).
- **Commits** : série de commits de documentation (`docs: …`), chacun limité au seul
  `docs/PROJECT_STATUS.md`. Hash : `git log --oneline -3` (les hashes ne sont pas inscrits
  dans le fichier : ils changent à chaque amendement).
- **Push** : chaque commit est poussé sur `origin/master` par un push normal (jamais
  `--force`), puis contrôlé par `git ls-remote origin refs/heads/master` +
  `git status -sb` + `git rev-list --left-right --count master...origin/master`
  (attendu : `0  0`).
  *Le fichier ne peut pas contenir le résultat de son propre push* — l'écrire le
  modifierait ; c'est pourquoi seule la **procédure** et l'**état attendu** sont consignés
  ici, et le résultat réel est vérifié par les commandes ci-dessous.
- **WIP** : les deux fichiers du § 2.1 sont restés **modifiés, non indexés, non commités**,
  empreintes SHA256 et dates de modification **inchangées** avant et après chaque push.

```bash
# contrôle de l'état réel par un assistant futur
git ls-remote origin refs/heads/master          # doit renvoyer le hash de HEAD
git status -sb                                  # "## master...origin/master" sans écart
git rev-list --left-right --count master...origin/master   # "0  0"
git log --oneline -3 -- docs/PROJECT_STATUS.md  # derniers commits de documentation
```

#### 11.3 Harmonisation de la navigation : « Tableau de bord » → « Accueil » (2026-10-21)

- **Périmètre** : **navigation uniquement**. Aucune refonte de dashboard, aucun changement
  de route, de rôle, de permission ou de politique de publication.
- **Objectif** : dans les **six** espaces (Buyer, Supplier, Driver, Agent, Admin, Root),
  la section `dashboard` — l'entrée qui ramène à l'écran principal du rôle — s'appelle
  **« Accueil »** en français et **« Home »** en anglais.
- **Constat de départ** : la section `dashboard` utilisait la clé partagée
  `sectionDashboard` (« Tableau de bord » / « Dashboard ») via `RoleSection.label()`.
  Cette clé sert aussi de **titre de page** (`UnderConstructionPage`) : la modifier
  globalement aurait donc aussi changé un titre de page, **hors périmètre**.
- **Décision** : créer une clé dédiée à la navigation, `navHome` (« Accueil » / « Home »),
  et une extension `RoleSectionNavLabelX.navLabel()` qui remplace le libellé de la section
  `dashboard` par `navHome` **sur les surfaces de navigation uniquement**.
  `sectionDashboard` reste le titre de la section pour les pages. L'ancienne clé
  agent-spécifique `agentNavigationHome` (déjà « Accueil » / « Home ») est **supprimée** :
  `navHome` la remplace, tous rôles confondus.
- **Fichiers modifiés** :
  - `lib/core/localization/l10n/app_fr.arb`, `app_en.arb` : `navHome` ajouté,
    `agentNavigationHome` retiré ;
  - `lib/core/localization/generated/*` : régénérés par `flutter gen-l10n` ;
  - `lib/core/localization/locale_x.dart` : extension `RoleSectionNavLabelX` ;
  - `lib/shared/widgets/role_shell.dart` : **trois surfaces** basculées sur `navLabel()`
    — barre basse `NavigationBar`, sidebar staff `_SidebarItem`, feuille « Plus »
    `_showMoreSheet` — ; le cas Agent compact n'a plus besoin de branche dédiée ;
  - `test/role_shell_responsive_navigation_test.dart` : **15 tests ajoutés**
    (6 rôles × FR/EN + 3 sidebars staff) ;
  - `test/agent_space_test.dart`, `test/supplier_space_test.dart`,
    `test/super_admin_space_test.dart` : libellés de navigation mis à jour.
- **Non modifié volontairement** : `sectionDashboard` (titre de page), les infobulles
  `dashboardRefreshTooltip` / `adminRefreshTooltip`, le CTA du panneau de bienvenue
  `supplierWelcomeSecondary` (« Accéder au tableau de bord ») — ce ne sont pas des
  libellés de navigation.
- **Tests réellement exécutés** :
  - navigation + localisation → **98 réussis / 0 échec**
    (`role_shell_responsive_navigation_test.dart`, `agent_space_test.dart`,
    `admin_localization_test.dart`, `mobile_navigation_audit_test.dart`) ;
  - espaces → **127 réussis / 0 échec** (`supplier_space_test.dart`,
    `super_admin_space_test.dart`, `driver_space_test.dart`, `admin_dashboard_test.dart`) ;
  - **suite complète → 671 réussis / 1 échec**. L'unique échec est le test WIP
    préexistant `the category hint tracks viewport resizing`
    (`test/buyer_space_test.dart`), sans rapport. Cohérence arithmétique :
    654 (HEAD) + 15 (nouveaux) + 3 (WIP) = 672 = 671 + 1.
- **Analyse** : `dart analyze` → **1 info** (`unnecessary_lambdas`,
  `test/admin_repository_test.dart:68:28`), **0 erreur**, identique à HEAD.
- **Diff** : `git diff --check` → code **0**.
- **Contrôle de rendu (build web, iframe 390 × 844)** : les **six** dashboards ont été
  parcourus en **FR** et **EN** (session pilotée par `localStorage`). Vérifié par
  **arbre de sémantique + géométrie DOM** : « Accueil » / « Home » affiché et
  **aucune trace de « Tableau de bord » / « Dashboard »** dans l'arbre de sémantique ;
  barre basse = 4 destinations de 98 × 80 px (x = 0 / 98 / 195 / 293) soit **390 px
  exactement**, **aucun débordement** ; Agent compact = Accueil / Support / Commandes /
  Plus ; feuille « Plus » ouverte (Admin) = Commandes, Livraisons, Statistiques, Profil.
  La **sidebar staff** n'est **pas** exposée par la sémantique web de ce build ; sa
  présence et son item sélectionné ont été confirmés par **lecture des pixels** du canvas
  (fond `primarySoft` = tuile sélectionnée en haut, surface blanche ensuite) et par le test
  `agent_space_test.dart`, qui ouvre la sidebar **par son libellé**.
  **Rendu graphique non vérifié** : aucune revue d'image (capture non lisible dans cet
  environnement) ni appareil Android.
- **Commit / push** : hash et résultat vérifié consignés dans le **§ 11.4**, ajouté après
  vérification réelle (un fichier ne peut pas contenir le résultat de son propre push).

#### 11.4 Push du commit de renommage de navigation (2026-10-21) — effectué et vérifié

Le commit **`b4df5f8`** — `fix(navigation): rename dashboard tab to home` — a été poussé
sur `origin/master` par un push **normal** (jamais `--force`), puis **vérifié**.

| Étape | Commande | Résultat observé |
|---|---|---|
| État avant | `git status --short --branch` | `## master...origin/master [ahead 1]` — index vide, 2 fichiers WIP modifiés **non indexés** |
| Historique distant | `git fetch origin` | **aucun commit distant nouveau** |
| Divergence | `git rev-list --left-right --count master...origin/master` | `1  0` → 1 commit devant, **0 derrière** |
| Compatibilité | `git merge-base --is-ancestor origin/master master` | code **0** → **fast-forward possible**, aucun écrasement |
| Contenu poussé | `git show --name-only --format= HEAD` | **12 fichiers**, aucun WIP, aucun fichier étranger |
| Push | `git push origin master` | `372a2f9..b4df5f8  master -> master` — code de sortie **0** |
| Preuve distante | `git ls-remote origin refs/heads/master` | `b4df5f85afaa87c8caec88085550851dc9d7cc3b` |
| Alignement après | `git rev-list --left-right --count master...origin/master` | `0  0` |
| WIP préservés | SHA256 + `LastWriteTime` | **identiques** avant et après le push (cf. § 2.1) |

Le commit poussé contient uniquement l'harmonisation de navigation : les 2 fichiers ARB,
les 3 fichiers de localisation régénérés, `locale_x.dart`, `role_shell.dart`, 4 fichiers de
test et ce document. Les deux fichiers WIP (§ 2.1) sont restés **modifiés, non indexés,
non commités**, avec des empreintes SHA256 et des dates de modification **inchangées**.

> Ce WIP Buyer a été **résolu puis commité** le même jour (cf. § 11.5) : il n'est plus
> en attente dans l'arbre de travail.

#### 11.5 Résolution du WIP Buyer — indice de scroll des catégories (2026-10-21)

- **Périmètre** : WIP Buyer uniquement (`lib/features/buyer/presentation/widgets/catalog_filter_bar.dart`
  et `test/buyer_space_test.dart`). Aucun autre dashboard touché, aucune intégration backend.
- **Objectif** : `test/buyer_space_test.dart` à **65 réussis / 0 échec**.
- **Symptôme** : `the category hint tracks viewport resizing` échouait dès sa **première**
  assertion (`Expected: no matching candidates` / `Actual: Found 1 widget with icon
  IconData(U+0F63B)`) : l'indice de scroll (`Icons.chevron_right_rounded`) était présent
  à 1200 px alors que le test l'attendait absent.
- **Diagnostic chiffré** (sondes de test temporaires, supprimées après usage) :
  - à 1200 px : barre de catégories = **690 px** (carte plafonnée à 720 px), rangée de
    puces = **1135 px** (police de test `FlutterTest`) → `maxScrollExtent` = **445,3 px** ;
  - à 320 px : barre = **250 px**, étendue = **885,3 px** ;
  - retour à 1200 px : étendue = **445,3 px** — l'indice suit, il n'est jamais obsolète ;
  - après défilement en bout de ligne puis retour à 1200 px : l'indice **ne réapparaît
    pas** (position plafonnée à la nouvelle étendue).
  - **Conclusion** : le widget est **correct** — l'étendue est recalculée à chaque
    redimensionnement et l'indice la suit. **La prémisse du test était fausse** : le
    dashboard plafonne la barre de filtres à 720 px, donc les catégories débordent à
    **toutes** les largeurs.
- **Confirmation sur rendu réel** (build web, police Roboto, puces inchangées par le WIP) :
  101,2 + 113 + 116,1 + 93,8 + 189,2 + ~101,2 + 5 × 8 (écarts) = **≈ 754 px** pour une
  barre de **690 px** → la dernière catégorie (« Épices ») est réellement tronquée à
  1200 px. L'indice est donc **légitime** : il signale une catégorie hors écran, ce qui
  est précisément la finalité du test voisin
  `the dashboard signals when more categories are off-screen`.
- **Correction retenue** : **correction de la prémisse du test**, et non affaiblissement.
  Le test corrigé garde et renforce ses assertions :
  - à 1200 px, l'indice est **présent** (la rangée déborde de la barre plafonnée) ;
  - à 320 px, l'étendue **augmente** et l'indice est toujours présent — le suivi est
    vérifié sur la mesure, pas sur une valeur figée ;
  - après `ensureVisible('Épices')`, l'indice **disparaît** (fin de rangée atteinte) ;
  - retour à 1200 px : l'indice **ne réapparaît pas** — aucun état obsolète.
  - `catalog_filter_bar.dart` n'a **pas** été modifié (SHA256 inchangé) : aucun
    contournement, aucun délai ajouté, aucune valeur fixe, aucun affaiblissement
    d'assertion, aucun test supprimé.
- **Tests réellement exécutés** :
  - `flutter test test/buyer_space_test.dart` → **65 réussis / 0 échec** ;
  - `flutter test` (suite complète) → **675 réussis / 0 échec** ;
  - `dart analyze` → **1 info** (`unnecessary_lambdas`, `test/admin_repository_test.dart:68:28`),
    **0 erreur**, identique à HEAD ;
  - `git diff --check` → code **0**.
- **Contrôle visuel** : **non réalisé** (ni revue d'image, ni appareil Android). L'indice
  n'a donc **pas** été validé optiquement : l'anomalie A6 (indice enveloppé dans
  `ExcludeSemantics`, donc invisible dans l'arbre de sémantique) reste **À CONFIRMER**.
- **Note de commit** : les deux fichiers Buyer forment une **unité cohérente** — le test
  dépend du widget (l'indice n'existe que dans le WIP), les commiter séparément produirait
  une suite rouge. Ils sont donc commités ensemble.
- **Commit / push** : hash et résultat vérifié consignés en **§ 11.6**.

#### 11.6 Push de la résolution du WIP Buyer (2026-10-21) — effectué et vérifié

Le commit **`24f17f3`** — `feat(buyer): add catalog category scroll hint and correct its
resize test` — a été poussé sur `origin/master` par un push **normal** (jamais `--force`),
puis **vérifié**.

| Étape | Commande | Résultat observé |
|---|---|---|
| État avant | `git status --short --branch` | `## master...origin/master [ahead 1]`, **arbre de travail propre** |
| Historique distant | `git fetch origin` | **aucun commit distant nouveau** |
| Divergence | `git rev-list --left-right --count master...origin/master` | `1  0` → 1 commit devant, **0 derrière** |
| Compatibilité | `git merge-base --is-ancestor origin/master master` | code **0** → **fast-forward possible**, aucun écrasement |
| Contenu poussé | `git show --name-only --format= HEAD` | **3 fichiers** : le widget, son test et ce document — **aucun fichier étranger** |
| Push | `git push origin master` | `217c3dc..24f17f3  master -> master` — code de sortie **0** |
| Preuve distante | `git ls-remote origin refs/heads/master` | `24f17f38020033bde06e21e49909f0751052ca24` |
| Alignement après | `git rev-list --left-right --count master...origin/master` | `0  0` |
| Arbre de travail | `git status --short --branch` | `## master...origin/master` — **aucune modification locale restante** |

**Aucun travail en attente n'est laissé de côté** : les deux fichiers du § 2.1 sont
désormais commités, et l'arbre de travail ne contient plus aucune modification locale
(ni fichier non suivi, ni index non vide). La suite complète est **verte**
(**675 réussis / 0 échec**).

---

## Annexe — Aides-mémoire pour un assistant IA

**Ordre de travail d'une nouvelle tâche :**

1. Lire ce document (`docs/PROJECT_STATUS.md`).
2. `git status -sb` + `git diff` + `git log --oneline -5` + `git fetch origin` →
   vérifier l'état réel, pas celui écrit ici.
3. Confirmer le chemin réel (U+00A0 !) et l'outillage (`dart analyze`, pas `flutter analyze`).
4. Identifier le périmètre : **une** étape fonctionnelle.
5. Préserver toute modification préexistante.
6. Écrire le code + les tests.
7. `dart analyze` + tests ciblés + suite complète + `git diff --check`.
8. **Contrôle de rendu** si l'environnement le permet : niveau 1 = sémantique + géométrie
   sur build web (390 × 844) ; niveau 2 = revue visuelle sur appareil / émulateur Android.
   Sinon, l'écrire honnêtement (« contrôle visuel non réalisé »).
9. `git add <chemin exact>` → relire `git diff --cached` → commit explicite.
10. `git fetch` → `git push origin master` → **vérifier** le résultat.
11. **Mettre à jour la § 11** avec date, tests, commit et push vérifié.

**Interdits absolus :**

- Commencer l'intégration backend avant la fin validée de la refonte des six dashboards
  (sauf instruction explicite de l'utilisateur).
- Modifier les routes, les rôles, les permissions ou la politique de publication.
- Déclarer une étape terminée sans commit, sans tests et sans mention explicite du
  contrôle visuel (réalisé / non réalisé).
- Écrire « push réussi » sans avoir vérifié la sortie de la commande.
- Supprimer, réinitialiser ou écraser un travail qui n'est pas le sien.

**Points de vigilance outillage (observés le 2026-10-21) :**

- **Chemin réel** : `D:\<U+00A0>\Agri_Connect\agri_connect` — le séparateur est le
  caractère **160 (NBSP)**, pas une espace. Les outils de lecture/écriture de fichiers ne
  peuvent pas ouvrir ce chemin : utiliser le shell avec `-LiteralPath` / `git -C`, ou
  éditer une copie dans un dossier temporaire puis `Copy-Item -LiteralPath`.
- **`flutter analyze` plante** sur ce chemin (analysis-server : `FormatException:
  Unexpected end of input`). **`dart analyze`** produit les mêmes diagnostics.
- **`flutter pub get` échoue sur un lecteur `subst`** ; `subst R: <dépôt>` fonctionne pour
  `flutter test`, `dart analyze`, `flutter gen-l10n` et `flutter build web`, puis
  `subst R: /D` pour démonter le lecteur.
- **`flutter build web --release` supprime les fichiers l10n générés** suivis par git
  (`lib/core/localization/generated/*`) : après un build, les restaurer avec
  `flutter gen-l10n` et contrôler `git status` — sinon ils apparaissent comme
  **supprimés** dans l'arbre de travail.
- **Jamais** `Get-Content -Raw` + `Set-Content -Encoding UTF8` sur ces fichiers : double
  encodage → mojibake. Éditer via une copie temporaire (outils de fichier) puis copier.
- **`core.autocrlf=true`** : un blob indexé en LF et une copie de travail en CRLF
  produisent un diff **minimal** (normalisation automatique). Ne pas comparer avec
  `core.autocrlf=false`, sinon git affiche tout le fichier comme réécrit.
- **Après tout build**, revérifier `git status` avant de conclure : le build ne doit
  laisser aucun fichier suivi modifié hors l10n régénéré.
