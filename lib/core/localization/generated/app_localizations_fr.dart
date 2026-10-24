// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tagline => 'Le marché agricole connecté';

  @override
  String get splashLoading => 'Chargement de votre espace…';

  @override
  String get loginGreeting => 'Bon retour parmi nous';

  @override
  String get loginSubtitle => 'Connectez-vous pour accéder à votre espace';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signingIn => 'Connexion…';

  @override
  String get demoAccountsTitle => 'Comptes de démonstration';

  @override
  String get demoAccountsHint =>
      'Touchez un compte pour pré-remplir les champs.';

  @override
  String get validationEmailRequired => 'Veuillez saisir votre adresse e-mail.';

  @override
  String get validationEmailInvalid => 'Adresse e-mail invalide.';

  @override
  String get validationPasswordRequired =>
      'Veuillez saisir votre mot de passe.';

  @override
  String get errInvalidCredentials =>
      'Identifiants incorrects. Veuillez réessayer.';

  @override
  String get errNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get errTimeout =>
      'Le délai de la requête est dépassé. Veuillez réessayer.';

  @override
  String get errServer => 'Erreur serveur. Veuillez réessayer plus tard.';

  @override
  String get errCache => 'Impossible d\'accéder au stockage local.';

  @override
  String get errUnexpected => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get errRoleNotAllowed =>
      'La création de compte pour ce rôle n\'est pas autorisée.';

  @override
  String get errAccessDenied =>
      'Votre session n\'a pas la permission d\'effectuer cette action.';

  @override
  String get errSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get roleSupplier => 'Fournisseur';

  @override
  String get roleBuyer => 'Acheteur';

  @override
  String get roleDriver => 'Livreur';

  @override
  String get roleAgent => 'Agent';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleRoot => 'Root';

  @override
  String get sectionDashboard => 'Tableau de bord';

  @override
  String get sectionProducts => 'Mes produits';

  @override
  String get sectionOrders => 'Commandes';

  @override
  String get sectionProfile => 'Profil';

  @override
  String get sectionCatalog => 'Catalogue';

  @override
  String get sectionDeliveries => 'Livraisons';

  @override
  String get sectionTrips => 'Trajets';

  @override
  String get sectionUsers => 'Utilisateurs';

  @override
  String get sectionAnalytics => 'Statistiques';

  @override
  String get sectionPlatform => 'Plateforme';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsMarkRead => 'Marquer comme lu';

  @override
  String get notificationsRead => 'Lu';

  @override
  String notificationsUnreadCount(String count) {
    return 'Non lues : $count';
  }

  @override
  String get notificationsDemoNotice =>
      'Exemples de démonstration uniquement. Ce ne sont pas des alertes en direct et elles ne sont pas synchronisées avec un serveur.';

  @override
  String get notificationsEmptyTitle => 'Vous êtes à jour';

  @override
  String get notificationsEmptyBody =>
      'Aucune notification de démonstration pour ce compte.';

  @override
  String get notificationsLoadError =>
      'Impossible de charger les notifications.';

  @override
  String get notificationsCategoryOrders => 'Commandes';

  @override
  String get notificationsCategoryProducts => 'Produits';

  @override
  String get notificationsCategoryDeliveries => 'Livraisons';

  @override
  String get notificationsCategorySupport => 'Support';

  @override
  String get notificationsCategoryAdministration => 'Administration';

  @override
  String get notificationBuyerOrderTitle =>
      'Exemple de mise à jour de commande';

  @override
  String get notificationBuyerOrderBody =>
      'Un exemple de changement de statut de commande apparaît ici.';

  @override
  String get notificationBuyerDeliveryTitle =>
      'Exemple de mise à jour de livraison';

  @override
  String get notificationBuyerDeliveryBody =>
      'Un exemple de progression de livraison apparaît ici.';

  @override
  String get notificationSupplierOrderTitle => 'Exemple de nouvelle commande';

  @override
  String get notificationSupplierOrderBody =>
      'Une commande acheteur de démonstration figure dans vos commandes.';

  @override
  String get notificationSupplierProductTitle =>
      'Exemple d\'action sur un produit';

  @override
  String get notificationSupplierProductBody =>
      'Un produit de démonstration peut nécessiter votre attention dans le catalogue.';

  @override
  String get notificationDriverDeliveryTitle =>
      'Exemple de livraison attribuée';

  @override
  String get notificationDriverDeliveryBody =>
      'Une livraison de démonstration est disponible dans votre liste.';

  @override
  String get notificationDriverTripTitle => 'Exemple de mise à jour de trajet';

  @override
  String get notificationDriverTripBody =>
      'Une mise à jour de trajet de démonstration est disponible.';

  @override
  String get notificationAgentSupportTitle => 'Exemple de demande de support';

  @override
  String get notificationAgentSupportBody =>
      'Une demande acheteur de démonstration figure dans la file de support.';

  @override
  String get notificationAgentOrderTitle => 'Exemple de tâche de commande';

  @override
  String get notificationAgentOrderBody =>
      'Une tâche de commande de démonstration est disponible pour traitement.';

  @override
  String get notificationAgentStockTitle => 'Exemple de validation de stock';

  @override
  String get notificationAgentStockBody =>
      'Une déclaration de stock de démonstration est disponible pour examen.';

  @override
  String get notificationAdminProductTitle => 'Exemple de produit à examiner';

  @override
  String get notificationAdminProductBody =>
      'Un produit de démonstration est disponible dans la liste de modération.';

  @override
  String get notificationAdminOrderTitle => 'Exemple d\'activité de commande';

  @override
  String get notificationAdminOrderBody =>
      'Une commande de démonstration est disponible dans l\'espace d\'administration.';

  @override
  String get notificationRootPlatformTitle =>
      'Exemple d\'activité de plateforme';

  @override
  String get notificationRootPlatformBody =>
      'Un événement de démonstration est disponible dans la console plateforme.';

  @override
  String get notificationRootStaffTitle => 'Exemple d\'activité du personnel';

  @override
  String get notificationRootStaffBody =>
      'Un événement de démonstration est disponible dans l\'annuaire du personnel.';

  @override
  String get underConstructionTitle => 'Section en construction';

  @override
  String get underConstructionBody =>
      'Cette section sera disponible dans une prochaine étape d\'AgriConnect.';

  @override
  String get comingSoonBadge => 'Bientôt disponible';

  @override
  String get routeNotFoundTitle => 'Page introuvable';

  @override
  String get routeNotFoundBody => 'L\'adresse demandée n\'existe pas.';

  @override
  String get routeNotFoundHome => 'Retour à l\'accueil';

  @override
  String dashboardWelcome(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get dashboardSubtitle => 'Bienvenue sur votre espace';

  @override
  String get dashboardQuickActions => 'Accès rapide';

  @override
  String get dashboardQuickOrders => 'Commandes reçues';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirmTitle => 'Déconnexion';

  @override
  String get signOutConfirmBody => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get back => 'Retour';

  @override
  String get confirm => 'Confirmer';

  @override
  String get connectedAs => 'Connecté en tant que';

  @override
  String get accountInfo => 'Informations du compte';

  @override
  String get profileEditAction => 'Modifier le profil';

  @override
  String get profileEditTitle => 'Modifier votre profil';

  @override
  String get profileEditDescription =>
      'Modifiez le nom affiché sur votre compte.';

  @override
  String get profileSaveAction => 'Enregistrer les modifications';

  @override
  String get profileUpdated => 'Profil mis à jour sur cet appareil.';

  @override
  String get profileDiscardTitle => 'Abandonner les modifications ?';

  @override
  String get profileDiscardBody =>
      'La modification du nom non enregistrée sera perdue.';

  @override
  String get profileDiscardAction => 'Abandonner';

  @override
  String get profileKeepEditingAction => 'Continuer la modification';

  @override
  String get profileNameInvalid =>
      'Saisissez un nom valide de 2 à 80 caractères.';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get capabilityBuyerSupport => 'Support acheteurs';

  @override
  String get capabilityStockValidation => 'Validation des stocks';

  @override
  String get capabilityOrderProcessing => 'Traitement des commandes';

  @override
  String get capabilityPaymentFollowup => 'Suivi des paiements';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingSlide1Title => 'Un marché agricole connecté';

  @override
  String get onboardingSlide1Body =>
      'Achetez et vendez des produits frais et locaux, directement entre fournisseurs, acheteurs et commerçants.';

  @override
  String get onboardingSlide2Title => 'Des livraisons de confiance';

  @override
  String get onboardingSlide2Body =>
      'Des chauffeurs fiables transportent vos marchandises, de la ferme au point de vente, en toute sérénité.';

  @override
  String get onboardingSlide3Title => 'Une communauté qui vous connecte';

  @override
  String get onboardingSlide3Body =>
      'Fournisseurs, acheteurs, chauffeurs et administrateurs réunis pour des échanges transparents et efficaces.';

  @override
  String get languageTitle => 'Choisissez votre langue';

  @override
  String get languageSubtitle => 'Vous pourrez la modifier à tout moment.';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get roleTitle => 'Quel est votre profil ?';

  @override
  String get roleSubtitle =>
      'Choisissez le rôle qui vous correspond pour personnaliser votre expérience.';

  @override
  String get roleSupplierDesc => 'Je vends mes produits agricoles';

  @override
  String get roleBuyerDesc => 'J\'achète des produits locaux';

  @override
  String get roleDriverDesc => 'Je livre et transporte les marchandises';

  @override
  String get roleAgentDesc => 'J\'accompagne les utilisateurs et la plateforme';

  @override
  String get roleAdminDesc => 'Je gère les utilisateurs et la plateforme';

  @override
  String get roleRootDesc => 'Je supervise l\'ensemble de la plateforme';

  @override
  String get loginSelectedRole => 'Profil sélectionné';

  @override
  String get loginChangeRole => 'Changer de rôle';

  @override
  String get loginNoAccount => 'Pas encore de compte ?';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get registerTitle => 'Créer votre compte';

  @override
  String get registerSubtitle =>
      'Rejoignez le marché agricole en quelques secondes.';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerCreate => 'Créer mon compte';

  @override
  String get registerCreating => 'Création…';

  @override
  String get registerAlreadyAccount => 'Déjà un compte ?';

  @override
  String get registerSignIn => 'Se connecter';

  @override
  String get validationNameRequired => 'Veuillez saisir votre nom complet.';

  @override
  String get validationPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get validationPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get validationNameTooShort =>
      'Le nom doit contenir au moins 2 caractères.';

  @override
  String get validationNameTooLong =>
      'Le nom est trop long (maximum 80 caractères).';

  @override
  String get errEmailExists =>
      'Un compte existe déjà avec cette adresse e-mail.';

  @override
  String get errRoleMismatch =>
      'Cette adresse e-mail n\'est pas associée au rôle sélectionné.';

  @override
  String get registerAsRoleTitle => 'Vous vous inscrivez en tant que';

  @override
  String get retry => 'Réessayer';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get dashboardOverview => 'Vue d\'ensemble';

  @override
  String get productStatusOnSale => 'En vente';

  @override
  String get productStatusOutOfStock => 'En rupture';

  @override
  String get declarationStatusDraft => 'Brouillon';

  @override
  String get declarationStatusPendingReview => 'En attente d\'examen';

  @override
  String get declarationStatusAdditionalInfoRequired =>
      'Informations complémentaires requises';

  @override
  String get declarationStatusUnderDiscussion => 'En discussion';

  @override
  String get declarationStatusApprovedForPublication =>
      'Approuvé pour publication';

  @override
  String get declarationStatusRejected => 'Rejeté';

  @override
  String get declarationStatusSection => 'Statut de la déclaration';

  @override
  String get declarationDemoNotice =>
      'Statuts de démonstration. Dans la version finale, l\'équipe AgriConnect examine chaque déclaration et vous contacte avant toute publication.';

  @override
  String get declarationSaveDraftAction => 'Enregistrer le brouillon';

  @override
  String get declarationSubmittedSnack =>
      'Déclaration soumise. Elle sera examinée avant toute publication.';

  @override
  String get declarationDraftSavedSnack =>
      'Brouillon enregistré. Il n\'est pas visible par les acheteurs.';

  @override
  String get supplierWelcomeTitle => 'Bienvenue sur votre espace fournisseur';

  @override
  String supplierWelcomeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get supplierWelcomeBody =>
      'Renseignez vos produits en quelques minutes. L\'équipe AgriConnect examine chaque déclaration et vous contacte avant toute publication : rien n\'est publié automatiquement.';

  @override
  String get supplierWelcomePrimary => 'Commencer à renseigner mes produits';

  @override
  String get supplierWelcomeSecondary => 'Accéder au tableau de bord';

  @override
  String get buyerWelcomeTitle => 'Bienvenue sur AgriConnect';

  @override
  String buyerWelcomeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get buyerWelcomeBody =>
      'Découvrez des produits frais de producteurs locaux et composez votre panier en quelques minutes.';

  @override
  String get buyerWelcomePrimary => 'Découvrir le catalogue';

  @override
  String get buyerWelcomeDismiss => 'Plus tard';

  @override
  String get addProduct => 'Nouveau produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get saveProduct => 'Enregistrer le produit';

  @override
  String get savingProduct => 'Enregistrement…';

  @override
  String get productSaved => 'Produit enregistré avec succès.';

  @override
  String get productsDeclaredStat => 'Produits déclarés';

  @override
  String get statConfirmedOrders => 'Confirmées';

  @override
  String get ordersPendingStat => 'En attente de confirmation';

  @override
  String get productsEmptyTitle => 'Aucun produit';

  @override
  String get productsEmptyBody =>
      'Déclarez votre premier produit. L\'équipe AgriConnect l\'examinera avant toute publication.';

  @override
  String get productsNoResultTitle => 'Aucun produit trouvé';

  @override
  String get productsNoResultBody =>
      'Modifiez votre recherche ou changez de filtre.';

  @override
  String get recentProducts => 'Produits récents';

  @override
  String get recentOrders => 'Commandes récentes';

  @override
  String get supplierProductsOnSaleTitle => 'Produits actuellement en vente';

  @override
  String get dashboardManageProducts => 'Gérer mes produits';

  @override
  String get dashboardRefreshTooltip => 'Rafraîchir le tableau de bord';

  @override
  String get dashboardQuickAddProduct => 'Ajouter un produit';

  @override
  String get dashboardQuickExplore => 'Explorer les produits';

  @override
  String get dashboardQuickCart => 'Mon panier';

  @override
  String get dashboardQuickMyOrders => 'Mes commandes';

  @override
  String get dashboardCartEmpty => 'Panier vide';

  @override
  String get buyerHeroSubtitle =>
      'Les meilleurs produits de la ferme, livrés chez vous.';

  @override
  String get ordersPlacedStat => 'Commandes passées';

  @override
  String get chatTitle => 'Messages';

  @override
  String get roleStaffBadge => 'Équipe';

  @override
  String get chatEmptyTitle => 'Aucune conversation';

  @override
  String get chatEmptyBody =>
      'Vos échanges avec les acheteurs et les livreurs apparaîtront ici.';

  @override
  String get chatThreadEmptyTitle => 'Démarrez la conversation';

  @override
  String get chatThreadEmptyBody =>
      'Envoyez un premier message pour lancer l\'échange.';

  @override
  String get chatComposerHint => 'Votre message';

  @override
  String get chatSend => 'Envoyer';

  @override
  String productInStock(int quantity, String unit) {
    return '$quantity $unit en stock';
  }

  @override
  String get productNameLabel => 'Nom du produit';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productPriceLabel => 'Prix';

  @override
  String get productStockLabel => 'Stock disponible';

  @override
  String get productUnitLabel => 'Unité';

  @override
  String get productDeclaredOn => 'Déclaré le';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String get productNotFoundBody =>
      'Ce produit n\'est plus disponible. Il a peut-être été supprimé.';

  @override
  String get productFormInfoSection => 'Informations du produit';

  @override
  String get productFormPricingSection => 'Prix et disponibilité';

  @override
  String get productFormPhotosSection => 'Photos du produit';

  @override
  String get productFormPhotosHint =>
      'Ajoutez jusqu\'à 5 photos. La première sera la photo principale.';

  @override
  String get productFormPhotosEmpty => 'Aucune photo pour le moment';

  @override
  String get productFormReplacePhoto => 'Remplacer les photos';

  @override
  String get productFormRemovePhoto => 'Retirer la photo';

  @override
  String get productFormPickingPhotos => 'Lecture des photos…';

  @override
  String get productFormPhotoError =>
      'Impossible de lire ces photos. Réessayez.';

  @override
  String get productFormPublishAction => 'Soumettre la déclaration';

  @override
  String get productFormUpdateAction => 'Soumettre les modifications';

  @override
  String get productFormStatusSection => 'Visibilité';

  @override
  String get productFormCreateHint =>
      'Renseignez le produit, son prix et son stock. Votre déclaration sera examinée avant toute publication.';

  @override
  String get productFormEditHint =>
      'Ajustez les informations, puis soumettez à nouveau votre déclaration.';

  @override
  String get productFormStatusHint =>
      'Le statut dépend automatiquement du stock saisi.';

  @override
  String get productFormOutOfStockHint =>
      'Un stock à 0 met le produit en rupture de stock.';

  @override
  String get productFormSaveErrorTitle => 'Le produit n\'a pas été enregistré';

  @override
  String get productFormValidationSummary =>
      'Corrigez les champs signalés avant d\'enregistrer.';

  @override
  String get discardChangesTitle => 'Modifications non enregistrées';

  @override
  String get discardChangesBody =>
      'Vos modifications seront perdues si vous quittez cette page.';

  @override
  String get leaveFormAction => 'Quitter';

  @override
  String get keepEditingAction => 'Continuer à modifier';

  @override
  String get validationProductNameRequired =>
      'Veuillez saisir un nom de produit.';

  @override
  String get validationProductNameTooLong =>
      'Le nom du produit est trop long (maximum 80 caractères).';

  @override
  String get validationPriceInvalid => 'Veuillez saisir un prix valide.';

  @override
  String get validationPricePositive => 'Le prix doit être supérieur à zéro.';

  @override
  String get validationStockInvalid => 'Veuillez saisir une quantité valide.';

  @override
  String get ordersEmptyTitle => 'Aucune commande';

  @override
  String get ordersEmptyBody =>
      'Les commandes de vos acheteurs apparaîtront ici.';

  @override
  String get ordersNotFoundTitle => 'Commande introuvable';

  @override
  String get ordersNotFoundBody =>
      'Cette commande n\'existe plus ou n\'a pas pu être chargée.';

  @override
  String get ordersBackToList => 'Retour aux commandes';

  @override
  String get ordersSearchHint => 'Référence, acheteur ou produit';

  @override
  String get ordersStatPending => 'À confirmer';

  @override
  String get ordersStatConfirmed => 'Confirmées';

  @override
  String get ordersStatCancelled => 'Annulées';

  @override
  String ordersResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
      zero: 'Aucune commande',
    );
    return '$_temp0';
  }

  @override
  String get ordersNoResultTitle => 'Aucune commande ne correspond';

  @override
  String get ordersNoResultBody =>
      'Modifiez votre recherche ou changez de filtre pour voir vos commandes.';

  @override
  String get ordersClearFilters => 'Réinitialiser';

  @override
  String ordersConfirmedRevenue(String amount) {
    return 'Chiffre d\'affaires confirmé : $amount';
  }

  @override
  String ordersMoreItems(int count) {
    return '+$count autres';
  }

  @override
  String get ordersSummaryTitle => 'Récapitulatif';

  @override
  String get ordersReferenceLabel => 'Référence';

  @override
  String get ordersArticlesLabel => 'Articles';

  @override
  String ordersArticlesCount(int lines, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines lignes',
      one: '1 ligne',
    );
    return '$_temp0 · $total unité(s)';
  }

  @override
  String get ordersBuyerTitle => 'Acheteur';

  @override
  String get ordersPhoneLabel => 'Téléphone';

  @override
  String get ordersConfirmHelp =>
      'Confirmez la commande pour valider la préparation du colis.';

  @override
  String ordersItemDetail(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get statusOrderPending => 'En attente';

  @override
  String get statusOrderConfirmed => 'Confirmée';

  @override
  String get statusOrderCancelled => 'Annulée';

  @override
  String get confirmOrderAction => 'Confirmer la commande';

  @override
  String get confirmingOrder => 'Confirmation…';

  @override
  String get orderConfirmed => 'Commande confirmée avec succès.';

  @override
  String get confirmOrderError => 'La confirmation n\'a pas abouti.';

  @override
  String get confirmOrderHint =>
      'Le statut réel n\'a pas été mis à jour automatiquement. Vérifiez-le avant toute nouvelle action.';

  @override
  String get verifyStatus => 'Vérifier le statut';

  @override
  String get totalLabel => 'Total';

  @override
  String get activeOrdersStat => 'Commandes actives';

  @override
  String get statInTransit => 'En transit';

  @override
  String get statDelivered => 'Livrées';

  @override
  String get featuredCatalog => 'Catalogue à la une';

  @override
  String get buyerOrdersEmptyTitle => 'Aucune commande';

  @override
  String get buyerOrdersEmptyBody => 'Vos commandes apparaîtront ici.';

  @override
  String get buyerOrdersOngoingTitle => 'En cours';

  @override
  String get buyerOrdersClosedTitle => 'Terminées';

  @override
  String get buyerOrdersFilterBody =>
      'Le statut sélectionné n\'a plus aucune commande. Réinitialisez le filtre pour toutes les revoir.';

  @override
  String get catalogEmptyTitle => 'Aucun produit disponible';

  @override
  String get catalogEmptyBody => 'Le catalogue se remplira bientôt.';

  @override
  String get searchCatalog => 'Rechercher un produit';

  @override
  String get filterCategory => 'Catégorie';

  @override
  String get filterLocation => 'Localisation';

  @override
  String get filterAll => 'Toutes';

  @override
  String resultsCount(int count) {
    return '$count résultat(s)';
  }

  @override
  String catalogTotalProducts(int count) {
    return '$count produits au catalogue';
  }

  @override
  String get quantityIncrease => 'Augmenter la quantité';

  @override
  String get quantityDecrease => 'Diminuer la quantité';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String addedToCart(String name) {
    return '$name ajouté au panier.';
  }

  @override
  String get goToCart => 'Commander';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartEmptyTitle => 'Panier vide';

  @override
  String get cartEmptyBody => 'Parcourez le catalogue et ajoutez des produits.';

  @override
  String get viewCatalog => 'Voir le catalogue';

  @override
  String get cartClear => 'Vider';

  @override
  String itemsCount(int count) {
    return '$count article(s)';
  }

  @override
  String get cartClearTitle => 'Vider le panier ?';

  @override
  String cartClearBody(int count) {
    return 'Les $count article(s) sélectionnés seront retirés du panier.';
  }

  @override
  String get cartClearConfirm => 'Vider le panier';

  @override
  String get cartContinueShopping => 'Continuer mes achats';

  @override
  String cartStockRemaining(int count) {
    return 'Stock disponible : $count';
  }

  @override
  String get checkoutTitle => 'Valider la commande';

  @override
  String get checkoutTitleAction => 'Valider la commande';

  @override
  String get checkoutEditCart => 'Modifier le panier';

  @override
  String checkoutSummary(int count, String total) {
    return '$count article(s) · $total';
  }

  @override
  String get checkoutErrorTitle => 'Commande non passée';

  @override
  String get removeFromCart => 'Retirer du panier';

  @override
  String get checkoutDeliveryTitle => 'Adresse de livraison';

  @override
  String get checkoutAddressLabel => 'Adresse';

  @override
  String get checkoutPhoneLabel => 'Téléphone';

  @override
  String get checkoutNoteLabel => 'Note de livraison (optionnel)';

  @override
  String get checkoutItemsTitle => 'Articles';

  @override
  String get placeOrder => 'Passer la commande';

  @override
  String get placingOrder => 'Commande en cours…';

  @override
  String get confirmationTitle => 'Commande confirmée';

  @override
  String get confirmationHeadline => 'Merci, votre commande est enregistrée.';

  @override
  String get confirmationBody =>
      'Les vendeurs ont reçu votre demande. Vous serez notifié à chaque étape de la livraison.';

  @override
  String get confirmationNextTitle => 'Et maintenant ?';

  @override
  String get confirmationStepSeller => 'Le vendeur prépare vos produits';

  @override
  String get confirmationStepDriver => 'Un livreur est assigné à la livraison';

  @override
  String get confirmationStepDelivered => 'Vous recevez vos produits';

  @override
  String get confirmationTrackOrder => 'Suivre ma commande';

  @override
  String get confirmationContinueShopping => 'Continuer mes achats';

  @override
  String productPricePerUnit(String unit) {
    return '/ $unit';
  }

  @override
  String productAlreadyInCart(int count) {
    return 'Déjà dans le panier · $count';
  }

  @override
  String get validationAddressRequired => 'Veuillez saisir une adresse.';

  @override
  String get validationPhoneRequired =>
      'Veuillez saisir votre numéro de téléphone.';

  @override
  String get validationPhoneInvalid => 'Numéro de téléphone invalide.';

  @override
  String get orderDetailTitle => 'Détail de la commande';

  @override
  String get orderItemsLabel => 'Articles commandés';

  @override
  String get buyerEmailLabel => 'E-mail de l\'acheteur';

  @override
  String get orderDateLabel => 'Date de commande';

  @override
  String get orderNotFound => 'Commande introuvable.';

  @override
  String orderNumber(String id) {
    return 'Commande $id';
  }

  @override
  String orderNumberItems(int count) {
    return '$count article(s)';
  }

  @override
  String get placedOn => 'Passée le';

  @override
  String get orderCancelled => 'Cette commande a été annulée.';

  @override
  String get trackingTitle => 'Suivi de livraison';

  @override
  String trackingStepOf(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get trackingStepDone => 'Fait';

  @override
  String get statusOrderInTransit => 'En transit';

  @override
  String get statusOrderDelivered => 'Livrée';

  @override
  String get driverTitle => 'Livreur';

  @override
  String get driverAssignedLater =>
      'Un chauffeur sera assigné après confirmation de la commande.';

  @override
  String get contactDriver => 'Contacter le chauffeur';

  @override
  String get copyNumber => 'Copier le numéro';

  @override
  String get phoneCopied => 'Numéro copié.';

  @override
  String get deliveryInfoLabel => 'Informations de livraison';

  @override
  String get deliveryAddressLabel => 'Adresse de livraison';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get noteLabel => 'Note';

  @override
  String get orderDeliveryStatusLabel => 'Statut de la livraison';

  @override
  String get sellerLabel => 'Vendeur';

  @override
  String get driverStatusPickUp => 'À ramasser';

  @override
  String get driverStatusInTransit => 'En cours';

  @override
  String get driverStatusDelivered => 'Livrée';

  @override
  String get driverStatToCollect => 'À livrer';

  @override
  String get driverRecentDeliveries => 'Livraisons récentes';

  @override
  String get driverUpcomingTrips => 'Trajets à venir';

  @override
  String get tripStatusUpcoming => 'À venir';

  @override
  String get tripStatusActive => 'En cours';

  @override
  String get tripStatusCompleted => 'Terminé';

  @override
  String get driverStartDelivery => 'Démarrer la livraison';

  @override
  String get driverStartingDelivery => 'Démarrage…';

  @override
  String get driverMarkDelivered => 'Marquer comme livrée';

  @override
  String get driverMarkingDelivered => 'Finalisation…';

  @override
  String get driverDeliveryStarted => 'Livraison démarrée.';

  @override
  String get driverDeliveryDelivered => 'Livraison terminée avec succès.';

  @override
  String get driverActionError => 'L\'action n\'a pas abouti.';

  @override
  String get driverActionHint =>
      'Le statut réel n\'a pas été mis à jour automatiquement. Vérifiez-le avant toute nouvelle action.';

  @override
  String get driverDetailTitle => 'Détail de la livraison';

  @override
  String get driverRouteTitle => 'Itinéraire';

  @override
  String get driverPickupLabel => 'Point de collecte';

  @override
  String get driverScheduledLabel => 'Programmée le';

  @override
  String get driverContactCustomer => 'Contacter le client';

  @override
  String get driverCustomerLabel => 'Client';

  @override
  String get driverDeliveriesEmptyTitle => 'Aucune livraison';

  @override
  String get driverDeliveriesEmptyBody => 'Vos livraisons apparaîtront ici.';

  @override
  String get driverTripsEmptyTitle => 'Aucun trajet';

  @override
  String get driverTripsEmptyBody => 'Vos trajets apparaîtront ici.';

  @override
  String get driverNoUpcomingTripTitle => 'Aucun trajet à venir';

  @override
  String get driverNoUpcomingTripBody =>
      'Vos tournées terminées restent dans l\'historique.';

  @override
  String get driverDeliveryNotFound => 'Livraison introuvable.';

  @override
  String get driverHeroSubtitle =>
      'Vos tournées et vos livraisons, au même endroit.';

  @override
  String get driverQuickDeliveries => 'Mes livraisons';

  @override
  String get driverQuickActiveDelivery => 'Ma livraison active';

  @override
  String get driverQuickHistory => 'Historique';

  @override
  String driverActiveDeliveriesCount(int count) {
    return '$count livraison(s) en cours';
  }

  @override
  String get driverNoActiveDelivery => 'Aucune livraison en cours';

  @override
  String get driverLoadingDeliveries => 'Chargement de vos livraisons…';

  @override
  String tripStopsProgress(int completed, int total) {
    return '$completed / $total arrêts livrés';
  }

  @override
  String get adminStatusPickUp => 'À récupérer';

  @override
  String get adminStatusInTransit => 'En transit';

  @override
  String get adminStatusDelivered => 'Livrée';

  @override
  String get adminStatusCancelled => 'Annulée';

  @override
  String get adminDeliveriesTitle => 'Livraisons';

  @override
  String get adminDeliveriesSearch => 'Rechercher une livraison…';

  @override
  String get adminDeliveriesEmptyTitle => 'Aucune livraison';

  @override
  String get adminDeliveriesEmptyBody =>
      'Les livraisons sous supervision apparaîtront ici.';

  @override
  String get adminDeliveryNotFound => 'Livraison introuvable.';

  @override
  String get adminDeliveryPickup => 'Collecte';

  @override
  String get adminDeliveryDestination => 'Destination';

  @override
  String get adminDeliveryDistance => 'Distance';

  @override
  String get adminDeliveryTracking => 'Suivi';

  @override
  String get adminDeliveryBaseFee => 'Frais de base';

  @override
  String get adminDeliveryTotalFee => 'Frais totaux';

  @override
  String get adminDeliveryMarkInTransit => 'Marquer en transit';

  @override
  String get adminDeliveryMarkDelivered => 'Marquer livrée';

  @override
  String get adminDeliveryAssignDriver => 'Assigner un chauffeur';

  @override
  String get adminDeliveryUpdated => 'Livraison mise à jour avec succès.';

  @override
  String get adminDeliveryAssigned => 'Livreur assigné avec succès.';

  @override
  String get adminDeliveryNoDriver => 'Aucun chauffeur';

  @override
  String get adminDeliveryAssignHint => 'Touchez pour assigner un chauffeur';

  @override
  String adminDeliveryDriverCaption(Object id) {
    return 'Livreur $id';
  }

  @override
  String get adminDeliveryDriverNameHint => 'Nom du chauffeur…';

  @override
  String get adminDeliveryAssignAction => 'Assigner';

  @override
  String get adminActionFailed => 'L\'opération a échoué. Veuillez réessayer.';

  @override
  String get adminFilterAll => 'Tous';

  @override
  String get adminModerationPending => 'En attente';

  @override
  String get adminModerationValidated => 'En ligne';

  @override
  String get adminModerationSuspended => 'Suspendu';

  @override
  String get adminModerationRejected => 'Rejeté';

  @override
  String get adminModerationArchived => 'Archivé';

  @override
  String get adminUsersSearchHint => 'Rechercher un compte…';

  @override
  String get adminUsersEmpty => 'Aucun compte ne correspond';

  @override
  String get adminUsersUpdated => 'Utilisateur mis à jour.';

  @override
  String get adminUserApprove => 'Approuver';

  @override
  String get adminUserRestrict => 'Restreindre';

  @override
  String get adminUserReactivate => 'Réactiver';

  @override
  String adminUserActivityCaption(int orders, int products) {
    String _temp0 = intl.Intl.pluralLogic(
      orders,
      locale: localeName,
      other: '$orders commandes',
      one: '1 commande',
      zero: 'Aucune commande',
    );
    String _temp1 = intl.Intl.pluralLogic(
      products,
      locale: localeName,
      other: '$products produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get adminProductsTitle => 'Gestion des produits';

  @override
  String get adminProductsSearchHint => 'Rechercher un produit…';

  @override
  String get adminProductsEmpty => 'Aucun produit ne correspond';

  @override
  String get adminProductsUpdated => 'Produit mis à jour.';

  @override
  String get adminProductsRejectTitle => 'Rejeter le produit';

  @override
  String get adminProductsRejectReasonHint => 'Motif du rejet…';

  @override
  String get adminProductsRejectAction => 'Rejeter';

  @override
  String get adminProductApprove => 'Approuver';

  @override
  String get adminProductArchive => 'Archiver';

  @override
  String get categoryCereals => 'Céréales';

  @override
  String get categoryVegetables => 'Légumes';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryTubers => 'Tubercules & racines';

  @override
  String get categorySpices => 'Épices';

  @override
  String get catalogSubtitle =>
      'Des produits frais, directement de nos producteurs partenaires.';

  @override
  String get catalogSearchClear => 'Effacer la recherche';

  @override
  String get catalogFiltersReset => 'Réinitialiser les filtres';

  @override
  String get catalogNoResultsTitle => 'Aucun produit ne correspond';

  @override
  String get catalogNoResultsBody =>
      'Essayez un autre mot-clé ou réinitialisez les filtres pour revoir tout le catalogue.';

  @override
  String catalogProductStock(Object count, Object unit) {
    return '$count $unit en stock';
  }

  @override
  String get adminConsoleLabel => 'Console d\'administration';

  @override
  String get adminConsoleSubtitle => 'Supervision de la plateforme';

  @override
  String get adminRefreshTooltip => 'Actualiser le tableau de bord';

  @override
  String get adminTodayLabel => 'Aujourd\'hui';

  @override
  String get adminOverviewTitle => 'Chiffres clés';

  @override
  String get adminStatRevenue => 'Chiffre d\'affaires';

  @override
  String get adminStatRevenueCaption =>
      'Toutes les commandes enregistrées par la plateforme';

  @override
  String get adminStatUsers => 'Utilisateurs';

  @override
  String get adminStatProducts => 'Produits';

  @override
  String get adminStatOrders => 'Commandes';

  @override
  String get adminStatDeliveries => 'Livraisons';

  @override
  String adminStatUsersCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes à valider',
      one: '1 compte à valider',
      zero: 'Aucun compte à valider',
    );
    return '$_temp0';
  }

  @override
  String adminStatProductsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits à modérer',
      one: '1 produit à modérer',
      zero: 'Aucun produit à modérer',
    );
    return '$_temp0';
  }

  @override
  String adminStatOrdersCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes à confirmer',
      one: '1 commande à confirmer',
      zero: 'Rien à confirmer',
    );
    return '$_temp0';
  }

  @override
  String adminStatDeliveriesCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livraisons en cours',
      one: '1 livraison en cours',
      zero: 'Aucune livraison en cours',
    );
    return '$_temp0';
  }

  @override
  String get adminAttentionTitle => 'À votre attention';

  @override
  String adminAttentionUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes en attente de validation',
      one: 'Compte en attente de validation',
    );
    return '$_temp0';
  }

  @override
  String adminAttentionProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits à modérer',
      one: 'Produit à modérer',
    );
    return '$_temp0';
  }

  @override
  String adminAttentionOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes en attente de confirmation',
      one: 'Commande en attente de confirmation',
    );
    return '$_temp0';
  }

  @override
  String adminAttentionDeliveries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livraisons en cours',
      one: 'Livraison en cours',
    );
    return '$_temp0';
  }

  @override
  String get adminAttentionClearTitle => 'Rien ne requiert votre attention';

  @override
  String get adminAttentionClearBody =>
      'Aucun compte, produit ou commande n\'attend de décision.';

  @override
  String get distributionEmpty => 'Rien à répartir pour le moment';

  @override
  String get adminQuickActionsTitle => 'Accès rapide';

  @override
  String get adminQuickActionProducts => 'Produits';

  @override
  String get adminQuickActionUsers => 'Utilisateurs';

  @override
  String get adminQuickActionDeliveries => 'Livraisons';

  @override
  String get adminQuickActionAnalytics => 'Statistiques';

  @override
  String get adminDistributionTitle => 'Répartition';

  @override
  String get adminDistributionOrders => 'Commandes par statut';

  @override
  String get adminDistributionDeliveries => 'Livraisons par statut';

  @override
  String get adminDistributionUsers => 'Utilisateurs par rôle';

  @override
  String get adminDistributionProducts => 'Produits par statut';

  @override
  String get adminAnalyticsTitle => 'Statistiques de la plateforme';

  @override
  String get adminAnalyticsSubtitle =>
      'Indicateurs calculés à partir des données de la console d\'administration.';

  @override
  String get adminAnalyticsVolumeTitle => 'Volume de la plateforme';

  @override
  String get adminAnalyticsIndicatorsTitle => 'Indicateurs de suivi';

  @override
  String get adminAnalyticsPublished => 'Produits publiés';

  @override
  String get adminAnalyticsActiveOrders => 'Commandes actives';

  @override
  String get adminAnalyticsCompletedDeliveries => 'Livraisons terminées';

  @override
  String get adminAnalyticsEmpty => 'Aucune donnée à analyser pour le moment';

  @override
  String get adminAnalyticsNoHistory =>
      'L\'historique et les séries temporelles ne sont pas disponibles : la console d\'administration n\'enregistre pas encore d\'historique.';

  @override
  String get adminModerationTitle => 'Produits à modérer';

  @override
  String get adminModerationEmpty => 'Aucun produit n\'attend de décision';

  @override
  String get adminRecentOrdersTitle => 'Dernières commandes';

  @override
  String get adminRecentOrdersEmpty => 'Aucune commande enregistrée';

  @override
  String adminOrderBuyerCaption(String buyer, String amount) {
    return '$buyer · $amount';
  }

  @override
  String get adminSectionLoadError => 'Cette section n\'a pas pu être chargée';

  @override
  String adminSectionLoadErrorDetail(String message) {
    return '$message';
  }

  @override
  String get adminOrdersSearchHint => 'Rechercher une commande…';

  @override
  String get adminOrdersEmptyTitle => 'Aucune commande';

  @override
  String get adminOrdersEmptyBody =>
      'Les commandes enregistrées apparaîtront ici.';

  @override
  String adminOrderArticlesCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String get adminOrderDetailTitle => 'Détail de la commande';

  @override
  String get adminOrderNotFound => 'Commande introuvable.';

  @override
  String get adminOrderPlacedAt => 'Passée le';

  @override
  String get adminOrderBuyerLabel => 'Acheteur';

  @override
  String get adminOrderSellerLabel => 'Vendeur';

  @override
  String adminOrderAccountCaption(String id) {
    return 'Compte $id';
  }

  @override
  String get adminOrderAmountLabel => 'Montant';

  @override
  String get adminOrderItemsTitle => 'Articles';

  @override
  String get adminOrderItemsEmpty =>
      'Aucune ligne d\'article disponible pour cette commande.';

  @override
  String get adminOrderLinkedDelivery => 'Livraison liée';

  @override
  String get adminOrderStatusLockedTitle => 'Changement de statut indisponible';

  @override
  String get adminOrderStatusLockedBody =>
      'Le workflow de transition des commandes n\'est pas encore défini. La consultation de la commande reste disponible.';

  @override
  String get navMore => 'Plus';

  @override
  String get navHome => 'Accueil';

  @override
  String get superAdminConsoleSubtitle =>
      'Supervision globale de la plateforme AgriConnect.';

  @override
  String get superAdminRefreshTooltip => 'Actualiser la console';

  @override
  String get superAdminConsoleLabel => 'Console plateforme';

  @override
  String get superAdminTodayLabel => 'Aujourd\'hui';

  @override
  String get superAdminOverviewTitle => 'Vue d\'ensemble';

  @override
  String get superAdminStatUsers => 'Utilisateurs';

  @override
  String superAdminStatUsersCaption(int count) {
    return '$count en attente de vérification';
  }

  @override
  String get superAdminStatStaff => 'Équipe';

  @override
  String get superAdminStatStaffCaption => 'Comptes actifs sur la plateforme';

  @override
  String get superAdminStatProducts => 'Produits';

  @override
  String superAdminStatProductsCaption(int count) {
    return '$count produits publiés';
  }

  @override
  String get superAdminStatDeliveries => 'Livraisons';

  @override
  String superAdminStatDeliveriesCaption(int count) {
    return '$count en cours actuellement';
  }

  @override
  String get superAdminStatGmv => 'Volume d\'affaires';

  @override
  String get superAdminStatGmvCaption => 'Total des commandes enregistrées';

  @override
  String get superAdminAttentionTitle => 'Supervision requise';

  @override
  String get superAdminAttentionModeration => 'Produits à modérer';

  @override
  String get superAdminAttentionUsers => 'Comptes à vérifier';

  @override
  String get superAdminAttentionDeliveries => 'Livraisons en cours';

  @override
  String get superAdminAttentionClearTitle =>
      'La plateforme ne demande aucune action';

  @override
  String get superAdminAttentionClearBody =>
      'Aucun produit, compte ni livraison n\'attend de décision.';

  @override
  String get superAdminQuickActionsTitle => 'Accès rapide';

  @override
  String get superAdminQuickActionStaff => 'Équipe';

  @override
  String get superAdminQuickActionPlatform => 'Plateforme';

  @override
  String get superAdminQuickActionAnalytics => 'Statistiques';

  @override
  String get superAdminDistributionTitle => 'Répartition';

  @override
  String get superAdminDistributionStaff => 'Équipe par niveau d\'accès';

  @override
  String get superAdminActivityTitle => 'Activité récente';

  @override
  String get superAdminActivityEmpty => 'Aucune activité enregistrée';

  @override
  String superAdminActivityActor(String actor, String action) {
    return '$actor — $action';
  }

  @override
  String get superAdminSectionLoadError =>
      'Cette section n\'a pas pu être chargée';

  @override
  String superAdminSectionLoadErrorDetail(String message) {
    return '$message';
  }

  @override
  String get superAdminStaffTitle => 'Gestion de l\'équipe';

  @override
  String get superAdminStaffSubtitle =>
      'Comptes de l\'équipe et droits accordés';

  @override
  String get superAdminStaffSearchHint => 'Rechercher un membre';

  @override
  String get superAdminStaffSearchLabel => 'Rechercher dans l\'équipe';

  @override
  String get superAdminStaffEmpty =>
      'Aucun membre ne correspond à cette recherche';

  @override
  String get superAdminStaffFilterRole => 'Rôle';

  @override
  String get superAdminStaffFilterStatus => 'Statut';

  @override
  String get superAdminStaffStatusActive => 'Actifs';

  @override
  String get superAdminStaffStatusSuspended => 'Suspendus';

  @override
  String get superAdminStaffReset => 'Réinitialiser';

  @override
  String superAdminStaffCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
      zero: 'Aucun membre',
    );
    return '$_temp0';
  }

  @override
  String superAdminStaffLastActive(String date) {
    return 'Actif $date';
  }

  @override
  String superAdminStaffPermissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count droits',
      one: '1 droit',
      zero: 'Aucun droit',
    );
    return '$_temp0';
  }

  @override
  String get superAdminStaffProtectedNotice =>
      'Ce compte ne peut pas être modifié depuis la console.';

  @override
  String get superAdminStaffAccessReadOnly => 'Lecture seule';

  @override
  String get superAdminStaffAccessFull => 'Accès complet';

  @override
  String get superAdminStaffAccessSuspended => 'Suspendu';

  @override
  String get superAdminStaffSuspend => 'Suspendre le compte';

  @override
  String get superAdminStaffRestore => 'Restaurer en lecture seule';

  @override
  String superAdminStaffPermissionsTitle(String name) {
    return 'Droits de $name';
  }

  @override
  String get superAdminStaffPermissionsSubtitle =>
      'Le droit sur les paramètres reste réservé au Root.';

  @override
  String get superAdminStaffPermissionsSave => 'Enregistrer les droits';

  @override
  String get superAdminStaffPermissionsSaved => 'Droits mis à jour';

  @override
  String get superAdminStaffSuspended => 'Compte suspendu';

  @override
  String get superAdminStaffRestored => 'Compte restauré en lecture seule';

  @override
  String get superAdminPermissionMarketplace => 'Place de marché';

  @override
  String get superAdminPermissionPeople => 'Utilisateurs';

  @override
  String get superAdminPermissionPlatform => 'Plateforme';

  @override
  String get superAdminPermissionModerateProducts => 'Modérer les produits';

  @override
  String get superAdminPermissionModerateProductsBody =>
      'Valider, refuser et archiver les produits.';

  @override
  String get superAdminPermissionManageUsers => 'Gérer les utilisateurs';

  @override
  String get superAdminPermissionManageUsersBody =>
      'Vérifier les comptes et appliquer les sanctions.';

  @override
  String get superAdminPermissionSuperviseDeliveries =>
      'Superviser les livraisons';

  @override
  String get superAdminPermissionSuperviseDeliveriesBody =>
      'Suivre les tournées et affecter les livreurs.';

  @override
  String get superAdminPermissionManageOrders => 'Traiter les commandes';

  @override
  String get superAdminPermissionManageOrdersBody =>
      'Passer les commandes au bon état.';

  @override
  String get superAdminPermissionViewAnalytics => 'Consulter les statistiques';

  @override
  String get superAdminPermissionViewAnalyticsBody =>
      'Lire les indicateurs de la plateforme.';

  @override
  String get superAdminPermissionManageSettings => 'Gérer les paramètres';

  @override
  String get superAdminPermissionManageSettingsBody =>
      'Modifier la configuration de la plateforme.';

  @override
  String get superAdminPermissionLocked => 'Réservé au Root';

  @override
  String get superAdminActionSuspended => 'a suspendu';

  @override
  String get superAdminActionRestored => 'a rétabli';

  @override
  String get superAdminActionUpdatedPermissions => 'a modifié les droits de';

  @override
  String get superAdminActionUpdatedSettings => 'a mis à jour';

  @override
  String get superAdminActionModeratedProduct => 'a modéré le produit';

  @override
  String get superAdminPlatformTitle => 'Paramètres système';

  @override
  String get superAdminPlatformSubtitle =>
      'Configuration appliquée à toute la plateforme';

  @override
  String get superAdminSettingRegistrations => 'Inscriptions ouvertes';

  @override
  String get superAdminSettingRegistrationsBody =>
      'Autorise ou bloque la création de nouveaux comptes.';

  @override
  String get superAdminSettingAutoModeration => 'Modération automatique';

  @override
  String get superAdminSettingAutoModerationBody =>
      'Publie les produits sans revue humaine préalable.';

  @override
  String get superAdminSettingAutoModerationWarning =>
      'Les produits seront visibles sans contrôle.';

  @override
  String get superAdminSettingMaintenance => 'Mode maintenance';

  @override
  String get superAdminSettingMaintenanceBody =>
      'Masque la place de marché aux utilisateurs.';

  @override
  String get superAdminSettingMaintenanceWarning =>
      'La place de marché sera inaccessible.';

  @override
  String get superAdminSettingSupportEmail => 'Email de support';

  @override
  String get superAdminSettingSupportEmailBody =>
      'Adresse affichée aux utilisateurs en cas de besoin.';

  @override
  String get superAdminSettingSupportEmailInvalid => 'Adresse email invalide.';

  @override
  String get superAdminSettingMaxUpload => 'Taille maximale des photos';

  @override
  String get superAdminSettingMaxUploadBody =>
      'En mégaoctets, appliquée aux produits.';

  @override
  String get superAdminSettingMaxUploadInvalid =>
      'La valeur doit être comprise entre 1 et 20 Mo.';

  @override
  String superAdminSettingUpdatedAt(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get superAdminSettingsSaved => 'Paramètres enregistrés';

  @override
  String get superAdminSettingsUnsaved =>
      'Modifications non enregistrées. Elles prendront effet à l\'enregistrement.';

  @override
  String get superAdminSettingsSave => 'Enregistrer les paramètres';

  @override
  String get superAdminSettingsSaveError =>
      'Les paramètres n\'ont pas pu être enregistrés.';

  @override
  String get superAdminAnalyticsTitle => 'Statistiques plateforme';

  @override
  String get superAdminAnalyticsSubtitle =>
      'Chiffres calculés sur l\'ensemble du marché';

  @override
  String get superAdminAnalyticsAudience => 'Répartition des comptes';

  @override
  String superAdminAnalyticsOrdersCaption(int count) {
    return '$count commandes au total';
  }

  @override
  String superAdminAnalyticsOpenOrdersCaption(int count) {
    return '$count commandes encore ouvertes';
  }

  @override
  String superAdminAnalyticsPublishedCaption(int count) {
    return '$count produits en ligne';
  }

  @override
  String get superAdminAnalyticsNoTrend =>
      'L\'historique n\'est pas encore disponible sur cette version de démonstration.';

  @override
  String get superAdminAnalyticsStaffCaption => 'Comptes de l\'équipe';

  @override
  String get superAdminStatOrders => 'Commandes';

  @override
  String get superAdminAnalyticsOpenOrders => 'Commandes ouvertes';

  @override
  String get superAdminAnalyticsStaffShare => 'Droits accordés à l\'équipe';

  @override
  String get sectionBuyerSupport => 'Support acheteur';

  @override
  String get sectionStockValidation => 'Validation du stock';

  @override
  String get sectionOrderProcessing => 'Traitement des commandes';

  @override
  String get sectionPaymentFollowup => 'Suivi des paiements';

  @override
  String get agentNavigationGroupOperations => 'Opérations';

  @override
  String get agentNavigationGroupSupport => 'Assistance';

  @override
  String get agentNavigationGroupFollowup => 'Suivi';

  @override
  String get agentConsoleSubtitle =>
      'Support acheteur, stock, commandes et paiements dans un seul espace.';

  @override
  String get agentRefreshTooltip => 'Actualiser l\'espace';

  @override
  String get agentTodayLabel => 'Aujourd\'hui';

  @override
  String get agentOverviewTitle => 'Vue d\'ensemble';

  @override
  String get agentQuickActionsTitle => 'Accès rapides';

  @override
  String get agentAttentionTitle => 'À traiter';

  @override
  String get agentAttentionClearTitle => 'Rien en attente';

  @override
  String get agentAttentionClearBody =>
      'Aucune demande ni dossier n\'attend de décision pour le moment.';

  @override
  String get agentNoCapabilitiesTitle => 'Aucun accès opérationnel';

  @override
  String get agentNoCapabilitiesBody =>
      'Aucune capacité agent n\'a encore été attribuée à votre compte.';

  @override
  String get agentLoading => 'Chargement de l\'espace…';

  @override
  String get agentRefreshing => 'Actualisation en cours…';

  @override
  String agentStaleQueueCount(String count) {
    return 'Dernière valeur connue : $count';
  }

  @override
  String get agentSectionLoadError => 'Cette section n\'a pas pu être chargée';

  @override
  String agentSectionLoadErrorDetail(String message) {
    return '$message';
  }

  @override
  String get agentAccessDeniedTitle => 'Accès non autorisé';

  @override
  String get agentAccessDeniedBody =>
      'Votre compte ne dispose pas de la capacité requise pour cette section.';

  @override
  String get agentActionError => 'L\'action n\'a pas pu être réalisée.';

  @override
  String get agentActionHint =>
      'Le statut réel n\'a pas été mis à jour automatiquement. Vérifiez-le avant toute nouvelle action.';

  @override
  String get agentSearchHint => 'Rechercher une référence ou un nom';

  @override
  String get agentFilterStatus => 'Statut';

  @override
  String get agentFilterAll => 'Tous';

  @override
  String get agentClearFilters => 'Réinitialiser';

  @override
  String agentResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers',
      one: '1 dossier',
      zero: 'Aucun dossier',
    );
    return '$_temp0';
  }

  @override
  String get agentEmptyTitle => 'Rien à afficher';

  @override
  String get agentEmptyBody => 'De nouveaux dossiers apparaîtront ici.';

  @override
  String get agentNoResultTitle => 'Aucun dossier correspondant';

  @override
  String get agentNoResultBody =>
      'Modifiez la recherche ou le filtre de statut.';

  @override
  String get agentDetailTitle => 'Détail du dossier';

  @override
  String get agentReferenceLabel => 'Référence';

  @override
  String get agentReceivedLabel => 'Reçu le';

  @override
  String get agentCloseAction => 'Fermer';

  @override
  String get agentBackToList => 'Retour à la liste';

  @override
  String get agentStatSupport => 'Demandes de support';

  @override
  String agentStatSupportCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes ouvertes',
      one: '1 demande ouverte',
      zero: 'Rien d\'ouvert',
    );
    return '$_temp0';
  }

  @override
  String get agentStatStock => 'Dossiers de stock';

  @override
  String agentStatStockCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers en attente',
      one: '1 dossier en attente',
      zero: 'Rien en attente',
    );
    return '$_temp0';
  }

  @override
  String get agentStatOrders => 'Commandes à traiter';

  @override
  String agentStatOrdersCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes à traiter',
      one: '1 commande à traiter',
      zero: 'Rien à traiter',
    );
    return '$_temp0';
  }

  @override
  String get agentStatPayments => 'Paiements à suivre';

  @override
  String agentStatPaymentsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paiements à suivre',
      one: '1 paiement à suivre',
      zero: 'Rien à suivre',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionSupport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes en attente de réponse',
      one: 'Demande en attente de réponse',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers de stock à valider',
      one: 'Dossier de stock à valider',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes à traiter',
      one: 'Commande à traiter',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionPayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paiements à relancer',
      one: 'Paiement à relancer',
    );
    return '$_temp0';
  }

  @override
  String get agentQuickSupport => 'Support acheteur';

  @override
  String get agentQuickStock => 'Validation du stock';

  @override
  String get agentQuickOrders => 'Traitement des commandes';

  @override
  String get agentQuickPayments => 'Suivi des paiements';

  @override
  String get agentSupportBuyerLabel => 'Acheteur';

  @override
  String get agentSupportSubjectLabel => 'Objet';

  @override
  String get agentSupportPriorityLabel => 'Priorité';

  @override
  String get agentSupportPriorityHigh => 'Haute';

  @override
  String get agentSupportPriorityNormal => 'Normale';

  @override
  String get agentSupportStatusOpen => 'Ouverte';

  @override
  String get agentSupportStatusInProgress => 'En cours';

  @override
  String get agentSupportStatusResolved => 'Résolue';

  @override
  String get agentSupportTakeAction => 'Prendre en charge';

  @override
  String get agentSupportResolveAction => 'Marquer comme résolue';

  @override
  String get agentSupportUpdated => 'Demande mise à jour.';

  @override
  String get agentSupportEmptyTitle => 'Aucune demande de support';

  @override
  String get agentSupportEmptyBody =>
      'Les demandes des acheteurs apparaîtront ici.';

  @override
  String get agentStockProductLabel => 'Produit';

  @override
  String get agentStockSupplierLabel => 'Fournisseur';

  @override
  String get agentStockLocationLabel => 'Localisation';

  @override
  String agentStockDeclaredQty(int quantity, String unit) {
    return '$quantity $unit déclarés';
  }

  @override
  String get agentStockStatusPending => 'En attente';

  @override
  String get agentStockStatusValidated => 'Validé';

  @override
  String get agentStockStatusRejected => 'Rejeté';

  @override
  String get agentStockValidateAction => 'Valider';

  @override
  String get agentStockRejectAction => 'Rejeter';

  @override
  String get agentStockUpdated => 'Dossier mis à jour.';

  @override
  String get agentStockEmptyTitle => 'Aucun dossier de stock';

  @override
  String get agentStockEmptyBody =>
      'Le stock déclaré à contrôler apparaîtra ici.';

  @override
  String get agentOrderBuyerLabel => 'Acheteur';

  @override
  String get agentOrderSellerLabel => 'Vendeur';

  @override
  String get agentOrderItemsLabel => 'Articles';

  @override
  String get agentOrderAmountLabel => 'Montant';

  @override
  String get agentOrderStatusAwaiting => 'À traiter';

  @override
  String get agentOrderStatusProcessing => 'En cours';

  @override
  String get agentOrderStatusProcessed => 'Traitée';

  @override
  String get agentOrderStartAction => 'Démarrer le traitement';

  @override
  String get agentOrderCompleteAction => 'Marquer comme traitée';

  @override
  String get agentOrderUpdated => 'Commande mise à jour.';

  @override
  String get agentOrderEmptyTitle => 'Aucune commande à traiter';

  @override
  String get agentOrderEmptyBody =>
      'Les commandes à faire avancer apparaîtront ici.';

  @override
  String get agentPaymentPayerLabel => 'Payeur';

  @override
  String get agentPaymentAmountLabel => 'Montant';

  @override
  String get agentPaymentMethodLabel => 'Moyen';

  @override
  String get agentPaymentDueLabel => 'Échéance';

  @override
  String get agentPaymentStatusDue => 'À relancer';

  @override
  String get agentPaymentStatusAwaiting => 'En attente de confirmation';

  @override
  String get agentPaymentStatusConfirmed => 'Confirmé';

  @override
  String get agentPaymentConfirmAction => 'Confirmer la réception';

  @override
  String get agentPaymentConfirmHelp =>
      'Ne confirmez qu\'une fois le paiement réellement reçu par la plateforme.';

  @override
  String get agentPaymentNotReceivedNotice =>
      'Ce paiement n\'est pas confirmé comme reçu.';

  @override
  String get agentPaymentUpdated => 'Paiement mis à jour.';

  @override
  String get agentPaymentEmptyTitle => 'Aucun paiement à suivre';

  @override
  String get agentPaymentEmptyBody =>
      'Les paiements à suivre apparaîtront ici.';

  @override
  String get migrationInProgress => 'AgriConnect — migration en cours';
}
