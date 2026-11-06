# AgriConnect — frontend Flutter

Application mobile d'une plateforme d'intermédiation agricole en consignation. Ce dépôt est connecté au backend
`agriconnect_backend` (dossier voisin `../agriconnect_backend`) en suivant un plan commit par commit.

Règles communes à tous les agents de code :
@.github/copilot-instructions.md

Feuille de route (statut et fiche de chaque commit) :
@docs/INTEGRATION_PLAN.md

Contrat réseau, seule source de vérité pour les endpoints, champs, codes d'erreur et événements :
`docs/API_CONTRACT.md` (à lire en entier avant la phase en cours, sections concernées ensuite).

## Commandes

- Dépendances : `flutter pub get`
- Traductions (après une modification de `lib/core/localization/*.arb`) : `flutter gen-l10n`
- Analyse : `flutter analyze` — 0 erreur, aucun nouvel avertissement ni nouvelle remarque
- Tests : `flutter test` (un fichier : `flutter test test/chemin_test.dart`)
- Lancement sur émulateur : `flutter run --dart-define-from-file=env/dev.emulator.json`
  (copier `env/dev.emulator.json.example` si le fichier manque ; le backend écoute sur le port 4000)

## Déroulement attendu

1. Prendre le premier commit « À FAIRE » de `docs/INTEGRATION_PLAN.md`, section 2.
2. Suivre la méthode de la section 3 du plan : lire la fiche, implémenter cette fiche seulement, vérifier,
   commiter, passer le statut à FAIT.
3. S'arrêter à la fin de chaque phase et à chaque point de contrôle, résumer ce qui a changé et ce qui reste à
   vérifier à la main, puis attendre la validation.

Ne jamais pousser, ni modifier le dépôt backend depuis ce dépôt, ni toucher aux fichiers `.env`.
