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
  String get socketReconnecting => 'Reconnexion…';

  @override
  String get notificationMessageTitle => 'Nouveau message';

  @override
  String get notificationMessageBody =>
      'Vous avez reçu une réponse dans une conversation.';

  @override
  String get notificationDeliveryAvailableTitle =>
      'Nouvelle livraison disponible';

  @override
  String get notificationDeliveryAvailableBody =>
      'Une livraison est disponible pour votre agence.';

  @override
  String get notificationDeliveryStatusTitle => 'Mise à jour de livraison';

  @override
  String get notificationDeliveryStatusBody =>
      'Le statut de votre livraison a changé.';

  @override
  String get notificationExpiringTitle => 'Alerte de péremption';

  @override
  String get notificationExpiringBody =>
      'Un lot approche de sa date de péremption.';

  @override
  String get notificationAiSuggestionTitle => 'Suggestion IA';

  @override
  String get notificationAiSuggestionBody =>
      'Une suggestion est disponible dans la file de support.';

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
      'Les nouveaux messages et les événements importants apparaîtront ici.';

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
  String get notificationDriverDeliveryTitle =>
      'Exemple de livraison attribuée';

  @override
  String get notificationDriverDeliveryBody =>
      'Une livraison de démonstration est disponible dans votre liste.';

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
  String get dashboardManageProducts => 'Gérer mes produits';

  @override
  String get dashboardRefreshTooltip => 'Rafraîchir le tableau de bord';

  @override
  String get dashboardQuickAddProduct => 'Ajouter un produit';

  @override
  String get dashboardQuickExplore => 'Explorer les produits';

  @override
  String get dashboardQuickMyOrders => 'Mes commandes';

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
  String get chatStartConversation => 'Écrire un message';

  @override
  String get chatConversationSubject => 'Conversation avec l’équipe';

  @override
  String get chatStatusOpen => 'En cours';

  @override
  String get chatStatusWaiting => 'En attente de votre réponse';

  @override
  String get chatStatusClosed => 'Terminée';

  @override
  String get chatClosedExplanation =>
      'Cette conversation est terminée. Vous ne pouvez plus envoyer de message.';

  @override
  String get chatLoadOlder => 'Charger les messages précédents';

  @override
  String get chatAiBadge => 'IA';

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
  String get catalogEmptyTitle => 'Aucune annonce disponible';

  @override
  String get catalogEmptyBody => 'Les annonces publiées apparaîtront ici.';

  @override
  String get searchCatalog => 'Rechercher une annonce';

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
  String get quantityLabel => 'Quantité';

  @override
  String itemsCount(int count) {
    return '$count article(s)';
  }

  @override
  String productPricePerUnit(String unit) {
    return '/ $unit';
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
  String get driverDeliveryNotFound => 'Livraison introuvable.';

  @override
  String get driverHeroSubtitle =>
      'Vos courses disponibles et vos livraisons, au même endroit.';

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
  String get driverAvailableTab => 'Disponibles';

  @override
  String get driverMineTab => 'Mes courses';

  @override
  String get driverAccountTab => 'Compte';

  @override
  String get driverActiveCourse => 'Course en cours';

  @override
  String get driverAvailableEmptyTitle => 'Aucune course disponible';

  @override
  String get driverAvailableEmptyBody =>
      'Les nouvelles courses de votre agence apparaîtront ici.';

  @override
  String get driverMineEmptyTitle => 'Aucune course';

  @override
  String get driverMineEmptyBody =>
      'Vos courses acceptées et terminées apparaîtront ici.';

  @override
  String get driverFilterStatus => 'Filtrer par statut';

  @override
  String get allStatuses => 'Tous les statuts';

  @override
  String get loadMore => 'Charger la suite';

  @override
  String get driverAccept => 'Accepter';

  @override
  String get driverAccepting => 'Acceptation…';

  @override
  String get driverUpdating => 'Mise à jour…';

  @override
  String get driverAlreadyActive => 'Terminez d\'abord votre course en cours.';

  @override
  String get driverAlreadyTaken => 'Cette course vient d\'être prise.';

  @override
  String get driverPickupAddress => 'Adresse de retrait';

  @override
  String get driverDropoffAddress => 'Adresse de livraison';

  @override
  String get driverDistance => 'Distance';

  @override
  String get driverItems => 'Articles';

  @override
  String get driverOpenMap => 'Ouvrir l\'itinéraire';

  @override
  String get driverCallBuyer => 'Appeler l\'acheteur';

  @override
  String get driverBuyerUnavailable =>
      'Les coordonnées de l\'acheteur ne sont pas disponibles.';

  @override
  String get driverFailureAction => 'Échec de livraison';

  @override
  String get driverFailureReason => 'Motif';

  @override
  String get driverFailureReasonHint =>
      'Expliquez pourquoi la livraison a échoué.';

  @override
  String get driverFailureReasonRequired => 'Saisissez un motif obligatoire.';

  @override
  String get driverLaunchError => 'Impossible d\'ouvrir cette application.';

  @override
  String get driverMarkPickedUp => 'Confirmer le retrait';

  @override
  String get driverStartTransit => 'Démarrer le trajet';

  @override
  String get deliveryStatusPending => 'En attente';

  @override
  String get deliveryStatusAccepted => 'Acceptée';

  @override
  String get deliveryStatusPickedUp => 'Retirée';

  @override
  String get deliveryStatusInTransit => 'En transit';

  @override
  String get deliveryStatusDelivered => 'Livrée';

  @override
  String get deliveryStatusFailed => 'Échec';

  @override
  String get deliveryStatusCancelled => 'Annulée';

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
    return '$count $unit disponible(s)';
  }

  @override
  String get buyerCatalogTab => 'Catalogue';

  @override
  String get buyerOrdersTab => 'Commandes';

  @override
  String get catalogSortLabel => 'Trier';

  @override
  String get catalogSortPrice => 'Prix';

  @override
  String get catalogSortExpiry => 'Péremption';

  @override
  String get catalogSortRecent => 'Plus récents';

  @override
  String catalogQualityGrade(String grade) {
    return 'Qualité $grade';
  }

  @override
  String catalogExpiry(String date) {
    return 'À consommer avant le $date';
  }

  @override
  String get catalogListingDetail => 'Détail de l\'annonce';

  @override
  String get catalogListingUnavailable =>
      'Cette annonce n\'est plus disponible.';

  @override
  String get catalogRequestQuote => 'Demander un devis';

  @override
  String get quoteQuantityHint => 'Quantité souhaitée';

  @override
  String get quoteMessageHint => 'Message complémentaire (facultatif)';

  @override
  String quoteRequestMessage(
    String quantity,
    String unit,
    String title,
    String reference,
  ) {
    return 'Bonjour, je souhaite $quantity $unit de « $title » ($reference).';
  }

  @override
  String get quoteRequestInvalidQuantity =>
      'Saisissez une quantité supérieure à zéro.';

  @override
  String get buyerOrdersEmptyMessage =>
      'Les devis proposés par l\'équipe apparaîtront ici.';

  @override
  String get buyerOrderActionRequired => 'Action requise';

  @override
  String get buyerOrderQuoted => 'Devis';

  @override
  String buyerQuoteExpiresIn(String time) {
    return 'Expire dans $time';
  }

  @override
  String get buyerQuoteExpired => 'Devis expiré';

  @override
  String get buyerConfirmQuote => 'Confirmer le devis';

  @override
  String get buyerCancelQuote => 'Annuler le devis';

  @override
  String get buyerConfirmQuoteQuestion => 'Confirmer ce devis ?';

  @override
  String get buyerCancelQuoteQuestion => 'Annuler ce devis ?';

  @override
  String get buyerCancellationReasonHint => 'Motif (facultatif)';

  @override
  String get buyerStatusQuoted => 'Devis proposé';

  @override
  String get buyerStatusConfirmed => 'Confirmée';

  @override
  String get buyerStatusPreparing => 'En préparation';

  @override
  String get buyerStatusReadyForPickup => 'Prête au retrait';

  @override
  String get buyerStatusOutForDelivery => 'En livraison';

  @override
  String get buyerStatusCompleted => 'Terminée';

  @override
  String get buyerStatusCancelled => 'Annulée';

  @override
  String get buyerDeliveryModePickup => 'Retrait au point de collecte';

  @override
  String get buyerDeliveryModeAgency => 'Livraison par agence';

  @override
  String get buyerPickupAddress => 'Adresse du point de collecte';

  @override
  String get buyerDeliveryAddress => 'Adresse de livraison';

  @override
  String get buyerQuoteTotals => 'Montants indiqués par l\'équipe';

  @override
  String buyerOrderCancellationReason(String reason) {
    return 'Motif d\'annulation : $reason';
  }

  @override
  String get buyerOrderItems => 'Annonces du devis';

  @override
  String get buyerOrderSubtotalLabel => 'Sous-total';

  @override
  String get buyerOrderBuyerFeeLabel => 'Frais acheteur';

  @override
  String get buyerOrderDeliveryFeeLabel => 'Frais de livraison';

  @override
  String get buyerCancelOrder => 'Annuler';

  @override
  String get buyerCancelOrderQuestion => 'Annuler cette commande ?';

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

  @override
  String get configurationMissing => 'Configuration manquante';

  @override
  String get errUnauthorized =>
      'Votre session n\'est plus valide. Reconnectez-vous.';

  @override
  String get errProfileNotVerified =>
      'Votre profil doit être vérifié pour continuer.';

  @override
  String get errStateConflict =>
      'Cette information a changé. Actualisez puis réessayez.';

  @override
  String get roleHomeTab => 'Accueil';

  @override
  String get roleComingSoon => 'À venir';

  @override
  String get pageNotFound => 'Cette page est introuvable.';

  @override
  String get onboardingPageTitle => 'Bienvenue';

  @override
  String get loginPageTitle => 'Connexion';

  @override
  String get registerPageTitle => 'Créer un compte';

  @override
  String get forgotPasswordPageTitle => 'Mot de passe oublié';

  @override
  String get legalPageTitle => 'Informations légales';

  @override
  String get sessionExpiredNotice =>
      'Votre session a expiré. Reconnectez-vous.';

  @override
  String get sessionSuspendedNotice => 'Votre compte est suspendu.';

  @override
  String get sessionRevokedNotice => 'Votre session a été fermée.';

  @override
  String get authInvalidCredentials =>
      'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get authAccountSuspended =>
      'Ce compte a été suspendu. Contactez notre équipe.';

  @override
  String get authTooManyAttempts =>
      'Trop de tentatives. Veuillez patienter avant de réessayer.';

  @override
  String get authUnexpectedError =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get authNetworkError =>
      'Connexion impossible. Vérifiez votre réseau puis réessayez.';

  @override
  String get authForgotLink => 'Mot de passe oublié ?';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authRolePrompt => 'Comment souhaitez-vous utiliser AgriConnect ?';

  @override
  String get authSupplierChoice => 'Je vends (fournisseur)';

  @override
  String get authBuyerChoice => 'J\'achète (acheteur)';

  @override
  String get authLanguageLabel => 'Langue';

  @override
  String get authContinue => 'Continuer';

  @override
  String get authFirstName => 'Prénom';

  @override
  String get authLastName => 'Nom';

  @override
  String get authPhone => 'Téléphone';

  @override
  String get authLocation => 'Ville ou localité (facultatif)';

  @override
  String get authFarmName => 'Nom de l\'exploitation';

  @override
  String get authBuyerType => 'Type d\'acheteur';

  @override
  String get authBusinessName => 'Nom de l\'entreprise (facultatif)';

  @override
  String get authReferralCode => 'Code de parrainage (facultatif)';

  @override
  String get authBuyerRetailer => 'Détaillant';

  @override
  String get authBuyerFarmer => 'Agriculteur';

  @override
  String get authBuyerWholesaler => 'Grossiste';

  @override
  String get authBuyerOther => 'Autre';

  @override
  String get authPasswordHelp =>
      '8 caractères minimum, une minuscule, une majuscule, un chiffre et un caractère parmi @\$!%*?&. Quatre caractères identiques à la suite sont interdits.';

  @override
  String get authAcceptTerms => 'J\'accepte les';

  @override
  String get authGeneralTerms => 'Conditions générales d\'utilisation';

  @override
  String get authRoleTerms => 'conditions de consignation fournisseur';

  @override
  String get authBuyerTerms => 'conditions d\'achat';

  @override
  String get authTermsRequired =>
      'Veuillez accepter les deux documents pour continuer.';

  @override
  String get authRegistrationConflict =>
      'Cette adresse e-mail ou ce téléphone est déjà utilisé.';

  @override
  String get authCreate => 'Créer mon compte';

  @override
  String get authCreating => 'Création du compte…';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get authForgotIntro =>
      'Saisissez votre adresse e-mail. Si elle est associée à un compte, vous recevrez un lien de réinitialisation.';

  @override
  String get authSendReset => 'Envoyer le lien';

  @override
  String get authResetSent =>
      'Si cette adresse correspond à un compte, un lien de réinitialisation vient d\'être envoyé.';

  @override
  String get authBackToLogin => 'Retour à la connexion';

  @override
  String get authLegalUnavailable =>
      'Ce document n\'est pas disponible pour le moment.';

  @override
  String get authEmailUnverified =>
      'Veuillez vérifier votre adresse e-mail pour profiter de toutes les fonctionnalités.';

  @override
  String get authResendVerification => 'Renvoyer';

  @override
  String get authVerificationSent =>
      'Un nouveau lien de vérification a été envoyé.';

  @override
  String get authVerificationWait =>
      'Veuillez attendre 5 minutes avant de demander un autre lien.';

  @override
  String get authPasswordPolicyInvalid =>
      'Le mot de passe ne respecte pas les critères affichés.';

  @override
  String get authOnboardingSubtitle => 'Le marché agricole connecté';

  @override
  String get authValueInvalid => 'Cette valeur n\'est pas valide.';

  @override
  String get authOptional => 'Facultatif';

  @override
  String get accountTab => 'Compte';

  @override
  String get accountTitle => 'Mon compte';

  @override
  String get accountProfile => 'Profil';

  @override
  String get accountDocuments => 'Documents de vérification';

  @override
  String get accountPayoutAccounts => 'Comptes de paiement';

  @override
  String get accountReferral => 'Parrainage';

  @override
  String get accountSessions => 'Sessions et sécurité';

  @override
  String get accountLanguage => 'Langue';

  @override
  String get accountEmail => 'Adresse e-mail';

  @override
  String get accountLocation => 'Localisation';

  @override
  String get accountFirstName => 'Prénom';

  @override
  String get accountLastName => 'Nom';

  @override
  String get accountFarmName => 'Nom de l\'exploitation';

  @override
  String get accountDescription => 'Description';

  @override
  String get accountBusinessName => 'Nom commercial';

  @override
  String get accountBuyerType => 'Type d\'acheteur';

  @override
  String get accountZone => 'Zone';

  @override
  String get accountVehicleType => 'Type de véhicule';

  @override
  String get accountPlateNumber => 'Immatriculation';

  @override
  String get accountAvatarChange => 'Modifier la photo';

  @override
  String get accountSaveFailed =>
      'Impossible d\'enregistrer les modifications.';

  @override
  String get accountAvatarInvalid =>
      'Choisissez une image JPEG, PNG ou WebP de 5 Mo maximum.';

  @override
  String get accountVerificationTitle => 'Vérification du profil';

  @override
  String get accountVerificationUnverified =>
      'Vérifiez votre profil pour commencer.';

  @override
  String get accountVerificationPending =>
      'Votre profil est en cours d\'examen.';

  @override
  String get accountVerificationRejected =>
      'Votre profil a été refusé. Déposez un nouveau document.';

  @override
  String get accountVerificationVerified => 'Profil vérifié';

  @override
  String get accountDocumentsEmpty => 'Aucun document de vérification déposé.';

  @override
  String get accountDocumentType => 'Type de document';

  @override
  String get accountSelectDocument => 'Choisir un fichier';

  @override
  String get accountDocumentTooLarge =>
      'Le document ne doit pas dépasser 8 Mo.';

  @override
  String get accountDocumentInvalid =>
      'Choisissez un PDF ou une image JPEG, PNG ou WebP.';

  @override
  String get accountDocumentPendingLimit =>
      'Vous avez déjà cinq documents en attente d\'examen.';

  @override
  String get accountUploadDocument => 'Déposer le document';

  @override
  String get accountFileName => 'Fichier sélectionné';

  @override
  String get accountPayoutTitle => 'Comptes de paiement';

  @override
  String get accountAddPayout => 'Ajouter un compte';

  @override
  String get accountPayoutMethod => 'Mode de paiement';

  @override
  String get accountProvider => 'Opérateur ou banque';

  @override
  String get accountAccountNumber => 'Numéro de compte';

  @override
  String get accountAccountName => 'Nom du titulaire';

  @override
  String get accountDefault => 'Compte par défaut';

  @override
  String get accountNoPayout => 'Aucun compte de paiement enregistré.';

  @override
  String get accountDeleteConfirm => 'Supprimer ce compte de paiement ?';

  @override
  String get accountReferralTitle => 'Parrainez vos proches';

  @override
  String get accountReferralCode => 'Votre code de parrainage';

  @override
  String get accountCopyCode => 'Copier le code';

  @override
  String get accountCopied => 'Code copié.';

  @override
  String get accountReferralNotVerified =>
      'Les récompenses de parrainage seront disponibles après vérification de votre profil.';

  @override
  String get accountPending => 'En attente';

  @override
  String get accountEligible => 'Éligibles';

  @override
  String get accountPaid => 'Payées';

  @override
  String get accountNoReferrals => 'Aucun filleul pour le moment.';

  @override
  String get accountSessionsTitle => 'Sessions actives';

  @override
  String get accountCurrentSession => 'Cet appareil';

  @override
  String get accountCloseSession => 'Fermer la session';

  @override
  String get accountLogoutOthers => 'Déconnecter les autres appareils';

  @override
  String get accountLogoutOthersConfirm =>
      'Les autres sessions seront fermées. Cet appareil restera connecté.';

  @override
  String get accountLogoutOthersDone => 'Les autres sessions ont été fermées.';

  @override
  String get accountSessionCreated => 'Connecté le';

  @override
  String get accountSessionLastActive => 'Dernière activité';

  @override
  String get accountSessionExpires => 'Expire le';

  @override
  String get accountSessionIp => 'Adresse IP';

  @override
  String get accountLanguageTitle => 'Langue de l\'application';

  @override
  String get verificationRequiredTitle => 'Profil non vérifié';

  @override
  String get verificationRequiredMessage =>
      'Vérifiez votre profil pour accéder à cette fonctionnalité.';

  @override
  String get verificationOpenDocuments => 'Voir les documents';

  @override
  String get accountLoadError => 'Impossible de charger ces informations.';

  @override
  String get accountSearch => 'Rechercher';

  @override
  String get accountCategory => 'Catégorie';

  @override
  String get accountAllCategories => 'Toutes les catégories';

  @override
  String get accountNoResults => 'Aucun résultat.';

  @override
  String get accountDocumentsIntro =>
      'Déposez les pièces demandées pour faire vérifier votre profil.';

  @override
  String get accountDocumentUploaded => 'Document déposé pour vérification.';

  @override
  String get accountDocumentId => 'Pièce d\'identité';

  @override
  String get accountDocumentBusiness => 'Registre du commerce';

  @override
  String get accountDocumentFarm => 'Justificatif agricole';

  @override
  String get accountDocumentOther => 'Autre document';

  @override
  String get accountRejected => 'Refusé';

  @override
  String get accountEditPayout => 'Modifier le compte';

  @override
  String get accountSaved => 'Modifications enregistrées.';

  @override
  String get accountDeleted => 'Compte supprimé.';

  @override
  String get accountDeleteTitle => 'Supprimer le compte';

  @override
  String get accountCurrentNumber => 'Numéro enregistré';

  @override
  String get accountNumberInvalid =>
      'Saisissez un numéro de 4 à 64 caractères.';

  @override
  String get accountMobileMoney => 'Mobile Money';

  @override
  String get accountBankTransfer => 'Virement bancaire';

  @override
  String get accountCash => 'Espèces';

  @override
  String get accountEdit => 'Modifier';

  @override
  String get accountDelete => 'Supprimer';

  @override
  String get accountSessionClosed => 'Session fermée.';

  @override
  String get accountCloseSessionConfirm => 'Voulez-vous fermer cette session ?';

  @override
  String get accountUnknownDevice => 'Appareil inconnu';

  @override
  String get accountRetailer => 'Détaillant';

  @override
  String get accountFarmer => 'Agriculteur';

  @override
  String get accountWholesaler => 'Grossiste';

  @override
  String get accountOther => 'Autre';

  @override
  String get accountReferralBuyer => 'Acheteur';

  @override
  String get accountReferralSupplier => 'Fournisseur';

  @override
  String get accountStatusPending => 'En attente';

  @override
  String get accountStatusEligible => 'Éligible';

  @override
  String get accountStatusPaid => 'Payé';

  @override
  String get accountStatusRejected => 'Refusé';

  @override
  String get supplierLotsTab => 'Mes lots';

  @override
  String get supplierRevenueTab => 'Revenus';

  @override
  String get supplierLotDashboard => 'Vue d\'ensemble des lots';

  @override
  String get supplierDeclareLot => 'Déclarer un lot';

  @override
  String get supplierLotPendingCount => 'En attente d\'examen';

  @override
  String get supplierLotAvailableCount => 'Disponibles';

  @override
  String get supplierLotReservedCount => 'Réservés';

  @override
  String get supplierLotSoldCount => 'Épuisés';

  @override
  String get supplierAllStatuses => 'Tous les statuts';

  @override
  String get supplierLotStatusPending => 'En attente de validation';

  @override
  String get supplierLotStatusAvailable => 'Disponible';

  @override
  String get supplierLotStatusReserved => 'Entièrement réservé';

  @override
  String get supplierLotStatusSold => 'Épuisé';

  @override
  String get supplierLotStatusExpired => 'Expiré';

  @override
  String get supplierLotStatusReturned => 'Retourné';

  @override
  String get supplierLotStatusRejected => 'Refusé';

  @override
  String get supplierLotStatusWithdrawn => 'Retiré';

  @override
  String get supplierLotEmpty =>
      'Aucun lot pour le moment. Déclarez votre premier lot.';

  @override
  String get supplierLotProductStep => 'Produit';

  @override
  String get supplierLotQuantityStep => 'Quantité et prix';

  @override
  String get supplierLotStorageStep => 'Stockage et zone';

  @override
  String get supplierLotPhotosStep => 'Photos et détails';

  @override
  String get supplierLotNewTitle => 'Déclarer un lot';

  @override
  String get supplierLotEditTitle => 'Modifier le lot';

  @override
  String get supplierLotProduct => 'Produit';

  @override
  String get supplierLotQuantity => 'Quantité';

  @override
  String get supplierLotAgreedPrice => 'Prix unitaire convenu';

  @override
  String supplierLotUnitHint(String unit) {
    return 'Unité : $unit';
  }

  @override
  String get supplierLotZone => 'Zone';

  @override
  String get supplierLotStorageType => 'Stockage';

  @override
  String get supplierLotHubStorage => 'Dans un point de collecte';

  @override
  String get supplierLotSiteStorage => 'Sur mon exploitation';

  @override
  String get supplierLotHub => 'Point de collecte';

  @override
  String get supplierLotPickupAddress => 'Adresse d\'enlèvement';

  @override
  String get supplierLotLatitude => 'Latitude';

  @override
  String get supplierLotLongitude => 'Longitude';

  @override
  String get supplierUseLocation => 'Utiliser ma position';

  @override
  String get supplierLocationUnavailable =>
      'Position indisponible. Saisissez-la manuellement.';

  @override
  String get supplierLotChoosePhotos => 'Ajouter des photos';

  @override
  String get supplierLotPhotosRequired => 'Ajoutez entre 1 et 5 photos.';

  @override
  String get supplierLotPhotoTooLarge =>
      'Chaque photo doit faire 5 Mo maximum.';

  @override
  String get supplierLotHarvestedAt => 'Date de récolte (facultatif)';

  @override
  String get supplierLotExpiresAt => 'Date de péremption';

  @override
  String get supplierLotPackagingNote => 'Notes sur l\'emballage';

  @override
  String get supplierLotQualityNote => 'Notes sur la qualité';

  @override
  String get supplierLotNotesLimit => '500 caractères maximum.';

  @override
  String get supplierLotNext => 'Suivant';

  @override
  String get supplierLotPrevious => 'Retour';

  @override
  String get supplierLotSubmit => 'Envoyer le lot';

  @override
  String get supplierLotSubmitted => 'Lot envoyé pour validation.';

  @override
  String get supplierLotQuantityError =>
      'Saisissez une quantité supérieure à zéro, avec 3 décimales maximum.';

  @override
  String get supplierLotPriceError =>
      'Saisissez un prix convenu supérieur à zéro, avec 2 décimales maximum.';

  @override
  String get supplierLotSelectProduct => 'Choisissez un produit.';

  @override
  String get supplierLotSelectZone => 'Choisissez une zone.';

  @override
  String get supplierLotSelectHub => 'Choisissez un point de collecte.';

  @override
  String get supplierLotPickupRequired =>
      'Saisissez l\'adresse d\'enlèvement et des coordonnées valides.';

  @override
  String get supplierLotExpiryRequired =>
      'La date de péremption est obligatoire pour les produits périssables.';

  @override
  String get supplierLotNotesError =>
      'Les notes ne doivent pas dépasser 500 caractères.';

  @override
  String get supplierLotInitial => 'Quantité initiale';

  @override
  String get supplierLotAvailable => 'Quantité disponible';

  @override
  String get supplierLotReserved => 'Quantité réservée';

  @override
  String get supplierLotSold => 'Quantité vendue';

  @override
  String get supplierLotLost => 'Quantité perdue';

  @override
  String get supplierLotRejectionReason => 'Motif du refus';

  @override
  String get supplierLotContactTeam => 'Contacter l\'équipe';

  @override
  String supplierLotChatPrefill(String code) {
    return 'J\'ai une question au sujet du lot $code.';
  }

  @override
  String get supplierLotDelete => 'Supprimer le lot';

  @override
  String get supplierLotDeleteConfirm => 'Supprimer ce lot ?';

  @override
  String get supplierLotWithdraw => 'Retirer le lot';

  @override
  String get supplierLotWithdrawReason => 'Motif du retrait';

  @override
  String get supplierLotWithdrawError =>
      'Saisissez un motif de 500 caractères maximum.';

  @override
  String get supplierLotEdit => 'Modifier';

  @override
  String get supplierLotIncomePayouts => 'Reversements';

  @override
  String get supplierLotIncomeCompensations => 'Indemnisations';

  @override
  String get supplierIncomeEmpty => 'Aucun versement pour le moment.';

  @override
  String get supplierPayoutGross => 'Montant brut';

  @override
  String get supplierPayoutCommission => 'Commission';

  @override
  String get supplierPayoutNet => 'Montant net';

  @override
  String get supplierPayoutStatusOnHold => 'En attente';

  @override
  String get supplierPayoutStatusReady => 'Prêt';

  @override
  String get supplierPayoutStatusPaid => 'Payé';

  @override
  String get supplierPayoutStatusCancelled => 'Annulé';

  @override
  String get supplierCompensationReason => 'Motif';

  @override
  String get supplierCompensationQuantity => 'Quantité';

  @override
  String get supplierCompensationAmount => 'Montant';

  @override
  String get supplierCompensationNote => 'Note';

  @override
  String get supplierCompensationStatusPending => 'En attente d\'approbation';

  @override
  String get supplierCompensationStatusApproved => 'Approuvée';

  @override
  String get supplierCompensationStatusPaid => 'Payée';

  @override
  String get supplierCompensationStatusRejected => 'Refusée';

  @override
  String get supplierOptional => 'Facultatif';

  @override
  String get supplierClear => 'Effacer';

  @override
  String get supplierSave => 'Enregistrer';

  @override
  String get staffNoCapabilities =>
      'Aucune capacité attribuée, contactez un administrateur.';

  @override
  String get staffSupport => 'Support';

  @override
  String get staffStock => 'Stock';

  @override
  String get staffListings => 'Annonces';

  @override
  String get staffOrders => 'Commandes';

  @override
  String get staffVerifications => 'Vérifications';

  @override
  String get staffAccount => 'Compte';

  @override
  String get staffHelpAdmin =>
      'Contactez un administrateur pour obtenir vos accès.';

  @override
  String get staffInboxAll => 'Toutes';

  @override
  String get staffInboxUnassigned => 'Non assignées';

  @override
  String get staffInboxMine => 'Les miennes';

  @override
  String get staffInboxEscalated => 'Escaladées';

  @override
  String get staffStatusOpen => 'Ouverte';

  @override
  String get staffStatusWaiting => 'En attente du client';

  @override
  String get staffStatusClosed => 'Fermée';

  @override
  String get staffLoadMore => 'Charger la suite';

  @override
  String get staffBuyerSupport => 'Acheteur';

  @override
  String get staffSupplierSupport => 'Fournisseur';

  @override
  String get staffLotPending => 'À valider';

  @override
  String get staffLotAvailable => 'Disponible';

  @override
  String get staffLotReserved => 'Entièrement réservé';

  @override
  String get staffLotSoldOut => 'Épuisé';

  @override
  String get staffLotExpired => 'Expiré';

  @override
  String get staffLotReturned => 'Retourné';

  @override
  String get staffLotRejected => 'Rejeté';

  @override
  String get staffLotWithdrawn => 'Retiré';

  @override
  String get staffListingDraft => 'Brouillon';

  @override
  String get staffListingActive => 'En ligne';

  @override
  String get staffListingSold => 'Vendu';

  @override
  String get staffListingInactive => 'Masqué';

  @override
  String get staffSupportTypeDenied =>
      'Votre accès ne permet pas de traiter ce type de conversation.';

  @override
  String get staffConversationSubject => 'Conversation';

  @override
  String get staffAssign => 'S\'assigner';

  @override
  String get staffEscalate => 'Escalader';

  @override
  String get staffClose => 'Fermer';

  @override
  String get staffInternalNote => 'Note interne (invisible du client)';

  @override
  String get staffMessageHint => 'Écrire un message';

  @override
  String get staffSend => 'Envoyer';

  @override
  String get staffContext => 'Contexte';

  @override
  String get staffSuggestionReserved => 'Suggestion IA — bientôt disponible';

  @override
  String get staffValidate => 'Valider';

  @override
  String get staffReject => 'Rejeter';

  @override
  String get staffReturn => 'Retourner';

  @override
  String get staffQualityCheck => 'Contrôle qualité';

  @override
  String get staffSupplierNotVerified => 'Le fournisseur n\'est pas vérifié.';

  @override
  String get staffSupplierReview => 'Revue fournisseur';

  @override
  String get staffReason => 'Motif';

  @override
  String get staffGrade => 'Qualité';

  @override
  String get staffNotes => 'Notes';

  @override
  String get staffListingCreate => 'Créer une annonce';

  @override
  String get staffLotId => 'Identifiant du lot validé';

  @override
  String get staffTitle => 'Titre';

  @override
  String get staffDescription => 'Description';

  @override
  String get staffPrice => 'Prix unitaire';

  @override
  String get staffPhotosRequired => 'Sélectionnez entre 1 et 5 photos.';

  @override
  String get staffPhotoInvalid =>
      'Format photo non pris en charge ou fichier supérieur à 5 Mo.';

  @override
  String get staffStatusFilter => 'Statut';

  @override
  String get staffSupplierId => 'ID fournisseur';

  @override
  String get staffProductId => 'ID produit';

  @override
  String get staffPublish => 'Publier';

  @override
  String get staffUnpublish => 'Masquer';

  @override
  String get staffEdit => 'Modifier';

  @override
  String get staffCreate => 'Créer';

  @override
  String get staffNoData => 'Aucun élément pour le moment.';

  @override
  String get staffPriceBelowSupplier =>
      'Le prix ne peut pas être inférieur au prix convenu.';

  @override
  String get staffLotAlreadyLinked => 'Ce lot est déjà lié à une annonce.';

  @override
  String get staffLotNotAvailable => 'Ce lot n\'est pas disponible.';

  @override
  String get staffFileRequired => 'Ajoutez les photos requises.';

  @override
  String get staffCreateQuote => 'Créer un devis';

  @override
  String get staffNoOrders => 'Aucune commande à traiter.';

  @override
  String get staffOrderDetail => 'Détail de la commande';

  @override
  String get staffPaymentUnknown => 'Paiement inconnu';

  @override
  String get staffQuoteExpires => 'Devis valable jusqu\'au';

  @override
  String get staffSupplierUnitPrice => 'Prix fournisseur';

  @override
  String get staffCommission => 'Commission';

  @override
  String get staffSupplierNet => 'Net fournisseur';

  @override
  String get staffSubtotal => 'Sous-total';

  @override
  String get staffBuyerFee => 'Frais acheteur';

  @override
  String get staffDeliveryFee => 'Frais de livraison';

  @override
  String get staffOrderTotal => 'Total calculé par le serveur';

  @override
  String get staffConfirmQuote => 'Confirmer le devis';

  @override
  String get staffCancelOrder => 'Annuler la commande';

  @override
  String get staffPaymentRequired => 'Paiement requis avant la préparation.';

  @override
  String get staffPayments => 'Paiements';

  @override
  String get staffRecordPayment => 'Saisir un paiement';

  @override
  String get staffNoPayments => 'Aucun paiement enregistré.';

  @override
  String get staffAmount => 'Montant (XAF)';

  @override
  String get staffPaymentMethod => 'Mode de paiement';

  @override
  String get staffCash => 'Espèces';

  @override
  String get staffMobileMoney => 'Mobile Money';

  @override
  String get staffBankTransfer => 'Virement bancaire';

  @override
  String get staffReferenceOptional => 'Référence (facultative)';

  @override
  String get staffRefund => 'Rembourser';

  @override
  String get staffDeliveries => 'Livraisons';

  @override
  String get staffNoDeliveries => 'Aucune livraison créée.';

  @override
  String get staffAgency => 'Agence';

  @override
  String get staffPickup => 'Enlèvement';

  @override
  String get staffDropoff => 'Destination';

  @override
  String get staffAgencyCost => 'Coût agence';

  @override
  String get staffInsuredValue => 'Valeur assurée';

  @override
  String get staffReleaseDelivery => 'Libérer';

  @override
  String get staffRedispatchDelivery => 'Redispatcher';

  @override
  String get staffCancelDelivery => 'Annuler la livraison';

  @override
  String get staffReasonOptional => 'Motif (facultatif)';

  @override
  String get staffCreateDeliveries => 'Créer les livraisons';

  @override
  String get staffDeliveryUnknown => 'Statut de livraison inconnu';

  @override
  String get staffDeliveryAvailable => 'Livraison disponible';

  @override
  String get staffDeliveryUnavailable => 'Aucune livraison disponible';

  @override
  String get staffBuyer => 'Acheteur';

  @override
  String get staffActiveListing => 'Annonce active';

  @override
  String get staffQuantity => 'Quantité';

  @override
  String get staffUnitPriceOptional => 'Prix unitaire (facultatif)';

  @override
  String get staffRemoveLine => 'Retirer la ligne';

  @override
  String get staffAddLine => 'Ajouter une ligne';

  @override
  String get staffDeliveryMode => 'Mode de livraison';

  @override
  String get staffHubPickup => 'Retrait au point relais';

  @override
  String get staffAgencyDelivery => 'Livraison par agence';

  @override
  String get staffPickupHub => 'Point de retrait';

  @override
  String get staffDeliveryZone => 'Zone de livraison';

  @override
  String get staffAddress => 'Adresse de livraison';

  @override
  String get staffLatitude => 'Latitude';

  @override
  String get staffLongitude => 'Longitude';

  @override
  String get staffNotesOptional => 'Note (facultative)';

  @override
  String get staffServerCalculatesTotals =>
      'Les frais, commissions et totaux seront calculés par le serveur.';

  @override
  String get staffQuoteCreated => 'Devis créé.';

  @override
  String get staffDeadlineNotProvided => 'échéance non communiquée';

  @override
  String staffQuoteCreatedMessage(String deadline) {
    return 'Votre devis est prêt. Il est réservé jusqu\'au $deadline.';
  }

  @override
  String get staffDocumentStatus => 'Statut du document';

  @override
  String get staffDocumentType => 'Type de document';

  @override
  String get staffAccountRole => 'Rôle du compte';

  @override
  String get staffUserId => 'ID utilisateur';

  @override
  String get staffNoVerifications => 'Aucun document à examiner.';

  @override
  String get staffVerificationRuleApprove =>
      'Approuver vérifie le document. Le compte est vérifié s\'il a au moins un document vérifié et aucun document en attente.';

  @override
  String get staffVerificationRuleReject =>
      'Un refus rejette le compte uniquement s\'il n\'a aucun autre document vérifié.';

  @override
  String get staffFileMissing =>
      'Le fichier est introuvable. Actualisez le détail pour demander un nouveau lien.';

  @override
  String get staffUnsupportedDocument =>
      'Format de document non pris en charge.';

  @override
  String get staffOpenPrivatePdf => 'Ouvrir le PDF privé';

  @override
  String get staffApprove => 'Approuver';

  @override
  String get staffRejectionNote => 'Motif du refus (obligatoire)';

  @override
  String get staffHumanActorRequired =>
      'Cette action doit être effectuée par une personne.';

  @override
  String get staffInsufficientStock => 'Le stock disponible est insuffisant.';

  @override
  String get staffZoneNotCovered => 'La zone n\'est pas desservie.';

  @override
  String get staffInvalidHub => 'Le point de retrait n\'est pas valide.';

  @override
  String get staffCompensationRateZero =>
      'Le taux d\'indemnisation n\'est pas défini (à régler par ROOT).';

  @override
  String get staffPrivateFileWrongReviewer =>
      'Ce lien privé appartient à un autre compte relecteur ou a expiré. Actualisez le détail.';

  @override
  String get staffVerificationAlreadyReviewed =>
      'Ce document a déjà été examiné. La file a été actualisée.';

  @override
  String get staffStatusQuoted => 'Devis';

  @override
  String get staffStatusConfirmed => 'Confirmée';

  @override
  String get staffStatusPreparing => 'En préparation';

  @override
  String get staffStatusReadyForPickup => 'Prête au retrait';

  @override
  String get staffStatusOutForDelivery => 'En livraison';

  @override
  String get staffStatusCompleted => 'Terminée';

  @override
  String get staffStatusCancelled => 'Annulée';

  @override
  String get staffPositiveAmount => 'Saisissez un montant supérieur à zéro.';

  @override
  String get staffCompensate => 'Demander une indemnisation';

  @override
  String get staffReasonExpiredUnsold => 'Invendu périmé';

  @override
  String get staffReasonLostDamaged => 'Perdu ou endommagé';

  @override
  String get staffReasonOther => 'Autre';

  @override
  String get staffCompensationQuantity => 'Quantité à indemniser';

  @override
  String get staffLotQuantity => 'Quantité du lot';

  @override
  String get staffDeliveryIdOptional => 'ID de livraison (facultatif)';

  @override
  String get staffCompensationSubmitted => 'Demande d\'indemnisation envoyée.';

  @override
  String get staffPaymentUnpaid => 'Non payé';

  @override
  String get staffPaymentPartiallyPaid => 'Partiellement payé';

  @override
  String get staffPaymentPaid => 'Payé';

  @override
  String get staffPaymentRefunded => 'Remboursé';

  @override
  String get staffDeliveryPending => 'En attente';

  @override
  String get staffDeliveryAccepted => 'Acceptée';

  @override
  String get staffDeliveryPickedUp => 'Enlevée';

  @override
  String get staffDeliveryInTransit => 'En transit';

  @override
  String get staffDeliveryDelivered => 'Livrée';

  @override
  String get staffDeliveryFailed => 'Échec';

  @override
  String get staffDeliveryCancelled => 'Annulée';

  @override
  String get staffDocumentPending => 'En attente';

  @override
  String get staffDocumentVerified => 'Vérifié';

  @override
  String get staffDocumentRejected => 'Rejeté';

  @override
  String get staffDocumentIdCard => 'Pièce d\'identité';

  @override
  String get staffDocumentBusinessRegistration =>
      'Immatriculation de l\'entreprise';

  @override
  String get staffDocumentFarmProof => 'Justificatif d\'exploitation agricole';

  @override
  String get staffDocumentOther => 'Autre';

  @override
  String get staffInsurancePolicy => 'Police d\'assurance';

  @override
  String get staffPrivateDocumentOpenFailed =>
      'Impossible d\'ouvrir le document privé.';
}
