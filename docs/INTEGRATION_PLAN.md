# Plan d'intégration frontend ↔ backend

Plan détaillé (descriptions de commit complètes, décisions, risques) :
https://claude.ai/artifact/HNhWPnpodzbn7vEkEybjqi

Branche frontend : `feature/api`. Branche backend : `feature/mobile-contract`.
Contrat réseau : `docs/API_CONTRACT.md`.

Statuts : À FAIRE · EN COURS · FAIT (commit) · ANNULÉ (raison).

## Baseline avant intégration

| Vérification | Résultat |
|---|---|
| `dart analyze` | Après C05 (2026-11-06) : 0 erreur, 0 avertissement, 7 remarques de style, corrigées en deux commits (la dernière, `close_sinks`, dans `realtime_service.dart`) |
| `flutter test` | Après C05 (2026-11-06) : 700 tests réussis |

## Backend (`agriconnect-backend`)

| # | Commit | Statut |
|---|---|---|
| B1 | chore(dev): log API requests with morgan and run with nodemon | FAIT en local (`3f4352f`), à pousser |
| B2 | feat(ai): add Anthropic Claude provider | À FAIRE |
| B3 | feat(ai): automatic fallback to a second provider on timeout or outage | À FAIRE |
| B4 | fix(seed): demo AI agent follows AI_PROVIDER instead of pinning Ollama | À FAIRE |
| B5 | docs(api): fix Order, sender label and AdminUser schemas, document sockets | À FAIRE |
| B6 | fix(staff): lot validation no longer requires a rejection reason | À FAIRE |

## Frontend (`agriconnect_frontend`)

| Phase | # | Commit | Statut |
|---|---|---|---|
| 0 Préparation | C01 | chore(android): build with the local toolchain and allow network access | FAIT |
| 0 Préparation | C02 | docs: API contract, integration plan and coding-agent rules | FAIT |
| 1 Socle | C03 | feat(core): environment config, Dio client and typed API failures | FAIT (vérifié) |
| 1 Socle | C04 | feat(auth): secure token storage and single-flight refresh | FAIT (vérifié) |
| 1 Socle | C05 | feat(realtime): Socket.io service with token-aware reconnection | FAIT (vérifié) |
| 2 Auth | C06 | feat(auth)!: remote authentication and backend user model | À FAIRE |
| 2 Auth | C07 | feat(auth)!: sign-in without role picking, role-aware sign-up and recovery | À FAIRE |
| 2 Auth | C08 | test(app): staff sessions stay interactive after sign-in | À FAIRE |
| 3 Compte | C09 | feat(reference): cached reference data and pickers | À FAIRE |
| 3 Compte | C10 | feat(account): profile, avatar, sessions and email verification | À FAIRE |
| 3 Compte | C11 | feat(account): profile verification documents and verified-only gating | À FAIRE |
| 3 Compte | C12 | feat(account): payout accounts and referral | À FAIRE |
| 4 Messagerie | C13 | feat(chat)!: support conversations over REST and Socket.io | À FAIRE |
| 5 Acheteur | C14 | feat(buyer)!: anonymous listing catalog with server-side filters | À FAIRE |
| 5 Acheteur | C15 | feat(buyer)!: replace cart and checkout with quote requests | À FAIRE |
| 5 Acheteur | C16 | feat(buyer)!: quotes and orders with countdown, confirmation and tracking | À FAIRE |
| 6 Fournisseur | C17 | feat(supplier)!: stock lots replace products | À FAIRE |
| 6 Fournisseur | C18 | feat(supplier): lot declaration with multipart photos | À FAIRE |
| 6 Fournisseur | C19 | feat(supplier)!: earnings tab replaces supplier orders | À FAIRE |
| 7 Livreur | C20 | feat(driver)!: pull-based delivery pool and status progression | À FAIRE |
| 8 Équipe | C21 | feat(staff)!: capability-driven staff shell with nine capabilities | À FAIRE |
| 8 Équipe | C22 | feat(staff): support inbox and conversation handling | À FAIRE |
| 8 Équipe | C23 | feat(staff): lot validation, quality checks and stock movements | À FAIRE |
| 8 Équipe | C24 | feat(staff): listing management from validated lots | À FAIRE |
| 8 Équipe | C25 | feat(staff): quote issuing and order processing | À FAIRE |
| 8 Équipe | C26 | feat(staff): payment recording with idempotency | À FAIRE |
| 8 Équipe | C27 | feat(staff): delivery dispatch coordination | À FAIRE |
| 8 Équipe | C28 | feat(staff): profile verification review | À FAIRE |
| 8 Équipe | C29 | feat(staff): supplier compensation requests | À FAIRE |
| 9 IA | C30 | feat(ai): suggestion repository with realtime tracking | À FAIRE |
| 9 IA | C31 | feat(ai): reply suggestions in the support thread | À FAIRE |
| 9 IA | C32 | feat(ai): AI listing drafts from lots | À FAIRE |
| 9 IA | C33 | feat(admin): AI engine status, test console and AI agents | À FAIRE |
| 10 Admin | C34 | feat(admin)!: users, drivers and staff accounts | À FAIRE |
| 10 Admin | C35 | feat(admin)!: statistics dashboard from /admin/stats | À FAIRE |
| 10 Admin | C36 | feat(admin): payouts, compensations and referrals | À FAIRE |
| 10 Admin | C37 | feat(admin): reference data, agencies and delivery zones | À FAIRE |
| 10 Admin | C38 | feat(admin): audit log and legal document versions | À FAIRE |
| 10 Admin | C39 | feat(root)!: real platform settings | À FAIRE |
| 11 Finition | C40 | feat(notifications)!: notification center fed by socket events | À FAIRE |
| 11 Finition | C41 | chore: remove remaining demo data, assets and dead code | À FAIRE |
| 11 Finition | C42 | docs: end-to-end checklist and project status | À FAIRE |

## Points de contrôle

- Après C08 : le test d'interactivité des rôles staff doit être vert avant d'aller plus loin.
- Fin des phases 8, 9 et 10 : connexion manuelle Admin et Agent sur émulateur, chaque onglet et un bouton par
  section doivent réagir.
- Avant la phase 9 : B2, B3 et B4 faits côté backend, `npm run ai:eval` lancé sur Granite et Gemini.
