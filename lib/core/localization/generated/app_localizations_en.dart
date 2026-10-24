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
  String get sectionTrips => 'Trips';

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
      'There are no demonstration notifications for this account.';

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
  String get notificationSupplierOrderTitle => 'Example incoming order';

  @override
  String get notificationSupplierOrderBody =>
      'A sample buyer order is listed in your orders.';

  @override
  String get notificationSupplierProductTitle => 'Example product action';

  @override
  String get notificationSupplierProductBody =>
      'A sample product may need attention in your catalog.';

  @override
  String get notificationDriverDeliveryTitle => 'Example assigned delivery';

  @override
  String get notificationDriverDeliveryBody =>
      'A sample delivery is available in your delivery list.';

  @override
  String get notificationDriverTripTitle => 'Example trip update';

  @override
  String get notificationDriverTripBody =>
      'A sample route update is available in your trips.';

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
  String get retry => 'Try again';

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
  String get supplierProductsOnSaleTitle => 'Products currently on sale';

  @override
  String get dashboardManageProducts => 'Manage my products';

  @override
  String get dashboardRefreshTooltip => 'Refresh the dashboard';

  @override
  String get dashboardQuickAddProduct => 'Add a product';

  @override
  String get dashboardQuickExplore => 'Explore products';

  @override
  String get dashboardQuickCart => 'My cart';

  @override
  String get dashboardQuickMyOrders => 'My orders';

  @override
  String get dashboardCartEmpty => 'Empty cart';

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
  String get catalogEmptyTitle => 'No products available';

  @override
  String get catalogEmptyBody => 'The catalog will fill up soon.';

  @override
  String get searchCatalog => 'Search for a product';

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
  String get addToCart => 'Add to cart';

  @override
  String addedToCart(String name) {
    return '$name added to cart.';
  }

  @override
  String get goToCart => 'Order';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Browse the catalog and add products.';

  @override
  String get viewCatalog => 'View catalog';

  @override
  String get cartClear => 'Clear';

  @override
  String itemsCount(int count) {
    return '$count item(s)';
  }

  @override
  String get cartClearTitle => 'Empty the cart?';

  @override
  String cartClearBody(int count) {
    return 'The $count selected item(s) will be removed from the cart.';
  }

  @override
  String get cartClearConfirm => 'Empty the cart';

  @override
  String get cartContinueShopping => 'Continue shopping';

  @override
  String cartStockRemaining(int count) {
    return 'Available stock: $count';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutTitleAction => 'Checkout';

  @override
  String get checkoutEditCart => 'Edit the cart';

  @override
  String checkoutSummary(int count, String total) {
    return '$count item(s) · $total';
  }

  @override
  String get checkoutErrorTitle => 'Order not placed';

  @override
  String get removeFromCart => 'Remove from cart';

  @override
  String get checkoutDeliveryTitle => 'Delivery address';

  @override
  String get checkoutAddressLabel => 'Address';

  @override
  String get checkoutPhoneLabel => 'Phone';

  @override
  String get checkoutNoteLabel => 'Delivery note (optional)';

  @override
  String get checkoutItemsTitle => 'Items';

  @override
  String get placeOrder => 'Place the order';

  @override
  String get placingOrder => 'Placing order…';

  @override
  String get confirmationTitle => 'Order confirmed';

  @override
  String get confirmationHeadline => 'Thank you, your order is registered.';

  @override
  String get confirmationBody =>
      'The sellers received your request. You will be notified at every delivery step.';

  @override
  String get confirmationNextTitle => 'What happens next?';

  @override
  String get confirmationStepSeller => 'The seller prepares your products';

  @override
  String get confirmationStepDriver => 'A driver is assigned to the delivery';

  @override
  String get confirmationStepDelivered => 'You receive your products';

  @override
  String get confirmationTrackOrder => 'Track my order';

  @override
  String get confirmationContinueShopping => 'Continue shopping';

  @override
  String productPricePerUnit(String unit) {
    return '/ $unit';
  }

  @override
  String productAlreadyInCart(int count) {
    return 'Already in the cart · $count';
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
  String get driverUpcomingTrips => 'Upcoming trips';

  @override
  String get tripStatusUpcoming => 'Upcoming';

  @override
  String get tripStatusActive => 'In progress';

  @override
  String get tripStatusCompleted => 'Completed';

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
  String get driverTripsEmptyTitle => 'No trips';

  @override
  String get driverTripsEmptyBody => 'Your trips will appear here.';

  @override
  String get driverNoUpcomingTripTitle => 'No upcoming trip';

  @override
  String get driverNoUpcomingTripBody =>
      'Completed routes stay in your history.';

  @override
  String get driverDeliveryNotFound => 'Delivery not found.';

  @override
  String get driverHeroSubtitle =>
      'Your routes and deliveries, all in one place.';

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
  String tripStopsProgress(int completed, int total) {
    return '$completed / $total stops delivered';
  }

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
    return '$count $unit in stock';
  }

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
}
