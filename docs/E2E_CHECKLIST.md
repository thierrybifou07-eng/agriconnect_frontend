# Checklist E2E AgriConnect

Les scénarios ci-dessous sont à exécuter avec le backend seed de démonstration.
Chaque case doit être cochée avec la date et le résultat observable.

## A. Fournisseur : inscription, vérification et publication
- [ ] Inscription fournisseur réussie
- [ ] Dépôt de document de vérification
- [ ] Agent approuve le profil
- [ ] Compte devient `VERIFIED` après rafraîchissement
- [ ] Déclaration de lot créée
- [ ] Agent valide la déclaration
- [ ] Annonce publiée
- [ ] Date / résultat :

## B. Acheteur : demande de devis et validation
- [ ] Demande de devis créée depuis le catalogue
- [ ] L'agent émet le devis
- [ ] Le compte à rebours est visible dans le flux
- [ ] L'acheteur confirme le devis
- [ ] Date / résultat :

## C. Paiement, préparation, livraison et clôture
- [ ] Paiement saisi sans double déclenchement / idempotence vérifiée
- [ ] Statut passe à `PREPARING`
- [ ] Livraison créée
- [ ] Le livreur accepte
- [ ] Statut final `DELIVERED`
- [ ] Statut final `COMPLETED`
- [ ] Date / résultat :

## D. Messagerie temps réel et reprise réseau
- [ ] Conversation ouverte sur deux appareils
- [ ] Message instantané reçu sur le second appareil
- [ ] Coupure réseau simulée
- [ ] Reconnexion automatique réussie
- [ ] Les messages continuent à se synchroniser
- [ ] Date / résultat :

## E. Suggestion IA et moteur d'administration
- [ ] Moteur IA disponible (si Ollama ou service configuré)
- [ ] Suggestion IA générée
- [ ] Suggestion approuvée par l'équipe
- [ ] Vérification côté admin du moteur IA
- [ ] Date / résultat :

## F. Suspension du compte connecté
- [ ] Suspension d'un compte connecté depuis l'admin
- [ ] Déconnexion immédiate observée
- [ ] Event `session_revoked` reçu par le client
- [ ] Date / résultat :

## G. Expiration du jeton d'accès et refresh
- [ ] JWT_EXPIRES_IN=1m en dev
- [ ] Plusieurs appels parallèles déclenchent un seul refresh
- [ ] Les requêtes repartent sans boucle d'erreur
- [ ] Date / résultat :

## H. Compte non vérifié : blocage et bannière
- [ ] Bannière visible pour un profil non vérifié
- [ ] Action bloquée affiche un message explicite
- [ ] Dialogue de blocage affiché sur chaque action critique
- [ ] Date / résultat :

## Notes de validation

- Les anomalies doivent être listées dans le commit final et ne sont pas corrigées
  hors périmètre tant qu'elles ne bloquent pas la validation du module.
- Le backend utilisé pour ce document doit être mentionné et la date de validation
  doit figurer dans chaque scénario.

## Exécution locale — 2026-10-27

Backend : `http://127.0.0.1:4000` — `GET /health` a répondu `200
{"status":"ok"}`. Exécution API sur les comptes seedés, sans créer ni modifier de
lot, devis, paiement, livraison, compte ou suggestion.

| Scénario | Résultat observé |
|---|---|
| A — Fournisseur | Connexion et `GET /auth/me` réussis pour les fournisseurs vérifié (`VERIFIED`) et non vérifié (`UNVERIFIED`) ; `GET /auth/sessions` répond `200`. Dépôt, approbation et publication non exécutés. |
| B — Lot / annonce | Non exécuté : nécessite les écritures métier du workflow. |
| C — Devis / paiement / livraison | Non exécuté : nécessite une commande seedée compatible ou la création d'enregistrements métier. |
| D — Messagerie | Endpoints de conversation agent accessibles (`200`), mais échange multi-appareil et coupure réseau non exécutés. Aucun appareil Android n'était connecté (Windows, Chrome et Edge seulement). |
| E — IA | `GET /admin/ai/status` répond `200`; génération et approbation d'une suggestion non exécutées. |
| F — Suspension | Non exécuté pour ne pas suspendre un compte seedé ni interrompre d'autres sessions. |
| G — Expiration / refresh parallèle | Non exécuté : le backend déjà démarré n'a pas été relancé avec `JWT_EXPIRES_IN=1m`. |
| H — Profil non vérifié | Les deux profils non vérifiés ont été lus avec succès. L'essai de la requête bloquée et la vérification des dialogues UI n'ont pas été exécutés. |

Endpoints de lecture vérifiés avec les comptes correspondants : catalogue acheteur,
lots et commandes staff, file IA staff, livraisons disponibles/du livreur,
vérifications admin et statut du moteur IA ont répondu `200`. Pour les sept
comptes, `GET /auth/me` et `GET /auth/sessions` ont répondu `200`. Les sessions
ouvertes pendant les vérifications ont été fermées via logout.

Limite rencontrée : après plusieurs connexions de test depuis la même IP, le
limiteur du backend a répondu `429` à de nouvelles connexions. Les tentatives ont
été arrêtées pour respecter la limite de `10 / 15 min / IP`; aucun nouvel essai
de connexion n'a été lancé.
