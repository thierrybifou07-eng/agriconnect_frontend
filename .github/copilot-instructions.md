# Règles pour les agents de code — AgriConnect (frontend Flutter)

Lire avant toute tâche : `docs/PROJECT_STATUS.md`, `docs/API_CONTRACT.md`, `docs/INTEGRATION_PLAN.md`.

## Pile et structure

- Flutter, **Riverpod** (`Notifier` / `AsyncNotifier`), go_router, Dio. Pas de GetX.
- Architecture par fonctionnalité : `domain/` (modèles, interfaces de dépôt, règles pures), `application/`
  (contrôleurs Riverpod), `data/` (implémentations `Remote*Repository`, DTO), `presentation/` (pages, widgets).
- Le réseau passe uniquement par `lib/core/network/`. Aucun import de `package:dio` en dehors de `lib/core/network/`
  et des dossiers `data/`.

## Contrat réseau

- `docs/API_CONTRACT.md` est la seule source de vérité. Ne jamais inventer un endpoint, un champ, un code d'erreur
  ou une valeur d'enum. Si une information manque, l'écrire dans la réponse et s'arrêter sur ce point.
- Identifiants : `int`. Montants et quantités : `double`. Dates : `DateTime` en UTC.
- Aucun calcul de total, de frais, de commission ou de prix côté client : le serveur fournit les montants.
- Le frontend ne contacte jamais Ollama, Gemini ni Claude : tout passe par le backend.

## Données et erreurs

- Aucune donnée fictive dans `lib/` : pas de `Demo*Repository`, pas de listes codées en dur d'utilisateurs, de
  produits, de villes ou de commandes. Les doublures de test vivent uniquement dans `test/support/`.
- Toute erreur réseau devient une `Failure` (`lib/core/errors/`) affichée par un message localisé FR et EN.
- Chaque écran gère quatre états : chargement, vide, erreur avec réessai, contenu.
- Aucune action de l'interface ne simule une réussite.

## Méthode

- Une étape du plan = un commit (Conventional Commits, description qui résume la diff, en français).
- Ajouter les chemins exacts (`git add <chemin>`), jamais `git add .`. Ne jamais pousser ni réécrire l'historique.
- Après chaque étape : `dart analyze` sans erreur ni nouvel avertissement, `flutter test` vert,
  `git diff --check` propre.
- Tout ce qui est ajouté ou modifié est testé. Un test qui portait sur du contenu de démonstration est réécrit sur
  une doublure, ou supprimé avec la fonctionnalité qu'il testait, et le commit le dit.
- Après deux échecs sur le même problème : s'arrêter et rapporter. Ne jamais affaiblir ni désactiver un test pour
  le faire passer.
