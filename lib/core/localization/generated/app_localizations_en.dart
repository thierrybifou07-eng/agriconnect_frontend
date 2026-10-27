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
  String get adminModerationPending => 'Pending';

  @override
  String get adminModerationValidated => 'Live';

  @override
  String get adminModerationSuspended => 'Suspended';

  @override
  String get adminModerationRejected => 'Rejected';

  @override
  String get adminModerationArchived => 'Archived';

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
  String get adminProductsTitle => 'Product management';

  @override
  String get adminProductsSearchHint => 'Search a product…';

  @override
  String get adminProductsEmpty => 'No product matches';

  @override
  String get adminProductsUpdated => 'Product updated.';

  @override
  String get adminProductsRejectTitle => 'Reject product';

  @override
  String get adminProductsRejectReasonHint => 'Reason for rejection…';

  @override
  String get adminProductsRejectAction => 'Reject';

  @override
  String get adminProductApprove => 'Approve';

  @override
  String get adminProductArchive => 'Archive';

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
  String get adminStatProducts => 'Products';

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
  String adminStatProductsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products to moderate',
      one: '1 product to moderate',
      zero: 'No product to moderate',
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
  String adminAttentionProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products to moderate',
      one: 'Product to moderate',
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
  String get adminQuickActionProducts => 'Products';

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
  String get adminDistributionProducts => 'Products by status';

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
  String get adminAnalyticsPublished => 'Published products';

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
  String get adminModerationTitle => 'Products to moderate';

  @override
  String get adminModerationEmpty => 'No product is waiting for a decision';

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
  String get navMore => 'More';

  @override
  String get navHome => 'Home';

  @override
  String get superAdminConsoleSubtitle =>
      'Platform-wide oversight of AgriConnect.';

  @override
  String get superAdminRefreshTooltip => 'Refresh the console';

  @override
  String get superAdminConsoleLabel => 'Platform console';

  @override
  String get superAdminTodayLabel => 'Today';

  @override
  String get superAdminOverviewTitle => 'Overview';

  @override
  String get superAdminStatUsers => 'Users';

  @override
  String superAdminStatUsersCaption(int count) {
    return '$count awaiting verification';
  }

  @override
  String get superAdminStatStaff => 'Staff';

  @override
  String get superAdminStatStaffCaption => 'accounts active on the platform';

  @override
  String get superAdminStatProducts => 'Products';

  @override
  String superAdminStatProductsCaption(int count) {
    return '$count products published';
  }

  @override
  String get superAdminStatDeliveries => 'Deliveries';

  @override
  String superAdminStatDeliveriesCaption(int count) {
    return '$count currently in progress';
  }

  @override
  String get superAdminStatGmv => 'Gross merchandise value';

  @override
  String get superAdminStatGmvCaption => 'Total value of every recorded order';

  @override
  String get superAdminAttentionTitle => 'Needs supervision';

  @override
  String get superAdminAttentionModeration => 'Products to moderate';

  @override
  String get superAdminAttentionUsers => 'Accounts to verify';

  @override
  String get superAdminAttentionDeliveries => 'Deliveries in progress';

  @override
  String get superAdminAttentionClearTitle => 'The platform asks for nothing';

  @override
  String get superAdminAttentionClearBody =>
      'No product, account or delivery is waiting for a decision.';

  @override
  String get superAdminQuickActionsTitle => 'Quick access';

  @override
  String get superAdminQuickActionStaff => 'Staff';

  @override
  String get superAdminQuickActionPlatform => 'Platform';

  @override
  String get superAdminQuickActionAnalytics => 'Analytics';

  @override
  String get superAdminDistributionTitle => 'Distribution';

  @override
  String get superAdminDistributionStaff => 'Staff by access level';

  @override
  String get superAdminActivityTitle => 'Recent activity';

  @override
  String get superAdminActivityEmpty => 'No activity recorded yet';

  @override
  String superAdminActivityActor(String actor, String action) {
    return '$actor — $action';
  }

  @override
  String get superAdminSectionLoadError => 'This section could not be loaded';

  @override
  String superAdminSectionLoadErrorDetail(String message) {
    return '$message';
  }

  @override
  String get superAdminStaffTitle => 'Staff management';

  @override
  String get superAdminStaffSubtitle =>
      'Staff accounts and the rights granted to them';

  @override
  String get superAdminStaffSearchHint => 'Search a staff member';

  @override
  String get superAdminStaffSearchLabel => 'Search the staff directory';

  @override
  String get superAdminStaffEmpty => 'No staff member matches this search';

  @override
  String get superAdminStaffFilterRole => 'Role';

  @override
  String get superAdminStaffFilterStatus => 'Status';

  @override
  String get superAdminStaffStatusActive => 'Active';

  @override
  String get superAdminStaffStatusSuspended => 'Suspended';

  @override
  String get superAdminStaffReset => 'Reset';

  @override
  String superAdminStaffCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count staff members',
      one: '1 staff member',
      zero: 'No staff member',
    );
    return '$_temp0';
  }

  @override
  String superAdminStaffLastActive(String date) {
    return 'Active $date';
  }

  @override
  String superAdminStaffPermissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rights',
      one: '1 right',
      zero: 'No rights',
    );
    return '$_temp0';
  }

  @override
  String get superAdminStaffProtectedNotice =>
      'This account cannot be modified from the console.';

  @override
  String get superAdminStaffAccessReadOnly => 'Read only';

  @override
  String get superAdminStaffAccessFull => 'Full access';

  @override
  String get superAdminStaffAccessSuspended => 'Suspended';

  @override
  String get superAdminStaffSuspend => 'Suspend the account';

  @override
  String get superAdminStaffRestore => 'Restore as read only';

  @override
  String superAdminStaffPermissionsTitle(String name) {
    return 'Rights of $name';
  }

  @override
  String get superAdminStaffPermissionsSubtitle =>
      'Settings rights stay reserved to the Root.';

  @override
  String get superAdminStaffPermissionsSave => 'Save rights';

  @override
  String get superAdminStaffPermissionsSaved => 'Rights updated';

  @override
  String get superAdminStaffSuspended => 'Account suspended';

  @override
  String get superAdminStaffRestored => 'Account restored as read only';

  @override
  String get superAdminPermissionMarketplace => 'Marketplace';

  @override
  String get superAdminPermissionPeople => 'Users';

  @override
  String get superAdminPermissionPlatform => 'Platform';

  @override
  String get superAdminPermissionModerateProducts => 'Moderate products';

  @override
  String get superAdminPermissionModerateProductsBody =>
      'Approve, reject and archive products.';

  @override
  String get superAdminPermissionManageUsers => 'Manage users';

  @override
  String get superAdminPermissionManageUsersBody =>
      'Verify accounts and apply sanctions.';

  @override
  String get superAdminPermissionSuperviseDeliveries => 'Supervise deliveries';

  @override
  String get superAdminPermissionSuperviseDeliveriesBody =>
      'Follow routes and assign drivers.';

  @override
  String get superAdminPermissionManageOrders => 'Process orders';

  @override
  String get superAdminPermissionManageOrdersBody =>
      'Move orders to the right state.';

  @override
  String get superAdminPermissionViewAnalytics => 'View analytics';

  @override
  String get superAdminPermissionViewAnalyticsBody =>
      'Read the platform indicators.';

  @override
  String get superAdminPermissionManageSettings => 'Manage settings';

  @override
  String get superAdminPermissionManageSettingsBody =>
      'Change the platform configuration.';

  @override
  String get superAdminPermissionLocked => 'Reserved to the Root';

  @override
  String get superAdminActionSuspended => 'suspended';

  @override
  String get superAdminActionRestored => 'restored';

  @override
  String get superAdminActionUpdatedPermissions => 'changed the rights of';

  @override
  String get superAdminActionUpdatedSettings => 'updated';

  @override
  String get superAdminActionModeratedProduct => 'moderated the product';

  @override
  String get superAdminPlatformTitle => 'System settings';

  @override
  String get superAdminPlatformSubtitle =>
      'Configuration applied to the whole platform';

  @override
  String get superAdminSettingRegistrations => 'Open registrations';

  @override
  String get superAdminSettingRegistrationsBody =>
      'Allows or blocks the creation of new accounts.';

  @override
  String get superAdminSettingAutoModeration => 'Automatic moderation';

  @override
  String get superAdminSettingAutoModerationBody =>
      'Publishes products without a human review.';

  @override
  String get superAdminSettingAutoModerationWarning =>
      'Products will be visible without review.';

  @override
  String get superAdminSettingMaintenance => 'Maintenance mode';

  @override
  String get superAdminSettingMaintenanceBody =>
      'Hides the marketplace from users.';

  @override
  String get superAdminSettingMaintenanceWarning =>
      'The marketplace will be unreachable.';

  @override
  String get superAdminSettingSupportEmail => 'Support email';

  @override
  String get superAdminSettingSupportEmailBody =>
      'Address shown to users when they need help.';

  @override
  String get superAdminSettingSupportEmailInvalid => 'Invalid email address.';

  @override
  String get superAdminSettingMaxUpload => 'Maximum photo size';

  @override
  String get superAdminSettingMaxUploadBody =>
      'In megabytes, applied to products.';

  @override
  String get superAdminSettingMaxUploadInvalid =>
      'The value must be between 1 and 20 MB.';

  @override
  String superAdminSettingUpdatedAt(String date) {
    return 'Last updated: $date';
  }

  @override
  String get superAdminSettingsSaved => 'Settings saved';

  @override
  String get superAdminSettingsUnsaved =>
      'Unsaved changes. They take effect when you save.';

  @override
  String get superAdminSettingsSave => 'Save settings';

  @override
  String get superAdminSettingsSaveError => 'The settings could not be saved.';

  @override
  String get superAdminAnalyticsTitle => 'Platform analytics';

  @override
  String get superAdminAnalyticsSubtitle =>
      'Figures computed across the whole marketplace';

  @override
  String get superAdminAnalyticsAudience => 'Accounts by role';

  @override
  String superAdminAnalyticsOrdersCaption(int count) {
    return '$count orders in total';
  }

  @override
  String superAdminAnalyticsOpenOrdersCaption(int count) {
    return '$count orders still open';
  }

  @override
  String superAdminAnalyticsPublishedCaption(int count) {
    return '$count products live';
  }

  @override
  String get superAdminAnalyticsNoTrend =>
      'History is not available on this demo build yet.';

  @override
  String get superAdminAnalyticsStaffCaption => 'Staff accounts';

  @override
  String get superAdminStatOrders => 'Orders';

  @override
  String get superAdminAnalyticsOpenOrders => 'Open orders';

  @override
  String get superAdminAnalyticsStaffShare => 'Rights granted to staff';

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
}
