// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'The connected agricultural marketplace';

  @override
  String get splashLoading => 'Loading your workspace…';

  @override
  String get loginGreeting => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to access your workspace';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get demoAccountsTitle => 'Demo accounts';

  @override
  String get demoAccountsHint => 'Tap an account to pre-fill the form.';

  @override
  String get validationEmailRequired => 'Please enter your email address.';

  @override
  String get validationEmailInvalid => 'Invalid email address.';

  @override
  String get validationPasswordRequired => 'Please enter your password.';

  @override
  String get errInvalidCredentials => 'Invalid credentials. Please try again.';

  @override
  String get errNetwork => 'Network error. Check your connection.';

  @override
  String get errTimeout => 'The request timed out. Please retry.';

  @override
  String get errServer => 'Server error. Please retry later.';

  @override
  String get errCache => 'Unable to access local storage.';

  @override
  String get errUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errRoleNotAllowed =>
      'Creating an account for this role is not allowed.';

  @override
  String get errAccessDenied =>
      'Your session is not allowed to perform this action.';

  @override
  String get errSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get roleSupplier => 'Supplier';

  @override
  String get roleBuyer => 'Buyer';

  @override
  String get roleDriver => 'Driver';

  @override
  String get roleAgent => 'Agent';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleRoot => 'Root';

  @override
  String get sectionDashboard => 'Dashboard';

  @override
  String get sectionProducts => 'My products';

  @override
  String get sectionOrders => 'Orders';

  @override
  String get sectionProfile => 'Profile';

  @override
  String get sectionCatalog => 'Catalog';

  @override
  String get sectionDeliveries => 'Deliveries';

  @override
  String get sectionUsers => 'Users';

  @override
  String get sectionAnalytics => 'Analytics';

  @override
  String get sectionPlatform => 'Platform';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsMarkRead => 'Mark as read';

  @override
  String get socketReconnecting => 'Reconnecting…';

  @override
  String get notificationMessageTitle => 'New message';

  @override
  String get notificationMessageBody =>
      'You received a reply in a conversation.';

  @override
  String get notificationDeliveryAvailableTitle => 'New delivery available';

  @override
  String get notificationDeliveryAvailableBody =>
      'A delivery is available for your agency.';

  @override
  String get notificationDeliveryStatusTitle => 'Delivery update';

  @override
  String get notificationDeliveryStatusBody =>
      'The status of your delivery has changed.';

  @override
  String get notificationExpiringTitle => 'Expiry alert';

  @override
  String get notificationExpiringBody =>
      'A lot is approaching its expiry date.';

  @override
  String get notificationAiSuggestionTitle => 'AI suggestion';

  @override
  String get notificationAiSuggestionBody =>
      'A suggestion is available in the support queue.';

  @override
  String get notificationsRead => 'Read';

  @override
  String notificationsUnreadCount(String count) {
    return 'Unread: $count';
  }

  @override
  String get notificationsDemoNotice =>
      'Demonstration examples only. These are not live alerts and are not synchronized with a server.';

  @override
  String get notificationsEmptyTitle => 'You’re all caught up';

  @override
  String get notificationsEmptyBody =>
      'New messages and important events will appear here.';

  @override
  String get notificationsLoadError => 'Notifications could not be loaded.';

  @override
  String get notificationsCategoryOrders => 'Orders';

  @override
  String get notificationsCategoryProducts => 'Products';

  @override
  String get notificationsCategoryDeliveries => 'Deliveries';

  @override
  String get notificationsCategorySupport => 'Support';

  @override
  String get notificationsCategoryAdministration => 'Administration';

  @override
  String get notificationBuyerOrderTitle => 'Example order update';

  @override
  String get notificationBuyerOrderBody =>
      'A sample order status update is shown here.';

  @override
  String get notificationBuyerDeliveryTitle => 'Example delivery update';

  @override
  String get notificationBuyerDeliveryBody =>
      'A sample delivery progress update is shown here.';

  @override
  String get notificationDriverDeliveryTitle => 'Example assigned delivery';

  @override
  String get notificationDriverDeliveryBody =>
      'A sample delivery is available in your delivery list.';

  @override
  String get notificationAgentSupportTitle => 'Example support request';

  @override
  String get notificationAgentSupportBody =>
      'A sample buyer request is available in the support queue.';

  @override
  String get notificationAgentOrderTitle => 'Example order task';

  @override
  String get notificationAgentOrderBody =>
      'A sample order task is available for processing.';

  @override
  String get notificationAgentStockTitle => 'Example stock review';

  @override
  String get notificationAgentStockBody =>
      'A sample stock declaration is available for review.';

  @override
  String get notificationAdminProductTitle => 'Example product review';

  @override
  String get notificationAdminProductBody =>
      'A sample product is available in the moderation list.';

  @override
  String get notificationAdminOrderTitle => 'Example order activity';

  @override
  String get notificationAdminOrderBody =>
      'A sample order is available in the administration workspace.';

  @override
  String get notificationRootPlatformTitle => 'Example platform activity';

  @override
  String get notificationRootPlatformBody =>
      'A sample platform event is available in the platform console.';

  @override
  String get notificationRootStaffTitle => 'Example staff activity';

  @override
  String get notificationRootStaffBody =>
      'A sample staff event is available in the user directory.';

  @override
  String get underConstructionTitle => 'Section under construction';

  @override
  String get underConstructionBody =>
      'This section will be available in a coming stage of AgriConnect.';

  @override
  String get comingSoonBadge => 'Coming soon';

  @override
  String get routeNotFoundTitle => 'Page not found';

  @override
  String get routeNotFoundBody => 'The address you requested does not exist.';

  @override
  String get routeNotFoundHome => 'Back to home';

  @override
  String dashboardWelcome(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardSubtitle => 'Welcome to your workspace';

  @override
  String get dashboardQuickActions => 'Quick access';

  @override
  String get dashboardQuickOrders => 'Received orders';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out';

  @override
  String get signOutConfirmBody => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get connectedAs => 'Signed in as';

  @override
  String get accountInfo => 'Account information';

  @override
  String get profileEditAction => 'Edit profile';

  @override
  String get profileEditTitle => 'Edit your profile';

  @override
  String get profileEditDescription =>
      'Update the name displayed on your account.';

  @override
  String get profileSaveAction => 'Save changes';

  @override
  String get profileUpdated => 'Profile updated on this device.';

  @override
  String get profileDiscardTitle => 'Discard changes?';

  @override
  String get profileDiscardBody => 'Your unsaved name change will be lost.';

  @override
  String get profileDiscardAction => 'Discard';

  @override
  String get profileKeepEditingAction => 'Keep editing';

  @override
  String get profileNameInvalid =>
      'Enter a valid name between 2 and 80 characters.';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get capabilityBuyerSupport => 'Buyer support';

  @override
  String get capabilityStockValidation => 'Stock validation';

  @override
  String get capabilityOrderProcessing => 'Order processing';

  @override
  String get capabilityPaymentFollowup => 'Payment follow-up';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSlide1Title => 'A connected agricultural marketplace';

  @override
  String get onboardingSlide1Body =>
      'Buy and sell fresh, local produce directly between suppliers, buyers and traders.';

  @override
  String get onboardingSlide2Title => 'Trusted deliveries';

  @override
  String get onboardingSlide2Body =>
      'Reliable drivers move your goods, from the farm to the point of sale, with complete peace of mind.';

  @override
  String get onboardingSlide3Title => 'A community that connects you';

  @override
  String get onboardingSlide3Body =>
      'Suppliers, buyers, drivers and administrators united for transparent, efficient exchanges.';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change it at any time.';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get roleTitle => 'What is your profile?';

  @override
  String get roleSubtitle =>
      'Pick the role that matches you to personalize your experience.';

  @override
  String get roleSupplierDesc => 'I sell my agricultural products';

  @override
  String get roleBuyerDesc => 'I buy local products';

  @override
  String get roleDriverDesc => 'I deliver and transport goods';

  @override
  String get roleAgentDesc => 'I support users and the platform';

  @override
  String get roleAdminDesc => 'I manage users and the platform';

  @override
  String get roleRootDesc => 'I oversee the entire platform';

  @override
  String get loginSelectedRole => 'Selected profile';

  @override
  String get loginChangeRole => 'Change role';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Join the marketplace in seconds.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get registerCreate => 'Create my account';

  @override
  String get registerCreating => 'Creating…';

  @override
  String get registerAlreadyAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get validationNameRequired => 'Please enter your full name.';

  @override
  String get validationPasswordMismatch => 'Passwords do not match.';

  @override
  String get validationPasswordTooShort =>
      'The password must be at least 8 characters long.';

  @override
  String get validationNameTooShort =>
      'The name must be at least 2 characters long.';

  @override
  String get validationNameTooLong =>
      'The name is too long (maximum 80 characters).';

  @override
  String get errEmailExists =>
      'An account already exists with this email address.';

  @override
  String get errRoleMismatch =>
      'This email address is not associated with the selected role.';

  @override
  String get registerAsRoleTitle => 'You are registering as';

  @override
  String get retry => 'Retry';

  @override
  String get seeAll => 'See all';

  @override
  String get dashboardOverview => 'Overview';

  @override
  String get productStatusOnSale => 'On sale';

  @override
  String get productStatusOutOfStock => 'Out of stock';

  @override
  String get declarationStatusDraft => 'Draft';

  @override
  String get declarationStatusPendingReview => 'Pending review';

  @override
  String get declarationStatusAdditionalInfoRequired =>
      'Additional information required';

  @override
  String get declarationStatusUnderDiscussion => 'Under discussion';

  @override
  String get declarationStatusApprovedForPublication =>
      'Approved for publication';

  @override
  String get declarationStatusRejected => 'Rejected';

  @override
  String get declarationStatusSection => 'Declaration status';

  @override
  String get declarationDemoNotice =>
      'Demo states. In the final version, the AgriConnect team reviews every declaration and contacts you before any publication.';

  @override
  String get declarationSaveDraftAction => 'Save the draft';

  @override
  String get declarationSubmittedSnack =>
      'Declaration submitted. It will be reviewed before any publication.';

  @override
  String get declarationDraftSavedSnack =>
      'Draft saved. It is not visible to buyers.';

  @override
  String get supplierWelcomeTitle => 'Welcome to your supplier workspace';

  @override
  String supplierWelcomeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get supplierWelcomeBody =>
      'Declare your products in a few minutes. The AgriConnect team reviews every declaration and contacts you before any publication: nothing is published automatically.';

  @override
  String get supplierWelcomePrimary => 'Start declaring my products';

  @override
  String get supplierWelcomeSecondary => 'Go to my dashboard';

  @override
  String get buyerWelcomeTitle => 'Welcome to AgriConnect';

  @override
  String buyerWelcomeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get buyerWelcomeBody =>
      'Discover fresh products from local farmers and build your basket in a few minutes.';

  @override
  String get buyerWelcomePrimary => 'Browse the catalog';

  @override
  String get buyerWelcomeDismiss => 'Later';

  @override
  String get addProduct => 'New product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get saveProduct => 'Save product';

  @override
  String get savingProduct => 'Saving…';

  @override
  String get productSaved => 'Product saved successfully.';

  @override
  String get productsDeclaredStat => 'Declared products';

  @override
  String get statConfirmedOrders => 'Confirmed';

  @override
  String get ordersPendingStat => 'Awaiting confirmation';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyBody =>
      'Declare your first product. The AgriConnect team will review it before any publication.';

  @override
  String get productsNoResultTitle => 'No product found';

  @override
  String get productsNoResultBody => 'Change your search or switch the filter.';

  @override
  String get recentProducts => 'Recent products';

  @override
  String get recentOrders => 'Recent orders';

  @override
  String get dashboardManageProducts => 'Manage my products';

  @override
  String get dashboardRefreshTooltip => 'Refresh the dashboard';

  @override
  String get dashboardQuickAddProduct => 'Add a product';

  @override
  String get dashboardQuickExplore => 'Explore products';

  @override
  String get dashboardQuickMyOrders => 'My orders';

  @override
  String get buyerHeroSubtitle =>
      'The finest produce from the farm, delivered to you.';

  @override
  String get ordersPlacedStat => 'Orders placed';

  @override
  String get chatTitle => 'Messages';

  @override
  String get roleStaffBadge => 'Staff';

  @override
  String get chatEmptyTitle => 'No conversation yet';

  @override
  String get chatEmptyBody =>
      'Your exchanges with buyers and drivers will appear here.';

  @override
  String get chatThreadEmptyTitle => 'Start the conversation';

  @override
  String get chatThreadEmptyBody => 'Send a first message to kick things off.';

  @override
  String get chatComposerHint => 'Your message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatStartConversation => 'Write a message';

  @override
  String get chatConversationSubject => 'Conversation with the team';

  @override
  String get chatStatusOpen => 'Open';

  @override
  String get chatStatusWaiting => 'Waiting for your reply';

  @override
  String get chatStatusClosed => 'Closed';

  @override
  String get chatClosedExplanation =>
      'This conversation is closed. You can no longer send messages.';

  @override
  String get chatLoadOlder => 'Load earlier messages';

  @override
  String get chatAiBadge => 'AI';

  @override
  String productInStock(int quantity, String unit) {
    return '$quantity $unit in stock';
  }

  @override
  String get productNameLabel => 'Product name';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productPriceLabel => 'Price';

  @override
  String get productStockLabel => 'Available stock';

  @override
  String get productUnitLabel => 'Unit';

  @override
  String get productDeclaredOn => 'Declared on';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get productNotFoundBody =>
      'This product is no longer available. It may have been deleted.';

  @override
  String get productFormInfoSection => 'Product information';

  @override
  String get productFormPricingSection => 'Price and availability';

  @override
  String get productFormPhotosSection => 'Product photos';

  @override
  String get productFormPhotosHint =>
      'Add up to 5 photos. The first one becomes the main photo.';

  @override
  String get productFormPhotosEmpty => 'No photo yet';

  @override
  String get productFormReplacePhoto => 'Replace the photos';

  @override
  String get productFormRemovePhoto => 'Remove the photo';

  @override
  String get productFormPickingPhotos => 'Reading the photos…';

  @override
  String get productFormPhotoError =>
      'These photos could not be read. Try again.';

  @override
  String get productFormPublishAction => 'Submit the declaration';

  @override
  String get productFormUpdateAction => 'Submit the changes';

  @override
  String get productFormStatusSection => 'Visibility';

  @override
  String get productFormCreateHint =>
      'Fill in the product, its price and its stock. Your declaration will be reviewed before any publication.';

  @override
  String get productFormEditHint =>
      'Adjust the details, then submit your declaration again.';

  @override
  String get productFormStatusHint => 'The status follows the stock you enter.';

  @override
  String get productFormOutOfStockHint =>
      'A stock of 0 puts the product out of stock.';

  @override
  String get productFormSaveErrorTitle => 'The product was not saved';

  @override
  String get productFormValidationSummary =>
      'Fix the highlighted fields before saving.';

  @override
  String get discardChangesTitle => 'Unsaved changes';

  @override
  String get discardChangesBody =>
      'Your changes will be lost if you leave this page.';

  @override
  String get leaveFormAction => 'Leave';

  @override
  String get keepEditingAction => 'Keep editing';

  @override
  String get validationProductNameRequired => 'Please enter a product name.';

  @override
  String get validationProductNameTooLong =>
      'The product name is too long (maximum 80 characters).';

  @override
  String get validationPriceInvalid => 'Please enter a valid price.';

  @override
  String get validationPricePositive => 'The price must be greater than zero.';

  @override
  String get validationStockInvalid => 'Please enter a valid quantity.';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody => 'Your customers\' orders will appear here.';

  @override
  String get ordersNotFoundTitle => 'Order not found';

  @override
  String get ordersNotFoundBody =>
      'This order no longer exists or could not be loaded.';

  @override
  String get ordersBackToList => 'Back to orders';

  @override
  String get ordersSearchHint => 'Reference, buyer or product';

  @override
  String get ordersStatPending => 'To confirm';

  @override
  String get ordersStatConfirmed => 'Confirmed';

  @override
  String get ordersStatCancelled => 'Cancelled';

  @override
  String ordersResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: 'No orders',
    );
    return '$_temp0';
  }

  @override
  String get ordersNoResultTitle => 'No matching order';

  @override
  String get ordersNoResultBody =>
      'Change your search or switch the filter to see your orders.';

  @override
  String get ordersClearFilters => 'Clear';

  @override
  String ordersConfirmedRevenue(String amount) {
    return 'Confirmed revenue: $amount';
  }

  @override
  String ordersMoreItems(int count) {
    return '+$count more';
  }

  @override
  String get ordersSummaryTitle => 'Summary';

  @override
  String get ordersReferenceLabel => 'Reference';

  @override
  String get ordersArticlesLabel => 'Items';

  @override
  String ordersArticlesCount(int lines, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines lines',
      one: '1 line',
    );
    return '$_temp0 · $total unit(s)';
  }

  @override
  String get ordersBuyerTitle => 'Buyer';

  @override
  String get ordersPhoneLabel => 'Phone';

  @override
  String get ordersConfirmHelp =>
      'Confirm the order to validate the parcel preparation.';

  @override
  String ordersItemDetail(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get statusOrderPending => 'Pending';

  @override
  String get statusOrderConfirmed => 'Confirmed';

  @override
  String get statusOrderCancelled => 'Cancelled';

  @override
  String get confirmOrderAction => 'Confirm order';

  @override
  String get confirmingOrder => 'Confirming…';

  @override
  String get orderConfirmed => 'Order confirmed successfully.';

  @override
  String get confirmOrderError => 'The confirmation failed.';

  @override
  String get confirmOrderHint =>
      'The real status was not updated automatically. Verify it before any new attempt.';

  @override
  String get verifyStatus => 'Check status';

  @override
  String get totalLabel => 'Total';

  @override
  String get activeOrdersStat => 'Active orders';

  @override
  String get statInTransit => 'In transit';

  @override
  String get statDelivered => 'Delivered';

  @override
  String get featuredCatalog => 'Featured catalog';

  @override
  String get buyerOrdersEmptyTitle => 'No orders yet';

  @override
  String get buyerOrdersEmptyBody => 'Your orders will appear here.';

  @override
  String get buyerOrdersOngoingTitle => 'In progress';

  @override
  String get buyerOrdersClosedTitle => 'Finished';

  @override
  String get buyerOrdersFilterBody =>
      'The selected status no longer holds any order. Clear the filter to see them all again.';

  @override
  String get catalogEmptyTitle => 'No listings available';

  @override
  String get catalogEmptyBody => 'Published listings will appear here.';

  @override
  String get searchCatalog => 'Search listings';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterLocation => 'Location';

  @override
  String get filterAll => 'All';

  @override
  String resultsCount(int count) {
    return '$count result(s)';
  }

  @override
  String catalogTotalProducts(int count) {
    return '$count products in the catalog';
  }

  @override
  String get quantityIncrease => 'Increase quantity';

  @override
  String get quantityDecrease => 'Decrease quantity';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String itemsCount(int count) {
    return '$count item(s)';
  }

  @override
  String productPricePerUnit(String unit) {
    return '/ $unit';
  }

  @override
  String get validationAddressRequired => 'Please enter an address.';

  @override
  String get validationPhoneRequired => 'Please enter your phone number.';

  @override
  String get validationPhoneInvalid => 'Invalid phone number.';

  @override
  String get orderDetailTitle => 'Order details';

  @override
  String get orderItemsLabel => 'Ordered items';

  @override
  String get buyerEmailLabel => 'Buyer email';

  @override
  String get orderDateLabel => 'Order date';

  @override
  String get orderNotFound => 'Order not found.';

  @override
  String orderNumber(String id) {
    return 'Order $id';
  }

  @override
  String orderNumberItems(int count) {
    return '$count item(s)';
  }

  @override
  String get placedOn => 'Placed on';

  @override
  String get orderCancelled => 'This order has been cancelled.';

  @override
  String get trackingTitle => 'Delivery tracking';

  @override
  String trackingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get trackingStepDone => 'Done';

  @override
  String get statusOrderInTransit => 'In transit';

  @override
  String get statusOrderDelivered => 'Delivered';

  @override
  String get driverTitle => 'Driver';

  @override
  String get driverAssignedLater =>
      'A driver will be assigned after the order is confirmed.';

  @override
  String get contactDriver => 'Contact driver';

  @override
  String get copyNumber => 'Copy number';

  @override
  String get phoneCopied => 'Number copied.';

  @override
  String get deliveryInfoLabel => 'Delivery information';

  @override
  String get deliveryAddressLabel => 'Delivery address';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get noteLabel => 'Note';

  @override
  String get orderDeliveryStatusLabel => 'Delivery status';

  @override
  String get sellerLabel => 'Seller';

  @override
  String get driverStatusPickUp => 'To collect';

  @override
  String get driverStatusInTransit => 'In transit';

  @override
  String get driverStatusDelivered => 'Delivered';

  @override
  String get driverStatToCollect => 'To deliver';

  @override
  String get driverRecentDeliveries => 'Recent deliveries';

  @override
  String get driverStartDelivery => 'Start delivery';

  @override
  String get driverStartingDelivery => 'Starting…';

  @override
  String get driverMarkDelivered => 'Mark as delivered';

  @override
  String get driverMarkingDelivered => 'Marking…';

  @override
  String get driverDeliveryStarted => 'Delivery started.';

  @override
  String get driverDeliveryDelivered => 'Delivery completed successfully.';

  @override
  String get driverActionError => 'The action could not be completed.';

  @override
  String get driverActionHint =>
      'The real status was not updated automatically. Verify it before any new action.';

  @override
  String get driverDetailTitle => 'Delivery details';

  @override
  String get driverRouteTitle => 'Route';

  @override
  String get driverPickupLabel => 'Pickup point';

  @override
  String get driverScheduledLabel => 'Scheduled on';

  @override
  String get driverContactCustomer => 'Contact customer';

  @override
  String get driverCustomerLabel => 'Customer';

  @override
  String get driverDeliveriesEmptyTitle => 'No deliveries';

  @override
  String get driverDeliveriesEmptyBody => 'Your deliveries will appear here.';

  @override
  String get driverDeliveryNotFound => 'Delivery not found.';

  @override
  String get driverHeroSubtitle =>
      'Available jobs and your deliveries, all in one place.';

  @override
  String get driverQuickDeliveries => 'My deliveries';

  @override
  String get driverQuickActiveDelivery => 'Active delivery';

  @override
  String get driverQuickHistory => 'History';

  @override
  String driverActiveDeliveriesCount(int count) {
    return '$count ongoing delivery(ies)';
  }

  @override
  String get driverNoActiveDelivery => 'No ongoing delivery';

  @override
  String get driverLoadingDeliveries => 'Loading your deliveries…';

  @override
  String get driverAvailableTab => 'Available';

  @override
  String get driverMineTab => 'My deliveries';

  @override
  String get driverAccountTab => 'Account';

  @override
  String get driverActiveCourse => 'Active delivery';

  @override
  String get driverAvailableEmptyTitle => 'No available deliveries';

  @override
  String get driverAvailableEmptyBody =>
      'New deliveries for your agency will appear here.';

  @override
  String get driverMineEmptyTitle => 'No deliveries';

  @override
  String get driverMineEmptyBody =>
      'Your accepted and completed deliveries will appear here.';

  @override
  String get driverFilterStatus => 'Filter by status';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get loadMore => 'Load more';

  @override
  String get driverAccept => 'Accept';

  @override
  String get driverAccepting => 'Accepting…';

  @override
  String get driverUpdating => 'Updating…';

  @override
  String get driverAlreadyActive => 'Finish your active delivery first.';

  @override
  String get driverAlreadyTaken => 'This delivery has just been taken.';

  @override
  String get driverPickupAddress => 'Pickup address';

  @override
  String get driverDropoffAddress => 'Delivery address';

  @override
  String get driverDistance => 'Distance';

  @override
  String get driverItems => 'Items';

  @override
  String get driverOpenMap => 'Open directions';

  @override
  String get driverCallBuyer => 'Call buyer';

  @override
  String get driverBuyerUnavailable => 'Buyer contact details are unavailable.';

  @override
  String get driverFailureAction => 'Report delivery failure';

  @override
  String get driverFailureReason => 'Reason';

  @override
  String get driverFailureReasonHint => 'Explain why the delivery failed.';

  @override
  String get driverFailureReasonRequired => 'A reason is required.';

  @override
  String get driverLaunchError => 'Unable to open this app.';

  @override
  String get driverMarkPickedUp => 'Confirm pickup';

  @override
  String get driverStartTransit => 'Start transit';

  @override
  String get deliveryStatusPending => 'Pending';

  @override
  String get deliveryStatusAccepted => 'Accepted';

  @override
  String get deliveryStatusPickedUp => 'Picked up';

  @override
  String get deliveryStatusInTransit => 'In transit';

  @override
  String get deliveryStatusDelivered => 'Delivered';

  @override
  String get deliveryStatusFailed => 'Failed';

  @override
  String get deliveryStatusCancelled => 'Cancelled';

  @override
  String get adminStatusPickUp => 'To collect';

  @override
  String get adminStatusInTransit => 'In transit';

  @override
  String get adminStatusDelivered => 'Delivered';

  @override
  String get adminStatusCancelled => 'Cancelled';

  @override
  String get adminDeliveriesTitle => 'Deliveries';

  @override
  String get adminDeliveriesSearch => 'Search a delivery…';

  @override
  String get adminDeliveriesEmptyTitle => 'No deliveries';

  @override
  String get adminDeliveriesEmptyBody =>
      'Deliveries under supervision will appear here.';

  @override
  String get adminDeliveryNotFound => 'Delivery not found.';

  @override
  String get adminDeliveryPickup => 'Pickup';

  @override
  String get adminDeliveryDestination => 'Destination';

  @override
  String get adminDeliveryDistance => 'Distance';

  @override
  String get adminDeliveryTracking => 'Tracking';

  @override
  String get adminDeliveryBaseFee => 'Base fee';

  @override
  String get adminDeliveryTotalFee => 'Total fee';

  @override
  String get adminDeliveryMarkInTransit => 'Mark as in transit';

  @override
  String get adminDeliveryMarkDelivered => 'Mark as delivered';

  @override
  String get adminDeliveryAssignDriver => 'Assign driver';

  @override
  String get adminDeliveryUpdated => 'Delivery updated successfully.';

  @override
  String get adminDeliveryAssigned => 'Driver assigned successfully.';

  @override
  String get adminDeliveryNoDriver => 'No driver';

  @override
  String get adminDeliveryAssignHint => 'Tap to assign a driver';

  @override
  String adminDeliveryDriverCaption(Object id) {
    return 'Driver $id';
  }

  @override
  String get adminDeliveryDriverNameHint => 'Driver name…';

  @override
  String get adminDeliveryAssignAction => 'Assign';

  @override
  String get adminActionFailed => 'The operation failed. Please try again.';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminUsersSearchHint => 'Search an account…';

  @override
  String get adminUsersEmpty => 'No account matches';

  @override
  String get adminUsersUpdated => 'User updated.';

  @override
  String get adminUserApprove => 'Approve';

  @override
  String get adminUserRestrict => 'Restrict';

  @override
  String get adminUserReactivate => 'Reactivate';

  @override
  String adminUserActivityCaption(int orders, int products) {
    String _temp0 = intl.Intl.pluralLogic(
      orders,
      locale: localeName,
      other: '$orders orders',
      one: '1 order',
      zero: 'No orders',
    );
    String _temp1 = intl.Intl.pluralLogic(
      products,
      locale: localeName,
      other: '$products products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get categoryCereals => 'Cereals';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryTubers => 'Tubers';

  @override
  String get categorySpices => 'Spices';

  @override
  String get catalogSubtitle =>
      'Fresh produce, straight from our partner suppliers.';

  @override
  String get catalogSearchClear => 'Clear search';

  @override
  String get catalogFiltersReset => 'Reset filters';

  @override
  String get catalogNoResultsTitle => 'No matching product';

  @override
  String get catalogNoResultsBody =>
      'Try another keyword or reset the filters to browse the whole catalog.';

  @override
  String catalogProductStock(Object count, Object unit) {
    return '$count $unit available';
  }

  @override
  String get buyerCatalogTab => 'Catalog';

  @override
  String get buyerOrdersTab => 'Orders';

  @override
  String get catalogSortLabel => 'Sort';

  @override
  String get catalogSortPrice => 'Price';

  @override
  String get catalogSortExpiry => 'Expiry';

  @override
  String get catalogSortRecent => 'Most recent';

  @override
  String catalogQualityGrade(String grade) {
    return 'Quality $grade';
  }

  @override
  String catalogExpiry(String date) {
    return 'Best before $date';
  }

  @override
  String get catalogListingDetail => 'Listing details';

  @override
  String get catalogListingUnavailable =>
      'This listing is no longer available.';

  @override
  String get catalogRequestQuote => 'Request a quote';

  @override
  String get quoteQuantityHint => 'Requested quantity';

  @override
  String get quoteMessageHint => 'Additional message (optional)';

  @override
  String quoteRequestMessage(
    String quantity,
    String unit,
    String title,
    String reference,
  ) {
    return 'Hello, I would like $quantity $unit of “$title” ($reference).';
  }

  @override
  String get quoteRequestInvalidQuantity =>
      'Enter a quantity greater than zero.';

  @override
  String get buyerOrdersEmptyMessage =>
      'Quotes from the team will appear here.';

  @override
  String get buyerOrderActionRequired => 'Action required';

  @override
  String get buyerOrderQuoted => 'Quote';

  @override
  String buyerQuoteExpiresIn(String time) {
    return 'Expires in $time';
  }

  @override
  String get buyerQuoteExpired => 'Quote expired';

  @override
  String get buyerConfirmQuote => 'Confirm quote';

  @override
  String get buyerCancelQuote => 'Cancel quote';

  @override
  String get buyerConfirmQuoteQuestion => 'Confirm this quote?';

  @override
  String get buyerCancelQuoteQuestion => 'Cancel this quote?';

  @override
  String get buyerCancellationReasonHint => 'Reason (optional)';

  @override
  String get buyerStatusQuoted => 'Quote sent';

  @override
  String get buyerStatusConfirmed => 'Confirmed';

  @override
  String get buyerStatusPreparing => 'Preparing';

  @override
  String get buyerStatusReadyForPickup => 'Ready for pickup';

  @override
  String get buyerStatusOutForDelivery => 'Out for delivery';

  @override
  String get buyerStatusCompleted => 'Completed';

  @override
  String get buyerStatusCancelled => 'Cancelled';

  @override
  String get buyerDeliveryModePickup => 'Pickup at collection point';

  @override
  String get buyerDeliveryModeAgency => 'Agency delivery';

  @override
  String get buyerPickupAddress => 'Collection point address';

  @override
  String get buyerDeliveryAddress => 'Delivery address';

  @override
  String get buyerQuoteTotals => 'Amounts provided by the team';

  @override
  String buyerOrderCancellationReason(String reason) {
    return 'Cancellation reason: $reason';
  }

  @override
  String get buyerOrderItems => 'Quoted listings';

  @override
  String get buyerOrderSubtotalLabel => 'Subtotal';

  @override
  String get buyerOrderBuyerFeeLabel => 'Buyer fee';

  @override
  String get buyerOrderDeliveryFeeLabel => 'Delivery fee';

  @override
  String get buyerCancelOrder => 'Cancel';

  @override
  String get buyerCancelOrderQuestion => 'Cancel this order?';

  @override
  String get adminConsoleLabel => 'Administration console';

  @override
  String get adminConsoleSubtitle => 'Platform supervision';

  @override
  String get adminRefreshTooltip => 'Refresh the dashboard';

  @override
  String get adminTodayLabel => 'Today';

  @override
  String get adminOverviewTitle => 'Key figures';

  @override
  String get adminStatRevenue => 'Order revenue';

  @override
  String get adminStatRevenueCaption => 'All orders recorded by the platform';

  @override
  String get adminStatUsers => 'Users';

  @override
  String get adminStatOrders => 'Orders';

  @override
  String get adminStatDeliveries => 'Deliveries';

  @override
  String adminStatUsersCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts to validate',
      one: '1 account to validate',
      zero: 'No account to validate',
    );
    return '$_temp0';
  }

  @override
  String adminStatOrdersCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders to confirm',
      one: '1 order to confirm',
      zero: 'Nothing to confirm',
    );
    return '$_temp0';
  }

  @override
  String adminStatDeliveriesCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deliveries running',
      one: '1 delivery running',
      zero: 'No delivery running',
    );
    return '$_temp0';
  }

  @override
  String get adminAttentionTitle => 'Needs your attention';

  @override
  String adminAttentionUsers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts awaiting validation',
      one: 'Account awaiting validation',
    );
    return '$_temp0';
  }

  @override
  String adminAttentionOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders awaiting confirmation',
      one: 'Order awaiting confirmation',
    );
    return '$_temp0';
  }

  @override
  String adminAttentionDeliveries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deliveries in progress',
      one: 'Delivery in progress',
    );
    return '$_temp0';
  }

  @override
  String get adminAttentionClearTitle => 'Nothing needs your attention';

  @override
  String get adminAttentionClearBody =>
      'No account, product or order is waiting for a decision.';

  @override
  String get distributionEmpty => 'Nothing to distribute yet';

  @override
  String get adminQuickActionsTitle => 'Shortcuts';

  @override
  String get adminQuickActionUsers => 'Users';

  @override
  String get adminQuickActionDeliveries => 'Deliveries';

  @override
  String get adminQuickActionAnalytics => 'Analytics';

  @override
  String get adminDistributionTitle => 'Distribution';

  @override
  String get adminDistributionOrders => 'Orders by status';

  @override
  String get adminDistributionDeliveries => 'Deliveries by status';

  @override
  String get adminDistributionUsers => 'Users by role';

  @override
  String get adminAnalyticsTitle => 'Platform analytics';

  @override
  String get adminAnalyticsSubtitle =>
      'Indicators computed from the administration console data.';

  @override
  String get adminAnalyticsVolumeTitle => 'Platform volume';

  @override
  String get adminAnalyticsIndicatorsTitle => 'Tracking indicators';

  @override
  String get adminAnalyticsActiveOrders => 'Active orders';

  @override
  String get adminAnalyticsCompletedDeliveries => 'Completed deliveries';

  @override
  String get adminAnalyticsEmpty => 'No data to analyze yet';

  @override
  String get adminAnalyticsNoHistory =>
      'History and time series are not available: the administration console does not record history yet.';

  @override
  String get adminRecentOrdersTitle => 'Latest orders';

  @override
  String get adminRecentOrdersEmpty => 'No order recorded yet';

  @override
  String adminOrderBuyerCaption(String buyer, String amount) {
    return '$buyer · $amount';
  }

  @override
  String get adminSectionLoadError => 'This section could not be loaded';

  @override
  String adminSectionLoadErrorDetail(String message) {
    return '$message';
  }

  @override
  String get adminOrdersSearchHint => 'Search an order…';

  @override
  String get adminOrdersEmptyTitle => 'No orders';

  @override
  String get adminOrdersEmptyBody => 'Recorded orders will appear here.';

  @override
  String adminOrderArticlesCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get adminOrderDetailTitle => 'Order detail';

  @override
  String get adminOrderNotFound => 'Order not found.';

  @override
  String get adminOrderPlacedAt => 'Placed on';

  @override
  String get adminOrderBuyerLabel => 'Buyer';

  @override
  String get adminOrderSellerLabel => 'Seller';

  @override
  String adminOrderAccountCaption(String id) {
    return 'Account $id';
  }

  @override
  String get adminOrderAmountLabel => 'Amount';

  @override
  String get adminOrderItemsTitle => 'Items';

  @override
  String get adminOrderItemsEmpty => 'No line items available for this order.';

  @override
  String get adminOrderLinkedDelivery => 'Linked delivery';

  @override
  String get adminOrderStatusLockedTitle => 'Status change unavailable';

  @override
  String get adminOrderStatusLockedBody =>
      'The order status transition workflow is not defined yet. Order consultation remains available.';

  @override
  String get adminTabDashboard => 'Dashboard';

  @override
  String get adminTabUsers => 'Users';

  @override
  String get adminTabAgents => 'Team';

  @override
  String get adminTabPlatform => 'Platform';

  @override
  String get adminTabAccount => 'Account';

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminPeriod => 'Period';

  @override
  String get adminFrom => 'From';

  @override
  String get adminTo => 'To';

  @override
  String get adminRefresh => 'Refresh';

  @override
  String get adminKpiUsers => 'Users';

  @override
  String get adminKpiReceivables => 'Receivables';

  @override
  String get adminKpiPendingPayouts => 'Pending payouts';

  @override
  String get adminKpiGrossRevenue => 'Gross revenue';

  @override
  String get adminKpiPendingCompensations => 'Pending compensations';

  @override
  String get adminKpiEligibleReferrals => 'Eligible referrals';

  @override
  String get adminKpiStock => 'Stock';

  @override
  String get adminByRole => 'Users by role';

  @override
  String get adminLotsByStatus => 'Lots by status';

  @override
  String get adminOrdersByStatus => 'Orders by status';

  @override
  String get adminDeliveriesByStatus => 'Deliveries by status';

  @override
  String get adminUsersSearch => 'Name, email or phone';

  @override
  String get adminRoleFilter => 'Role';

  @override
  String get adminStatusFilter => 'Account status';

  @override
  String get adminVerificationFilter => 'Profile verification';

  @override
  String get adminAll => 'All';

  @override
  String get adminActive => 'Active';

  @override
  String get adminSuspended => 'Suspended';

  @override
  String get adminVerified => 'Verified';

  @override
  String get adminUnverified => 'Unverified';

  @override
  String get adminPending => 'Pending';

  @override
  String get adminRejected => 'Rejected';

  @override
  String get adminNoUsers => 'No users match these filters.';

  @override
  String get adminCreateStaff => 'Create staff account';

  @override
  String get adminCreateAccount => 'Create account';

  @override
  String get adminFirstName => 'First name';

  @override
  String get adminLastName => 'Last name';

  @override
  String get adminEmail => 'Email';

  @override
  String get adminPhone => 'Phone';

  @override
  String get adminPassword => 'Password';

  @override
  String get adminStaffRole => 'Staff role';

  @override
  String get adminAgentName => 'Agent display name';

  @override
  String get adminCapabilities => 'Capabilities';

  @override
  String get adminAgency => 'Transport agency';

  @override
  String get adminChooseAgency => 'Choose an agency';

  @override
  String get adminOpsTab => 'Operations';

  @override
  String get adminReferentials => 'Catalog & locations';

  @override
  String get adminAgencies => 'Agencies';

  @override
  String get adminPayouts => 'Supplier payouts';

  @override
  String get adminReferrals => 'Referrals';

  @override
  String get adminCompensations => 'Compensations';

  @override
  String get adminLegalVersions => 'Terms';

  @override
  String get adminCategories => 'Categories';

  @override
  String get adminUnits => 'Units';

  @override
  String get adminProducts => 'Products';

  @override
  String get adminZones => 'Zones';

  @override
  String get adminHubs => 'Drop-off points';

  @override
  String get adminCode => 'Code';

  @override
  String get adminLabel => 'Label';

  @override
  String get adminName => 'Name';

  @override
  String get adminDescription => 'Description';

  @override
  String get adminImageUrl => 'Image URL';

  @override
  String get adminCategoryId => 'Category ID';

  @override
  String get adminUnitId => 'Unit ID';

  @override
  String get adminZoneId => 'Zone ID';

  @override
  String get adminAddress => 'Address';

  @override
  String get adminCity => 'City';

  @override
  String get adminRegion => 'Region';

  @override
  String get adminLatitude => 'Latitude';

  @override
  String get adminLongitude => 'Longitude';

  @override
  String get adminActiveFilter => 'Filter by activity';

  @override
  String get adminInactive => 'Inactive';

  @override
  String get adminCreate => 'Create';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminSaveChanges => 'Save';

  @override
  String get adminLoadMore => 'Load more';

  @override
  String get adminIsActive => 'Active';

  @override
  String get adminIsPerishable => 'Perishable product';

  @override
  String get adminAcceptsDropoff => 'Accepts drop-off';

  @override
  String get adminAcceptsPickup => 'Accepts pickup';

  @override
  String get adminNoRecords => 'No items.';

  @override
  String get adminContactName => 'Contact name';

  @override
  String get adminInsuranceProvider => 'Insurance provider';

  @override
  String get adminInsurancePolicy => 'Policy number';

  @override
  String get adminInsuranceExpiresAt => 'Insurance expiry (YYYY-MM-DD)';

  @override
  String get adminInsuranceExpiring =>
      'Warning: insurance expires in less than 30 days.';

  @override
  String get adminCoverage => 'Zone coverage';

  @override
  String get adminBaseFee => 'Base fee';

  @override
  String get adminPerKmFee => 'Per-km fee';

  @override
  String get adminSaveCoverage => 'Save coverage';

  @override
  String get adminRemoveCoverage => 'Remove coverage';

  @override
  String get adminDrivers => 'Drivers';

  @override
  String get adminPaymentReference => 'Payment reference';

  @override
  String get adminPayoutAccountId => 'Payout account ID (optional)';

  @override
  String get adminDefaultPayoutAccount => 'Default payout account';

  @override
  String get adminConfirmMoneyAction => 'Confirm sending this payment?';

  @override
  String get adminHumanActorRequired =>
      'This financial action must be performed by a person.';

  @override
  String get adminRejectReason => 'Rejection reason';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminPay => 'Mark as paid';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminShowAccount => 'Show';

  @override
  String get adminHideAccount => 'Hide';

  @override
  String get adminLegalCode => 'Legal document';

  @override
  String get adminVersion => 'Version';

  @override
  String get adminFrenchTitle => 'French title';

  @override
  String get adminFrenchContent => 'French content';

  @override
  String get adminEnglishTitle => 'English title (optional)';

  @override
  String get adminEnglishContent => 'English content (optional)';

  @override
  String get adminPreview => 'Preview';

  @override
  String get adminCreateDraft => 'Create draft';

  @override
  String get adminPublish => 'Publish';

  @override
  String get adminDraft => 'Draft';

  @override
  String get adminPublished => 'Published';

  @override
  String get adminReferenceInvalid => 'A valid payment reference is required.';

  @override
  String get adminOperationSaved => 'Changes saved.';

  @override
  String get adminOperationFailed => 'The operation could not be completed.';

  @override
  String get adminVehicleType => 'Vehicle type (optional)';

  @override
  String get adminPlateNumber => 'Plate number (optional)';

  @override
  String get adminRootOnly => 'Reserved for the ROOT account';

  @override
  String get adminEmailVerified => 'Email verified';

  @override
  String get adminProfileVerification => 'Profile verification';

  @override
  String get adminCreatedAt => 'Created';

  @override
  String get adminViewDocuments => 'View documents';

  @override
  String get adminSuspend => 'Suspend';

  @override
  String get adminReactivate => 'Reactivate';

  @override
  String get adminConfirmSuspendTitle => 'Suspend this account?';

  @override
  String get adminConfirmSuspendBody =>
      'Its sessions will be closed and its devices disconnected.';

  @override
  String get adminConfirmReactivateTitle => 'Reactivate this account?';

  @override
  String get adminConfirmReactivateBody =>
      'This account will be able to sign in again.';

  @override
  String get adminConfirmDeactivateTitle => 'Deactivate this agent?';

  @override
  String get adminConfirmDeactivateBody =>
      'The agent will no longer be able to access the platform.';

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminConfirm => 'Confirm';

  @override
  String get adminStaffCreated => 'Staff account created.';

  @override
  String get adminAccountUpdated => 'Account updated.';

  @override
  String get adminNoAgents => 'No agents.';

  @override
  String get adminAiBadge => 'AI';

  @override
  String get adminReadOnlyAi =>
      'AI records are read-only here and managed in the AI module.';

  @override
  String get adminEditAgent => 'Edit agent';

  @override
  String get adminDisplayName => 'Display name';

  @override
  String get adminAgentActive => 'Active agent';

  @override
  String get adminAutonomy => 'Autonomy';

  @override
  String get adminAutonomyNone => 'Not set';

  @override
  String get adminAutonomySuggest => 'Suggestions only';

  @override
  String get adminAutonomyApproval => 'Action with approval';

  @override
  String get adminAutonomyFull => 'Autonomous';

  @override
  String get adminSave => 'Save';

  @override
  String get adminSettingsTitle => 'Platform settings';

  @override
  String get adminCommission => 'Supplier commission (%)';

  @override
  String get adminBuyerFeeType => 'Buyer fee';

  @override
  String get adminFeeNone => 'None';

  @override
  String get adminFeeFixed => 'Fixed amount';

  @override
  String get adminFeePercent => 'Percentage';

  @override
  String get adminBuyerFeeValue => 'Buyer fee value';

  @override
  String get adminTransportMarkup => 'Transport markup (%)';

  @override
  String get adminBuyerReward => 'Buyer referral reward';

  @override
  String get adminSupplierReward => 'Supplier referral reward';

  @override
  String get adminReservationHours => 'Reservation duration (hours)';

  @override
  String get adminExpiryCompensation => 'Expiry compensation (%)';

  @override
  String get adminCurrency => 'Currency';

  @override
  String get adminCommissionWarning => 'Supplier commission is not set.';

  @override
  String get adminSettingsSaved => 'Settings saved.';

  @override
  String get adminAuditTitle => 'Audit log';

  @override
  String get adminAuditEntityType => 'Entity type';

  @override
  String get adminAuditEntityId => 'Entity ID';

  @override
  String get adminAuditActorUserId => 'Actor user ID';

  @override
  String get adminAuditActorAgentId => 'Actor agent ID';

  @override
  String get adminAuditAction => 'Action';

  @override
  String get adminAuditEntity => 'Entity';

  @override
  String get adminAuditActor => 'Actor';

  @override
  String get adminAuditDate => 'Date';

  @override
  String get adminAuditMetadata => 'Metadata';

  @override
  String get adminAuditEmpty => 'No audit entries.';

  @override
  String get adminPrevious => 'Previous';

  @override
  String get adminNext => 'Next';

  @override
  String get adminCapabilityBuyerSupport => 'Buyer support';

  @override
  String get adminCapabilitySupplierSupport => 'Supplier support';

  @override
  String get adminCapabilityListingManagement => 'Listing management';

  @override
  String get adminCapabilityOrderProcessing => 'Order processing';

  @override
  String get adminCapabilityStockValidation => 'Stock validation';

  @override
  String get adminCapabilityPaymentFollowup => 'Payment follow-up';

  @override
  String get adminCapabilityDispatchCoordination => 'Delivery coordination';

  @override
  String get adminCapabilityUserVerification => 'User verification';

  @override
  String get adminCapabilityDisputeHandling => 'Dispute handling';

  @override
  String get adminErrorLoading => 'Could not load the data.';

  @override
  String get adminRetry => 'Try again';

  @override
  String get adminNoData => 'No data';

  @override
  String get adminLoadAgenciesError => 'Could not load agencies.';

  @override
  String get adminStaffPasswordHelp =>
      'At least 8 characters with lowercase, uppercase, a number and a special character (@\$!%*?&).';

  @override
  String get adminUserDetails => 'User profile';

  @override
  String get adminHumanAgent => 'Human agent';

  @override
  String get adminSettingsLocked =>
      'Only the ROOT account can change platform settings.';

  @override
  String get adminDateRangeInvalid =>
      'The start date must be before the end date.';

  @override
  String get adminInvalidEmail => 'Enter a valid email address.';

  @override
  String get adminInvalidPhone => 'Enter a valid phone number.';

  @override
  String get adminInvalidPassword =>
      'The password does not meet the requirements.';

  @override
  String get adminInvalidSettings => 'Check the settings values.';

  @override
  String get adminInvalidApiResponse =>
      'The server returned an invalid response.';

  @override
  String get navMore => 'More';

  @override
  String get navHome => 'Home';

  @override
  String get sectionBuyerSupport => 'Buyer support';

  @override
  String get sectionStockValidation => 'Stock validation';

  @override
  String get sectionOrderProcessing => 'Order processing';

  @override
  String get sectionPaymentFollowup => 'Payment follow-up';

  @override
  String get agentNavigationGroupOperations => 'Operations';

  @override
  String get agentNavigationGroupSupport => 'Support';

  @override
  String get agentNavigationGroupFollowup => 'Follow-up';

  @override
  String get agentConsoleSubtitle =>
      'Buyer support, stock, orders and payments in one workspace.';

  @override
  String get agentRefreshTooltip => 'Refresh the workspace';

  @override
  String get agentTodayLabel => 'Today';

  @override
  String get agentOverviewTitle => 'Overview';

  @override
  String get agentQuickActionsTitle => 'Quick access';

  @override
  String get agentAttentionTitle => 'Needs your attention';

  @override
  String get agentAttentionClearTitle => 'Nothing waiting';

  @override
  String get agentAttentionClearBody =>
      'No request or case needs a decision right now.';

  @override
  String get agentNoCapabilitiesTitle => 'No operational access';

  @override
  String get agentNoCapabilitiesBody =>
      'No agent capability has been granted to your account yet.';

  @override
  String get agentLoading => 'Loading the workspace…';

  @override
  String get agentRefreshing => 'Refreshing…';

  @override
  String agentStaleQueueCount(String count) {
    return 'Last known value: $count';
  }

  @override
  String get agentSectionLoadError => 'This section could not be loaded';

  @override
  String agentSectionLoadErrorDetail(String message) {
    return '$message';
  }

  @override
  String get agentAccessDeniedTitle => 'Access not allowed';

  @override
  String get agentAccessDeniedBody =>
      'Your account does not hold the capability required for this section.';

  @override
  String get agentActionError => 'The action could not be completed.';

  @override
  String get agentActionHint =>
      'The real status was not updated automatically. Verify it before any new action.';

  @override
  String get agentSearchHint => 'Search a reference or a name';

  @override
  String get agentFilterStatus => 'Status';

  @override
  String get agentFilterAll => 'All';

  @override
  String get agentClearFilters => 'Reset';

  @override
  String agentResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases',
      one: '1 case',
      zero: 'No case',
    );
    return '$_temp0';
  }

  @override
  String get agentEmptyTitle => 'Nothing to show';

  @override
  String get agentEmptyBody => 'New cases will appear here.';

  @override
  String get agentNoResultTitle => 'No matching case';

  @override
  String get agentNoResultBody => 'Change the search or the status filter.';

  @override
  String get agentDetailTitle => 'Case details';

  @override
  String get agentReferenceLabel => 'Reference';

  @override
  String get agentReceivedLabel => 'Received on';

  @override
  String get agentCloseAction => 'Close';

  @override
  String get agentBackToList => 'Back to the list';

  @override
  String get agentStatSupport => 'Support requests';

  @override
  String agentStatSupportCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open requests',
      one: '1 open request',
      zero: 'Nothing open',
    );
    return '$_temp0';
  }

  @override
  String get agentStatStock => 'Stock cases';

  @override
  String agentStatStockCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending cases',
      one: '1 pending case',
      zero: 'Nothing pending',
    );
    return '$_temp0';
  }

  @override
  String get agentStatOrders => 'Orders to process';

  @override
  String agentStatOrdersCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders to process',
      one: '1 order to process',
      zero: 'Nothing to process',
    );
    return '$_temp0';
  }

  @override
  String get agentStatPayments => 'Payments to follow';

  @override
  String agentStatPaymentsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments to follow',
      one: '1 payment to follow',
      zero: 'Nothing to follow',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionSupport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests awaiting an answer',
      one: 'Request awaiting an answer',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stock cases to validate',
      one: 'Stock case to validate',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders to process',
      one: 'Order to process',
    );
    return '$_temp0';
  }

  @override
  String agentAttentionPayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments to follow up',
      one: 'Payment to follow up',
    );
    return '$_temp0';
  }

  @override
  String get agentQuickSupport => 'Buyer support';

  @override
  String get agentQuickStock => 'Stock validation';

  @override
  String get agentQuickOrders => 'Order processing';

  @override
  String get agentQuickPayments => 'Payment follow-up';

  @override
  String get agentSupportBuyerLabel => 'Buyer';

  @override
  String get agentSupportSubjectLabel => 'Subject';

  @override
  String get agentSupportPriorityLabel => 'Priority';

  @override
  String get agentSupportPriorityHigh => 'High';

  @override
  String get agentSupportPriorityNormal => 'Normal';

  @override
  String get agentSupportStatusOpen => 'Open';

  @override
  String get agentSupportStatusInProgress => 'In progress';

  @override
  String get agentSupportStatusResolved => 'Resolved';

  @override
  String get agentSupportTakeAction => 'Take charge';

  @override
  String get agentSupportResolveAction => 'Mark as resolved';

  @override
  String get agentSupportUpdated => 'Request updated.';

  @override
  String get agentSupportEmptyTitle => 'No support request';

  @override
  String get agentSupportEmptyBody => 'Buyer requests will appear here.';

  @override
  String get agentStockProductLabel => 'Product';

  @override
  String get agentStockSupplierLabel => 'Supplier';

  @override
  String get agentStockLocationLabel => 'Location';

  @override
  String agentStockDeclaredQty(int quantity, String unit) {
    return '$quantity $unit declared';
  }

  @override
  String get agentStockStatusPending => 'Pending';

  @override
  String get agentStockStatusValidated => 'Validated';

  @override
  String get agentStockStatusRejected => 'Rejected';

  @override
  String get agentStockValidateAction => 'Validate';

  @override
  String get agentStockRejectAction => 'Reject';

  @override
  String get agentStockUpdated => 'Case updated.';

  @override
  String get agentStockEmptyTitle => 'No stock case';

  @override
  String get agentStockEmptyBody => 'Declared stock to check will appear here.';

  @override
  String get agentOrderBuyerLabel => 'Buyer';

  @override
  String get agentOrderSellerLabel => 'Seller';

  @override
  String get agentOrderItemsLabel => 'Items';

  @override
  String get agentOrderAmountLabel => 'Amount';

  @override
  String get agentOrderStatusAwaiting => 'To process';

  @override
  String get agentOrderStatusProcessing => 'In progress';

  @override
  String get agentOrderStatusProcessed => 'Processed';

  @override
  String get agentOrderStartAction => 'Start processing';

  @override
  String get agentOrderCompleteAction => 'Mark as processed';

  @override
  String get agentOrderUpdated => 'Order updated.';

  @override
  String get agentOrderEmptyTitle => 'No order to process';

  @override
  String get agentOrderEmptyBody => 'Orders to move forward will appear here.';

  @override
  String get agentPaymentPayerLabel => 'Payer';

  @override
  String get agentPaymentAmountLabel => 'Amount';

  @override
  String get agentPaymentMethodLabel => 'Method';

  @override
  String get agentPaymentDueLabel => 'Due on';

  @override
  String get agentPaymentStatusDue => 'To follow up';

  @override
  String get agentPaymentStatusAwaiting => 'Awaiting confirmation';

  @override
  String get agentPaymentStatusConfirmed => 'Confirmed';

  @override
  String get agentPaymentConfirmAction => 'Confirm receipt';

  @override
  String get agentPaymentConfirmHelp =>
      'Only confirm once the payment is actually received by the platform.';

  @override
  String get agentPaymentNotReceivedNotice =>
      'This payment is not confirmed as received.';

  @override
  String get agentPaymentUpdated => 'Payment updated.';

  @override
  String get agentPaymentEmptyTitle => 'No payment to follow';

  @override
  String get agentPaymentEmptyBody => 'Payments to track will appear here.';

  @override
  String get migrationInProgress => 'AgriConnect — migration in progress';

  @override
  String get configurationMissing => 'Configuration is missing';

  @override
  String get errUnauthorized =>
      'Your session is no longer valid. Please sign in again.';

  @override
  String get errProfileNotVerified =>
      'Your profile must be verified to continue.';

  @override
  String get errStateConflict =>
      'This information has changed. Refresh and try again.';

  @override
  String get roleHomeTab => 'Home';

  @override
  String get roleComingSoon => 'Coming soon';

  @override
  String get pageNotFound => 'This page could not be found.';

  @override
  String get onboardingPageTitle => 'Welcome';

  @override
  String get loginPageTitle => 'Sign in';

  @override
  String get registerPageTitle => 'Create an account';

  @override
  String get forgotPasswordPageTitle => 'Forgot password';

  @override
  String get legalPageTitle => 'Legal information';

  @override
  String get sessionExpiredNotice =>
      'Your session expired. Please sign in again.';

  @override
  String get sessionSuspendedNotice => 'Your account is suspended.';

  @override
  String get sessionRevokedNotice => 'Your session has been closed.';

  @override
  String get authInvalidCredentials => 'Incorrect email address or password.';

  @override
  String get authAccountSuspended =>
      'This account has been suspended. Contact our team.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Please wait before trying again.';

  @override
  String get authUnexpectedError => 'Something went wrong. Please try again.';

  @override
  String get authNetworkError =>
      'Could not connect. Check your network and try again.';

  @override
  String get authForgotLink => 'Forgot password?';

  @override
  String get authNoAccount => 'Don\'t have an account yet?';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authRolePrompt => 'How would you like to use AgriConnect?';

  @override
  String get authSupplierChoice => 'I sell (supplier)';

  @override
  String get authBuyerChoice => 'I buy (buyer)';

  @override
  String get authLanguageLabel => 'Language';

  @override
  String get authContinue => 'Continue';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authPhone => 'Phone';

  @override
  String get authLocation => 'City or locality (optional)';

  @override
  String get authFarmName => 'Farm name';

  @override
  String get authBuyerType => 'Buyer type';

  @override
  String get authBusinessName => 'Business name (optional)';

  @override
  String get authReferralCode => 'Referral code (optional)';

  @override
  String get authBuyerRetailer => 'Retailer';

  @override
  String get authBuyerFarmer => 'Farmer';

  @override
  String get authBuyerWholesaler => 'Wholesaler';

  @override
  String get authBuyerOther => 'Other';

  @override
  String get authPasswordHelp =>
      'At least 8 characters, one lowercase, one uppercase, one number and one of @\$!%*?&. Four identical characters in a row are not allowed.';

  @override
  String get authAcceptTerms => 'I accept the';

  @override
  String get authGeneralTerms => 'Terms of use';

  @override
  String get authRoleTerms => 'supplier consignment terms';

  @override
  String get authBuyerTerms => 'buyer terms';

  @override
  String get authTermsRequired => 'Please accept both documents to continue.';

  @override
  String get authRegistrationConflict =>
      'This email address or phone number is already in use.';

  @override
  String get authCreate => 'Create my account';

  @override
  String get authCreating => 'Creating account…';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authForgotIntro =>
      'Enter your email address. If it is associated with an account, you will receive a reset link.';

  @override
  String get authSendReset => 'Send the link';

  @override
  String get authResetSent =>
      'If this address matches an account, a password reset link has been sent.';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get authLegalUnavailable =>
      'This document is not available right now.';

  @override
  String get authEmailUnverified =>
      'Verify your email address to access all features.';

  @override
  String get authResendVerification => 'Resend';

  @override
  String get authVerificationSent => 'A new verification link has been sent.';

  @override
  String get authVerificationWait =>
      'Please wait 5 minutes before requesting another link.';

  @override
  String get authPasswordPolicyInvalid =>
      'The password does not meet the requirements shown.';

  @override
  String get authOnboardingSubtitle => 'The connected agricultural marketplace';

  @override
  String get authValueInvalid => 'This value is invalid.';

  @override
  String get authOptional => 'Optional';

  @override
  String get accountTab => 'Account';

  @override
  String get accountTitle => 'My account';

  @override
  String get accountProfile => 'Profile';

  @override
  String get accountDocuments => 'Verification documents';

  @override
  String get accountPayoutAccounts => 'Payout accounts';

  @override
  String get accountReferral => 'Referrals';

  @override
  String get accountSessions => 'Sessions and security';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountEmail => 'Email address';

  @override
  String get accountLocation => 'Location';

  @override
  String get accountFirstName => 'First name';

  @override
  String get accountLastName => 'Last name';

  @override
  String get accountFarmName => 'Farm name';

  @override
  String get accountDescription => 'Description';

  @override
  String get accountBusinessName => 'Business name';

  @override
  String get accountBuyerType => 'Buyer type';

  @override
  String get accountZone => 'Zone';

  @override
  String get accountVehicleType => 'Vehicle type';

  @override
  String get accountPlateNumber => 'License plate';

  @override
  String get accountAvatarChange => 'Change photo';

  @override
  String get accountSaveFailed => 'Could not save your changes.';

  @override
  String get accountAvatarInvalid =>
      'Choose a JPEG, PNG, or WebP image no larger than 5 MB.';

  @override
  String get accountVerificationTitle => 'Profile verification';

  @override
  String get accountVerificationUnverified =>
      'Verify your profile to get started.';

  @override
  String get accountVerificationPending => 'Your profile is being reviewed.';

  @override
  String get accountVerificationRejected =>
      'Your profile was rejected. Submit a new document.';

  @override
  String get accountVerificationVerified => 'Profile verified';

  @override
  String get accountDocumentsEmpty => 'No verification documents submitted.';

  @override
  String get accountDocumentType => 'Document type';

  @override
  String get accountSelectDocument => 'Choose a file';

  @override
  String get accountDocumentTooLarge =>
      'The document must be no larger than 8 MB.';

  @override
  String get accountDocumentInvalid =>
      'Choose a PDF or a JPEG, PNG, or WebP image.';

  @override
  String get accountDocumentPendingLimit =>
      'You already have five documents awaiting review.';

  @override
  String get accountUploadDocument => 'Submit document';

  @override
  String get accountFileName => 'Selected file';

  @override
  String get accountPayoutTitle => 'Payout accounts';

  @override
  String get accountAddPayout => 'Add account';

  @override
  String get accountPayoutMethod => 'Payment method';

  @override
  String get accountProvider => 'Provider or bank';

  @override
  String get accountAccountNumber => 'Account number';

  @override
  String get accountAccountName => 'Account holder name';

  @override
  String get accountDefault => 'Default account';

  @override
  String get accountNoPayout => 'No payout accounts saved.';

  @override
  String get accountDeleteConfirm => 'Delete this payout account?';

  @override
  String get accountReferralTitle => 'Invite people you know';

  @override
  String get accountReferralCode => 'Your referral code';

  @override
  String get accountCopyCode => 'Copy code';

  @override
  String get accountCopied => 'Code copied.';

  @override
  String get accountReferralNotVerified =>
      'Referral rewards are available after your profile is verified.';

  @override
  String get accountPending => 'Pending';

  @override
  String get accountEligible => 'Eligible';

  @override
  String get accountPaid => 'Paid';

  @override
  String get accountNoReferrals => 'No referrals yet.';

  @override
  String get accountSessionsTitle => 'Active sessions';

  @override
  String get accountCurrentSession => 'This device';

  @override
  String get accountCloseSession => 'Close session';

  @override
  String get accountLogoutOthers => 'Sign out other devices';

  @override
  String get accountLogoutOthersConfirm =>
      'Other sessions will be closed. This device will stay signed in.';

  @override
  String get accountLogoutOthersDone => 'Other sessions have been closed.';

  @override
  String get accountSessionCreated => 'Signed in';

  @override
  String get accountSessionLastActive => 'Last active';

  @override
  String get accountSessionExpires => 'Expires';

  @override
  String get accountSessionIp => 'IP address';

  @override
  String get accountLanguageTitle => 'App language';

  @override
  String get verificationRequiredTitle => 'Profile not verified';

  @override
  String get verificationRequiredMessage =>
      'Verify your profile to use this feature.';

  @override
  String get verificationOpenDocuments => 'View documents';

  @override
  String get accountLoadError => 'Could not load this information.';

  @override
  String get accountSearch => 'Search';

  @override
  String get accountCategory => 'Category';

  @override
  String get accountAllCategories => 'All categories';

  @override
  String get accountNoResults => 'No results.';

  @override
  String get accountDocumentsIntro =>
      'Submit the requested documents to verify your profile.';

  @override
  String get accountDocumentUploaded => 'Document submitted for verification.';

  @override
  String get accountDocumentId => 'Identity document';

  @override
  String get accountDocumentBusiness => 'Business registration';

  @override
  String get accountDocumentFarm => 'Proof of farming';

  @override
  String get accountDocumentOther => 'Other document';

  @override
  String get accountRejected => 'Rejected';

  @override
  String get accountEditPayout => 'Edit account';

  @override
  String get accountSaved => 'Changes saved.';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get accountCurrentNumber => 'Saved number';

  @override
  String get accountNumberInvalid =>
      'Enter a number between 4 and 64 characters.';

  @override
  String get accountMobileMoney => 'Mobile Money';

  @override
  String get accountBankTransfer => 'Bank transfer';

  @override
  String get accountCash => 'Cash';

  @override
  String get accountEdit => 'Edit';

  @override
  String get accountDelete => 'Delete';

  @override
  String get accountSessionClosed => 'Session closed.';

  @override
  String get accountCloseSessionConfirm => 'Close this session?';

  @override
  String get accountUnknownDevice => 'Unknown device';

  @override
  String get accountRetailer => 'Retailer';

  @override
  String get accountFarmer => 'Farmer';

  @override
  String get accountWholesaler => 'Wholesaler';

  @override
  String get accountOther => 'Other';

  @override
  String get accountReferralBuyer => 'Buyer';

  @override
  String get accountReferralSupplier => 'Supplier';

  @override
  String get accountStatusPending => 'Pending';

  @override
  String get accountStatusEligible => 'Eligible';

  @override
  String get accountStatusPaid => 'Paid';

  @override
  String get accountStatusRejected => 'Rejected';

  @override
  String get supplierLotsTab => 'My lots';

  @override
  String get supplierRevenueTab => 'Income';

  @override
  String get supplierLotDashboard => 'Lot overview';

  @override
  String get supplierDeclareLot => 'Declare a lot';

  @override
  String get supplierLotPendingCount => 'Awaiting review';

  @override
  String get supplierLotAvailableCount => 'Available';

  @override
  String get supplierLotReservedCount => 'Reserved';

  @override
  String get supplierLotSoldCount => 'Sold out';

  @override
  String get supplierAllStatuses => 'All statuses';

  @override
  String get supplierLotStatusPending => 'Awaiting validation';

  @override
  String get supplierLotStatusAvailable => 'Available';

  @override
  String get supplierLotStatusReserved => 'Fully reserved';

  @override
  String get supplierLotStatusSold => 'Sold out';

  @override
  String get supplierLotStatusExpired => 'Expired';

  @override
  String get supplierLotStatusReturned => 'Returned';

  @override
  String get supplierLotStatusRejected => 'Rejected';

  @override
  String get supplierLotStatusWithdrawn => 'Withdrawn';

  @override
  String get supplierLotEmpty => 'No lots yet. Declare your first lot.';

  @override
  String get supplierLotProductStep => 'Product';

  @override
  String get supplierLotQuantityStep => 'Quantity and price';

  @override
  String get supplierLotStorageStep => 'Storage and area';

  @override
  String get supplierLotPhotosStep => 'Photos and details';

  @override
  String get supplierLotNewTitle => 'Declare a lot';

  @override
  String get supplierLotEditTitle => 'Edit lot';

  @override
  String get supplierLotProduct => 'Product';

  @override
  String get supplierLotQuantity => 'Quantity';

  @override
  String get supplierLotAgreedPrice => 'Agreed unit price';

  @override
  String supplierLotUnitHint(String unit) {
    return 'Unit: $unit';
  }

  @override
  String get supplierLotZone => 'Area';

  @override
  String get supplierLotStorageType => 'Storage';

  @override
  String get supplierLotHubStorage => 'At a collection hub';

  @override
  String get supplierLotSiteStorage => 'At my farm';

  @override
  String get supplierLotHub => 'Collection hub';

  @override
  String get supplierLotPickupAddress => 'Pickup address';

  @override
  String get supplierLotLatitude => 'Latitude';

  @override
  String get supplierLotLongitude => 'Longitude';

  @override
  String get supplierUseLocation => 'Use my location';

  @override
  String get supplierLocationUnavailable =>
      'Location could not be obtained. Enter it manually.';

  @override
  String get supplierLotChoosePhotos => 'Add photos';

  @override
  String get supplierLotPhotosRequired => 'Add between 1 and 5 photos.';

  @override
  String get supplierLotPhotoTooLarge => 'Each photo must be 5 MB or smaller.';

  @override
  String get supplierLotHarvestedAt => 'Harvest date (optional)';

  @override
  String get supplierLotExpiresAt => 'Expiry date';

  @override
  String get supplierLotPackagingNote => 'Packaging notes';

  @override
  String get supplierLotQualityNote => 'Quality notes';

  @override
  String get supplierLotNotesLimit => 'Maximum 500 characters.';

  @override
  String get supplierLotNext => 'Next';

  @override
  String get supplierLotPrevious => 'Back';

  @override
  String get supplierLotSubmit => 'Submit lot';

  @override
  String get supplierLotSubmitted => 'Lot submitted for validation.';

  @override
  String get supplierLotQuantityError =>
      'Enter a quantity above zero with up to 3 decimal places.';

  @override
  String get supplierLotPriceError =>
      'Enter an agreed price above zero with up to 2 decimal places.';

  @override
  String get supplierLotSelectProduct => 'Choose a product.';

  @override
  String get supplierLotSelectZone => 'Choose an area.';

  @override
  String get supplierLotSelectHub => 'Choose a collection hub.';

  @override
  String get supplierLotPickupRequired =>
      'Enter the pickup address and valid coordinates.';

  @override
  String get supplierLotExpiryRequired =>
      'An expiry date is required for perishable products.';

  @override
  String get supplierLotNotesError => 'Notes must not exceed 500 characters.';

  @override
  String get supplierLotInitial => 'Initial quantity';

  @override
  String get supplierLotAvailable => 'Available quantity';

  @override
  String get supplierLotReserved => 'Reserved quantity';

  @override
  String get supplierLotSold => 'Sold quantity';

  @override
  String get supplierLotLost => 'Lost quantity';

  @override
  String get supplierLotRejectionReason => 'Reason for rejection';

  @override
  String get supplierLotContactTeam => 'Contact the team';

  @override
  String supplierLotChatPrefill(String code) {
    return 'I have a question about lot $code.';
  }

  @override
  String get supplierLotDelete => 'Delete lot';

  @override
  String get supplierLotDeleteConfirm => 'Delete this lot?';

  @override
  String get supplierLotWithdraw => 'Withdraw lot';

  @override
  String get supplierLotWithdrawReason => 'Reason for withdrawal';

  @override
  String get supplierLotWithdrawError =>
      'Enter a reason of up to 500 characters.';

  @override
  String get supplierLotEdit => 'Edit';

  @override
  String get supplierLotIncomePayouts => 'Payouts';

  @override
  String get supplierLotIncomeCompensations => 'Compensations';

  @override
  String get supplierIncomeEmpty => 'No records yet.';

  @override
  String get supplierPayoutGross => 'Gross amount';

  @override
  String get supplierPayoutCommission => 'Commission';

  @override
  String get supplierPayoutNet => 'Net amount';

  @override
  String get supplierPayoutStatusOnHold => 'On hold';

  @override
  String get supplierPayoutStatusReady => 'Ready';

  @override
  String get supplierPayoutStatusPaid => 'Paid';

  @override
  String get supplierPayoutStatusCancelled => 'Cancelled';

  @override
  String get supplierCompensationReason => 'Reason';

  @override
  String get supplierCompensationQuantity => 'Quantity';

  @override
  String get supplierCompensationAmount => 'Amount';

  @override
  String get supplierCompensationNote => 'Note';

  @override
  String get supplierCompensationStatusPending => 'Pending approval';

  @override
  String get supplierCompensationStatusApproved => 'Approved';

  @override
  String get supplierCompensationStatusPaid => 'Paid';

  @override
  String get supplierCompensationStatusRejected => 'Rejected';

  @override
  String get supplierOptional => 'Optional';

  @override
  String get supplierClear => 'Clear';

  @override
  String get supplierSave => 'Save';

  @override
  String get staffNoCapabilities =>
      'No capabilities have been assigned. Contact an administrator.';

  @override
  String get staffSupport => 'Support';

  @override
  String get staffStock => 'Stock';

  @override
  String get staffListings => 'Listings';

  @override
  String get staffOrders => 'Orders';

  @override
  String get staffVerifications => 'Verifications';

  @override
  String get staffAccount => 'Account';

  @override
  String get staffHelpAdmin => 'Contact an administrator to request access.';

  @override
  String get staffInboxAll => 'All';

  @override
  String get staffInboxUnassigned => 'Unassigned';

  @override
  String get staffInboxMine => 'Mine';

  @override
  String get staffInboxEscalated => 'Escalated';

  @override
  String get staffStatusOpen => 'Open';

  @override
  String get staffStatusWaiting => 'Waiting for customer';

  @override
  String get staffStatusClosed => 'Closed';

  @override
  String get staffLoadMore => 'Load more';

  @override
  String get staffBuyerSupport => 'Buyer';

  @override
  String get staffSupplierSupport => 'Supplier';

  @override
  String get staffLotPending => 'Pending validation';

  @override
  String get staffLotAvailable => 'Available';

  @override
  String get staffLotReserved => 'Fully reserved';

  @override
  String get staffLotSoldOut => 'Sold out';

  @override
  String get staffLotExpired => 'Expired';

  @override
  String get staffLotReturned => 'Returned';

  @override
  String get staffLotRejected => 'Rejected';

  @override
  String get staffLotWithdrawn => 'Withdrawn';

  @override
  String get staffListingDraft => 'Draft';

  @override
  String get staffListingActive => 'Active';

  @override
  String get staffListingSold => 'Sold';

  @override
  String get staffListingInactive => 'Hidden';

  @override
  String get staffSupportTypeDenied =>
      'You do not have access to handle this conversation type.';

  @override
  String get staffConversationSubject => 'Conversation';

  @override
  String get staffAssign => 'Assign to me';

  @override
  String get staffEscalate => 'Escalate';

  @override
  String get staffClose => 'Close';

  @override
  String get staffInternalNote => 'Internal note (hidden from customer)';

  @override
  String get staffMessageHint => 'Write a message';

  @override
  String get staffSend => 'Send';

  @override
  String get staffContext => 'Context';

  @override
  String get staffSuggestionReserved => 'AI suggestion — coming soon';

  @override
  String get staffValidate => 'Validate';

  @override
  String get staffReject => 'Reject';

  @override
  String get staffReturn => 'Return';

  @override
  String get staffQualityCheck => 'Quality check';

  @override
  String get staffSupplierNotVerified => 'The supplier is not verified.';

  @override
  String get staffSupplierReview => 'Supplier review';

  @override
  String get staffReason => 'Reason';

  @override
  String get staffGrade => 'Grade';

  @override
  String get staffNotes => 'Notes';

  @override
  String get staffListingCreate => 'Create listing';

  @override
  String get staffLotId => 'Validated lot ID';

  @override
  String get staffTitle => 'Title';

  @override
  String get staffDescription => 'Description';

  @override
  String get staffPrice => 'Unit price';

  @override
  String get staffPhotosRequired => 'Select 1 to 5 photos.';

  @override
  String get staffPhotoInvalid =>
      'Unsupported photo format or file larger than 5 MB.';

  @override
  String get staffStatusFilter => 'Status';

  @override
  String get staffSupplierId => 'Supplier ID';

  @override
  String get staffProductId => 'Product ID';

  @override
  String get staffPublish => 'Publish';

  @override
  String get staffUnpublish => 'Unpublish';

  @override
  String get staffEdit => 'Edit';

  @override
  String get staffCreate => 'Create';

  @override
  String get staffNoData => 'Nothing here yet.';

  @override
  String get staffPriceBelowSupplier =>
      'The price cannot be below the agreed price.';

  @override
  String get staffLotAlreadyLinked =>
      'This lot is already linked to a listing.';

  @override
  String get staffLotNotAvailable => 'This lot is not available.';

  @override
  String get staffFileRequired => 'Add the required photos.';

  @override
  String get staffCreateQuote => 'Create a quote';

  @override
  String get staffNoOrders => 'There are no orders to process.';

  @override
  String get staffOrderDetail => 'Order details';

  @override
  String get staffPaymentUnknown => 'Payment status unknown';

  @override
  String get staffQuoteExpires => 'Quote reserved until';

  @override
  String get staffSupplierUnitPrice => 'Supplier price';

  @override
  String get staffCommission => 'Commission';

  @override
  String get staffSupplierNet => 'Supplier net';

  @override
  String get staffSubtotal => 'Subtotal';

  @override
  String get staffBuyerFee => 'Buyer fee';

  @override
  String get staffDeliveryFee => 'Delivery fee';

  @override
  String get staffOrderTotal => 'Total calculated by the server';

  @override
  String get staffConfirmQuote => 'Confirm quote';

  @override
  String get staffCancelOrder => 'Cancel order';

  @override
  String get staffPaymentRequired => 'Payment is required before preparation.';

  @override
  String get staffPayments => 'Payments';

  @override
  String get staffRecordPayment => 'Record payment';

  @override
  String get staffNoPayments => 'No payments recorded.';

  @override
  String get staffAmount => 'Amount (XAF)';

  @override
  String get staffPaymentMethod => 'Payment method';

  @override
  String get staffCash => 'Cash';

  @override
  String get staffMobileMoney => 'Mobile Money';

  @override
  String get staffBankTransfer => 'Bank transfer';

  @override
  String get staffReferenceOptional => 'Reference (optional)';

  @override
  String get staffRefund => 'Refund';

  @override
  String get staffDeliveries => 'Deliveries';

  @override
  String get staffNoDeliveries => 'No deliveries created.';

  @override
  String get staffAgency => 'Agency';

  @override
  String get staffPickup => 'Pickup';

  @override
  String get staffDropoff => 'Destination';

  @override
  String get staffAgencyCost => 'Agency cost';

  @override
  String get staffInsuredValue => 'Insured value';

  @override
  String get staffReleaseDelivery => 'Release';

  @override
  String get staffRedispatchDelivery => 'Redispatch';

  @override
  String get staffCancelDelivery => 'Cancel delivery';

  @override
  String get staffReasonOptional => 'Reason (optional)';

  @override
  String get staffCreateDeliveries => 'Create deliveries';

  @override
  String get staffDeliveryUnknown => 'Delivery status unknown';

  @override
  String get staffDeliveryAvailable => 'Delivery available';

  @override
  String get staffDeliveryUnavailable => 'No delivery available';

  @override
  String get staffBuyer => 'Buyer';

  @override
  String get staffActiveListing => 'Active listing';

  @override
  String get staffQuantity => 'Quantity';

  @override
  String get staffUnitPriceOptional => 'Unit price (optional)';

  @override
  String get staffRemoveLine => 'Remove line';

  @override
  String get staffAddLine => 'Add line';

  @override
  String get staffDeliveryMode => 'Delivery mode';

  @override
  String get staffHubPickup => 'Pickup at a hub';

  @override
  String get staffAgencyDelivery => 'Agency delivery';

  @override
  String get staffPickupHub => 'Pickup hub';

  @override
  String get staffDeliveryZone => 'Delivery zone';

  @override
  String get staffAddress => 'Delivery address';

  @override
  String get staffLatitude => 'Latitude';

  @override
  String get staffLongitude => 'Longitude';

  @override
  String get staffNotesOptional => 'Note (optional)';

  @override
  String get staffServerCalculatesTotals =>
      'Fees, commissions, and totals are calculated by the server.';

  @override
  String get staffQuoteCreated => 'Quote created.';

  @override
  String get staffDeadlineNotProvided => 'an unspecified date';

  @override
  String staffQuoteCreatedMessage(String deadline) {
    return 'Your quote is ready. It is reserved until $deadline.';
  }

  @override
  String get staffDocumentStatus => 'Document status';

  @override
  String get staffDocumentType => 'Document type';

  @override
  String get staffAccountRole => 'Account role';

  @override
  String get staffUserId => 'User ID';

  @override
  String get staffNoVerifications => 'There are no documents to review.';

  @override
  String get staffVerificationRuleApprove =>
      'Approval verifies the document. The account is verified when it has at least one verified document and none pending.';

  @override
  String get staffVerificationRuleReject =>
      'A rejection marks the account rejected only if it has no other verified document.';

  @override
  String get staffFileMissing =>
      'The file is missing. Refresh the detail to request a new link.';

  @override
  String get staffUnsupportedDocument =>
      'This document format is not supported.';

  @override
  String get staffOpenPrivatePdf => 'Open private PDF';

  @override
  String get staffApprove => 'Approve';

  @override
  String get staffRejectionNote => 'Reason for rejection (required)';

  @override
  String get staffHumanActorRequired =>
      'This action must be performed by a human.';

  @override
  String get staffInsufficientStock => 'There is not enough stock available.';

  @override
  String get staffZoneNotCovered => 'This zone is not covered.';

  @override
  String get staffInvalidHub => 'The pickup hub is not valid.';

  @override
  String get staffCompensationRateZero =>
      'The compensation rate is not set (configure it as ROOT).';

  @override
  String get staffPrivateFileWrongReviewer =>
      'This private link belongs to another reviewer account or has expired. Refresh the detail.';

  @override
  String get staffVerificationAlreadyReviewed =>
      'This document was already reviewed. The queue has been refreshed.';

  @override
  String get staffStatusQuoted => 'Quoted';

  @override
  String get staffStatusConfirmed => 'Confirmed';

  @override
  String get staffStatusPreparing => 'Preparing';

  @override
  String get staffStatusReadyForPickup => 'Ready for pickup';

  @override
  String get staffStatusOutForDelivery => 'Out for delivery';

  @override
  String get staffStatusCompleted => 'Completed';

  @override
  String get staffStatusCancelled => 'Cancelled';

  @override
  String get staffPositiveAmount => 'Enter an amount greater than zero.';

  @override
  String get staffCompensate => 'Request compensation';

  @override
  String get staffReasonExpiredUnsold => 'Expired and unsold';

  @override
  String get staffReasonLostDamaged => 'Lost or damaged';

  @override
  String get staffReasonOther => 'Other';

  @override
  String get staffCompensationQuantity => 'Quantity for compensation';

  @override
  String get staffLotQuantity => 'Lot quantity';

  @override
  String get staffDeliveryIdOptional => 'Delivery ID (optional)';

  @override
  String get staffCompensationSubmitted => 'Compensation request submitted.';

  @override
  String get staffPaymentUnpaid => 'Unpaid';

  @override
  String get staffPaymentPartiallyPaid => 'Partially paid';

  @override
  String get staffPaymentPaid => 'Paid';

  @override
  String get staffPaymentRefunded => 'Refunded';

  @override
  String get staffDeliveryPending => 'Pending';

  @override
  String get staffDeliveryAccepted => 'Accepted';

  @override
  String get staffDeliveryPickedUp => 'Picked up';

  @override
  String get staffDeliveryInTransit => 'In transit';

  @override
  String get staffDeliveryDelivered => 'Delivered';

  @override
  String get staffDeliveryFailed => 'Failed';

  @override
  String get staffDeliveryCancelled => 'Cancelled';

  @override
  String get staffDocumentPending => 'Pending';

  @override
  String get staffDocumentVerified => 'Verified';

  @override
  String get staffDocumentRejected => 'Rejected';

  @override
  String get staffDocumentIdCard => 'Identity card';

  @override
  String get staffDocumentBusinessRegistration => 'Business registration';

  @override
  String get staffDocumentFarmProof => 'Farm proof';

  @override
  String get staffDocumentOther => 'Other';

  @override
  String get staffInsurancePolicy => 'Insurance policy';

  @override
  String get staffPrivateDocumentOpenFailed =>
      'The private document could not be opened.';
}
