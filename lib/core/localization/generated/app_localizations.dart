import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'The connected agricultural marketplace'**
  String get tagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your workspace…'**
  String get splashLoading;

  /// No description provided for @loginGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginGreeting;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your workspace'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @demoAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo accounts'**
  String get demoAccountsTitle;

  /// No description provided for @demoAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an account to pre-fill the form.'**
  String get demoAccountsHint;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get validationPasswordRequired;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please try again.'**
  String get errInvalidCredentials;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errNetwork;

  /// No description provided for @errTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please retry.'**
  String get errTimeout;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please retry later.'**
  String get errServer;

  /// No description provided for @errCache.
  ///
  /// In en, this message translates to:
  /// **'Unable to access local storage.'**
  String get errCache;

  /// No description provided for @errUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnexpected;

  /// No description provided for @errRoleNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Creating an account for this role is not allowed.'**
  String get errRoleNotAllowed;

  /// No description provided for @errAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Your session is not allowed to perform this action.'**
  String get errAccessDenied;

  /// No description provided for @errSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errSessionExpired;

  /// No description provided for @roleSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get roleSupplier;

  /// No description provided for @roleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get roleBuyer;

  /// No description provided for @roleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get roleDriver;

  /// No description provided for @roleAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get roleAgent;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleRoot.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get roleRoot;

  /// No description provided for @sectionDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get sectionDashboard;

  /// No description provided for @sectionProducts.
  ///
  /// In en, this message translates to:
  /// **'My products'**
  String get sectionProducts;

  /// No description provided for @sectionOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sectionOrders;

  /// No description provided for @sectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get sectionProfile;

  /// No description provided for @sectionCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get sectionCatalog;

  /// No description provided for @sectionDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get sectionDeliveries;

  /// No description provided for @sectionTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get sectionTrips;

  /// No description provided for @sectionUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get sectionUsers;

  /// No description provided for @sectionAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get sectionAnalytics;

  /// No description provided for @sectionPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get sectionPlatform;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get notificationsMarkRead;

  /// No description provided for @socketReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get socketReconnecting;

  /// No description provided for @notificationMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get notificationMessageTitle;

  /// No description provided for @notificationMessageBody.
  ///
  /// In en, this message translates to:
  /// **'You received a reply in a conversation.'**
  String get notificationMessageBody;

  /// No description provided for @notificationDeliveryAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New delivery available'**
  String get notificationDeliveryAvailableTitle;

  /// No description provided for @notificationDeliveryAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A delivery is available for your agency.'**
  String get notificationDeliveryAvailableBody;

  /// No description provided for @notificationDeliveryStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery update'**
  String get notificationDeliveryStatusTitle;

  /// No description provided for @notificationDeliveryStatusBody.
  ///
  /// In en, this message translates to:
  /// **'The status of your delivery has changed.'**
  String get notificationDeliveryStatusBody;

  /// No description provided for @notificationExpiringTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry alert'**
  String get notificationExpiringTitle;

  /// No description provided for @notificationExpiringBody.
  ///
  /// In en, this message translates to:
  /// **'A lot is approaching its expiry date.'**
  String get notificationExpiringBody;

  /// No description provided for @notificationAiSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion'**
  String get notificationAiSuggestionTitle;

  /// No description provided for @notificationAiSuggestionBody.
  ///
  /// In en, this message translates to:
  /// **'A suggestion is available in the support queue.'**
  String get notificationAiSuggestionBody;

  /// No description provided for @notificationsRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsRead;

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'Unread: {count}'**
  String notificationsUnreadCount(String count);

  /// No description provided for @notificationsDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demonstration examples only. These are not live alerts and are not synchronized with a server.'**
  String get notificationsDemoNotice;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New messages and important events will appear here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be loaded.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsCategoryOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get notificationsCategoryOrders;

  /// No description provided for @notificationsCategoryProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get notificationsCategoryProducts;

  /// No description provided for @notificationsCategoryDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get notificationsCategoryDeliveries;

  /// No description provided for @notificationsCategorySupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get notificationsCategorySupport;

  /// No description provided for @notificationsCategoryAdministration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get notificationsCategoryAdministration;

  /// No description provided for @notificationBuyerOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Example order update'**
  String get notificationBuyerOrderTitle;

  /// No description provided for @notificationBuyerOrderBody.
  ///
  /// In en, this message translates to:
  /// **'A sample order status update is shown here.'**
  String get notificationBuyerOrderBody;

  /// No description provided for @notificationBuyerDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Example delivery update'**
  String get notificationBuyerDeliveryTitle;

  /// No description provided for @notificationBuyerDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'A sample delivery progress update is shown here.'**
  String get notificationBuyerDeliveryBody;

  /// No description provided for @notificationDriverDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Example assigned delivery'**
  String get notificationDriverDeliveryTitle;

  /// No description provided for @notificationDriverDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'A sample delivery is available in your delivery list.'**
  String get notificationDriverDeliveryBody;

  /// No description provided for @notificationDriverTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Example trip update'**
  String get notificationDriverTripTitle;

  /// No description provided for @notificationDriverTripBody.
  ///
  /// In en, this message translates to:
  /// **'A sample route update is available in your trips.'**
  String get notificationDriverTripBody;

  /// No description provided for @notificationAgentSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Example support request'**
  String get notificationAgentSupportTitle;

  /// No description provided for @notificationAgentSupportBody.
  ///
  /// In en, this message translates to:
  /// **'A sample buyer request is available in the support queue.'**
  String get notificationAgentSupportBody;

  /// No description provided for @notificationAgentOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Example order task'**
  String get notificationAgentOrderTitle;

  /// No description provided for @notificationAgentOrderBody.
  ///
  /// In en, this message translates to:
  /// **'A sample order task is available for processing.'**
  String get notificationAgentOrderBody;

  /// No description provided for @notificationAgentStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Example stock review'**
  String get notificationAgentStockTitle;

  /// No description provided for @notificationAgentStockBody.
  ///
  /// In en, this message translates to:
  /// **'A sample stock declaration is available for review.'**
  String get notificationAgentStockBody;

  /// No description provided for @notificationAdminProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Example product review'**
  String get notificationAdminProductTitle;

  /// No description provided for @notificationAdminProductBody.
  ///
  /// In en, this message translates to:
  /// **'A sample product is available in the moderation list.'**
  String get notificationAdminProductBody;

  /// No description provided for @notificationAdminOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Example order activity'**
  String get notificationAdminOrderTitle;

  /// No description provided for @notificationAdminOrderBody.
  ///
  /// In en, this message translates to:
  /// **'A sample order is available in the administration workspace.'**
  String get notificationAdminOrderBody;

  /// No description provided for @notificationRootPlatformTitle.
  ///
  /// In en, this message translates to:
  /// **'Example platform activity'**
  String get notificationRootPlatformTitle;

  /// No description provided for @notificationRootPlatformBody.
  ///
  /// In en, this message translates to:
  /// **'A sample platform event is available in the platform console.'**
  String get notificationRootPlatformBody;

  /// No description provided for @notificationRootStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Example staff activity'**
  String get notificationRootStaffTitle;

  /// No description provided for @notificationRootStaffBody.
  ///
  /// In en, this message translates to:
  /// **'A sample staff event is available in the user directory.'**
  String get notificationRootStaffBody;

  /// No description provided for @underConstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Section under construction'**
  String get underConstructionTitle;

  /// No description provided for @underConstructionBody.
  ///
  /// In en, this message translates to:
  /// **'This section will be available in a coming stage of AgriConnect.'**
  String get underConstructionBody;

  /// No description provided for @comingSoonBadge.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonBadge;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The address you requested does not exist.'**
  String get routeNotFoundBody;

  /// No description provided for @routeNotFoundHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get routeNotFoundHome;

  /// Greeting shown on the role dashboard.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your workspace'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardQuickOrders.
  ///
  /// In en, this message translates to:
  /// **'Received orders'**
  String get dashboardQuickOrders;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Action that returns to the previous screen.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @connectedAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get connectedAs;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get accountInfo;

  /// No description provided for @profileEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditAction;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get profileEditTitle;

  /// No description provided for @profileEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Update the name displayed on your account.'**
  String get profileEditDescription;

  /// No description provided for @profileSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSaveAction;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated on this device.'**
  String get profileUpdated;

  /// No description provided for @profileDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get profileDiscardTitle;

  /// No description provided for @profileDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved name change will be lost.'**
  String get profileDiscardBody;

  /// No description provided for @profileDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get profileDiscardAction;

  /// No description provided for @profileKeepEditingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get profileKeepEditingAction;

  /// No description provided for @profileNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name between 2 and 80 characters.'**
  String get profileNameInvalid;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @capabilityBuyerSupport.
  ///
  /// In en, this message translates to:
  /// **'Buyer support'**
  String get capabilityBuyerSupport;

  /// No description provided for @capabilityStockValidation.
  ///
  /// In en, this message translates to:
  /// **'Stock validation'**
  String get capabilityStockValidation;

  /// No description provided for @capabilityOrderProcessing.
  ///
  /// In en, this message translates to:
  /// **'Order processing'**
  String get capabilityOrderProcessing;

  /// No description provided for @capabilityPaymentFollowup.
  ///
  /// In en, this message translates to:
  /// **'Payment follow-up'**
  String get capabilityPaymentFollowup;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'A connected agricultural marketplace'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Buy and sell fresh, local produce directly between suppliers, buyers and traders.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Trusted deliveries'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Reliable drivers move your goods, from the farm to the point of sale, with complete peace of mind.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'A community that connects you'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Suppliers, buyers, drivers and administrators united for transparent, efficient exchanges.'**
  String get onboardingSlide3Body;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it at any time.'**
  String get languageSubtitle;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @roleTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your profile?'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the role that matches you to personalize your experience.'**
  String get roleSubtitle;

  /// No description provided for @roleSupplierDesc.
  ///
  /// In en, this message translates to:
  /// **'I sell my agricultural products'**
  String get roleSupplierDesc;

  /// No description provided for @roleBuyerDesc.
  ///
  /// In en, this message translates to:
  /// **'I buy local products'**
  String get roleBuyerDesc;

  /// No description provided for @roleDriverDesc.
  ///
  /// In en, this message translates to:
  /// **'I deliver and transport goods'**
  String get roleDriverDesc;

  /// No description provided for @roleAgentDesc.
  ///
  /// In en, this message translates to:
  /// **'I support users and the platform'**
  String get roleAgentDesc;

  /// No description provided for @roleAdminDesc.
  ///
  /// In en, this message translates to:
  /// **'I manage users and the platform'**
  String get roleAdminDesc;

  /// No description provided for @roleRootDesc.
  ///
  /// In en, this message translates to:
  /// **'I oversee the entire platform'**
  String get roleRootDesc;

  /// No description provided for @loginSelectedRole.
  ///
  /// In en, this message translates to:
  /// **'Selected profile'**
  String get loginSelectedRole;

  /// No description provided for @loginChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get loginChangeRole;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the marketplace in seconds.'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @registerCreate.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get registerCreate;

  /// No description provided for @registerCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get registerCreating;

  /// No description provided for @registerAlreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerAlreadyAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignIn;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get validationNameRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordMismatch;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters long.'**
  String get validationPasswordTooShort;

  /// No description provided for @validationNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'The name must be at least 2 characters long.'**
  String get validationNameTooShort;

  /// No description provided for @validationNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The name is too long (maximum 80 characters).'**
  String get validationNameTooLong;

  /// No description provided for @errEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email address.'**
  String get errEmailExists;

  /// No description provided for @errRoleMismatch.
  ///
  /// In en, this message translates to:
  /// **'This email address is not associated with the selected role.'**
  String get errRoleMismatch;

  /// No description provided for @registerAsRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'You are registering as'**
  String get registerAsRoleTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardOverview;

  /// No description provided for @productStatusOnSale.
  ///
  /// In en, this message translates to:
  /// **'On sale'**
  String get productStatusOnSale;

  /// No description provided for @productStatusOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productStatusOutOfStock;

  /// No description provided for @declarationStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get declarationStatusDraft;

  /// No description provided for @declarationStatusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get declarationStatusPendingReview;

  /// No description provided for @declarationStatusAdditionalInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Additional information required'**
  String get declarationStatusAdditionalInfoRequired;

  /// No description provided for @declarationStatusUnderDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Under discussion'**
  String get declarationStatusUnderDiscussion;

  /// No description provided for @declarationStatusApprovedForPublication.
  ///
  /// In en, this message translates to:
  /// **'Approved for publication'**
  String get declarationStatusApprovedForPublication;

  /// No description provided for @declarationStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get declarationStatusRejected;

  /// No description provided for @declarationStatusSection.
  ///
  /// In en, this message translates to:
  /// **'Declaration status'**
  String get declarationStatusSection;

  /// No description provided for @declarationDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo states. In the final version, the AgriConnect team reviews every declaration and contacts you before any publication.'**
  String get declarationDemoNotice;

  /// No description provided for @declarationSaveDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Save the draft'**
  String get declarationSaveDraftAction;

  /// No description provided for @declarationSubmittedSnack.
  ///
  /// In en, this message translates to:
  /// **'Declaration submitted. It will be reviewed before any publication.'**
  String get declarationSubmittedSnack;

  /// No description provided for @declarationDraftSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Draft saved. It is not visible to buyers.'**
  String get declarationDraftSavedSnack;

  /// No description provided for @supplierWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your supplier workspace'**
  String get supplierWelcomeTitle;

  /// No description provided for @supplierWelcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String supplierWelcomeGreeting(String name);

  /// No description provided for @supplierWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Declare your products in a few minutes. The AgriConnect team reviews every declaration and contacts you before any publication: nothing is published automatically.'**
  String get supplierWelcomeBody;

  /// No description provided for @supplierWelcomePrimary.
  ///
  /// In en, this message translates to:
  /// **'Start declaring my products'**
  String get supplierWelcomePrimary;

  /// No description provided for @supplierWelcomeSecondary.
  ///
  /// In en, this message translates to:
  /// **'Go to my dashboard'**
  String get supplierWelcomeSecondary;

  /// No description provided for @buyerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AgriConnect'**
  String get buyerWelcomeTitle;

  /// No description provided for @buyerWelcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String buyerWelcomeGreeting(String name);

  /// No description provided for @buyerWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Discover fresh products from local farmers and build your basket in a few minutes.'**
  String get buyerWelcomeBody;

  /// No description provided for @buyerWelcomePrimary.
  ///
  /// In en, this message translates to:
  /// **'Browse the catalog'**
  String get buyerWelcomePrimary;

  /// No description provided for @buyerWelcomeDismiss.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get buyerWelcomeDismiss;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save product'**
  String get saveProduct;

  /// No description provided for @savingProduct.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingProduct;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully.'**
  String get productSaved;

  /// No description provided for @productsDeclaredStat.
  ///
  /// In en, this message translates to:
  /// **'Declared products'**
  String get productsDeclaredStat;

  /// No description provided for @statConfirmedOrders.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statConfirmedOrders;

  /// No description provided for @ordersPendingStat.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get ordersPendingStat;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Declare your first product. The AgriConnect team will review it before any publication.'**
  String get productsEmptyBody;

  /// No description provided for @productsNoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'No product found'**
  String get productsNoResultTitle;

  /// No description provided for @productsNoResultBody.
  ///
  /// In en, this message translates to:
  /// **'Change your search or switch the filter.'**
  String get productsNoResultBody;

  /// No description provided for @recentProducts.
  ///
  /// In en, this message translates to:
  /// **'Recent products'**
  String get recentProducts;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get recentOrders;

  /// No description provided for @dashboardManageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage my products'**
  String get dashboardManageProducts;

  /// No description provided for @dashboardRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the dashboard'**
  String get dashboardRefreshTooltip;

  /// No description provided for @dashboardQuickAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add a product'**
  String get dashboardQuickAddProduct;

  /// No description provided for @dashboardQuickExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore products'**
  String get dashboardQuickExplore;

  /// No description provided for @dashboardQuickMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get dashboardQuickMyOrders;

  /// No description provided for @buyerHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The finest produce from the farm, delivered to you.'**
  String get buyerHeroSubtitle;

  /// No description provided for @ordersPlacedStat.
  ///
  /// In en, this message translates to:
  /// **'Orders placed'**
  String get ordersPlacedStat;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// No description provided for @roleStaffBadge.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaffBadge;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversation yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your exchanges with buyers and drivers will appear here.'**
  String get chatEmptyBody;

  /// No description provided for @chatThreadEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get chatThreadEmptyTitle;

  /// No description provided for @chatThreadEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Send a first message to kick things off.'**
  String get chatThreadEmptyBody;

  /// No description provided for @chatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get chatComposerHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get chatStartConversation;

  /// No description provided for @chatConversationSubject.
  ///
  /// In en, this message translates to:
  /// **'Conversation with the team'**
  String get chatConversationSubject;

  /// No description provided for @chatStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get chatStatusOpen;

  /// No description provided for @chatStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your reply'**
  String get chatStatusWaiting;

  /// No description provided for @chatStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get chatStatusClosed;

  /// No description provided for @chatClosedExplanation.
  ///
  /// In en, this message translates to:
  /// **'This conversation is closed. You can no longer send messages.'**
  String get chatClosedExplanation;

  /// No description provided for @chatLoadOlder.
  ///
  /// In en, this message translates to:
  /// **'Load earlier messages'**
  String get chatLoadOlder;

  /// No description provided for @chatAiBadge.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get chatAiBadge;

  /// No description provided for @productInStock.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit} in stock'**
  String productInStock(int quantity, String unit);

  /// No description provided for @productNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productNameLabel;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPriceLabel;

  /// No description provided for @productStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Available stock'**
  String get productStockLabel;

  /// No description provided for @productUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get productUnitLabel;

  /// No description provided for @productDeclaredOn.
  ///
  /// In en, this message translates to:
  /// **'Declared on'**
  String get productDeclaredOn;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @productNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This product is no longer available. It may have been deleted.'**
  String get productNotFoundBody;

  /// No description provided for @productFormInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Product information'**
  String get productFormInfoSection;

  /// No description provided for @productFormPricingSection.
  ///
  /// In en, this message translates to:
  /// **'Price and availability'**
  String get productFormPricingSection;

  /// No description provided for @productFormPhotosSection.
  ///
  /// In en, this message translates to:
  /// **'Product photos'**
  String get productFormPhotosSection;

  /// No description provided for @productFormPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Add up to 5 photos. The first one becomes the main photo.'**
  String get productFormPhotosHint;

  /// No description provided for @productFormPhotosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get productFormPhotosEmpty;

  /// No description provided for @productFormReplacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace the photos'**
  String get productFormReplacePhoto;

  /// No description provided for @productFormRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove the photo'**
  String get productFormRemovePhoto;

  /// No description provided for @productFormPickingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Reading the photos…'**
  String get productFormPickingPhotos;

  /// No description provided for @productFormPhotoError.
  ///
  /// In en, this message translates to:
  /// **'These photos could not be read. Try again.'**
  String get productFormPhotoError;

  /// No description provided for @productFormPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Submit the declaration'**
  String get productFormPublishAction;

  /// No description provided for @productFormUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Submit the changes'**
  String get productFormUpdateAction;

  /// No description provided for @productFormStatusSection.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get productFormStatusSection;

  /// No description provided for @productFormCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Fill in the product, its price and its stock. Your declaration will be reviewed before any publication.'**
  String get productFormCreateHint;

  /// No description provided for @productFormEditHint.
  ///
  /// In en, this message translates to:
  /// **'Adjust the details, then submit your declaration again.'**
  String get productFormEditHint;

  /// No description provided for @productFormStatusHint.
  ///
  /// In en, this message translates to:
  /// **'The status follows the stock you enter.'**
  String get productFormStatusHint;

  /// No description provided for @productFormOutOfStockHint.
  ///
  /// In en, this message translates to:
  /// **'A stock of 0 puts the product out of stock.'**
  String get productFormOutOfStockHint;

  /// No description provided for @productFormSaveErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'The product was not saved'**
  String get productFormSaveErrorTitle;

  /// No description provided for @productFormValidationSummary.
  ///
  /// In en, this message translates to:
  /// **'Fix the highlighted fields before saving.'**
  String get productFormValidationSummary;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes will be lost if you leave this page.'**
  String get discardChangesBody;

  /// No description provided for @leaveFormAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveFormAction;

  /// No description provided for @keepEditingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditingAction;

  /// No description provided for @validationProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name.'**
  String get validationProductNameRequired;

  /// No description provided for @validationProductNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The product name is too long (maximum 80 characters).'**
  String get validationProductNameTooLong;

  /// No description provided for @validationPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price.'**
  String get validationPriceInvalid;

  /// No description provided for @validationPricePositive.
  ///
  /// In en, this message translates to:
  /// **'The price must be greater than zero.'**
  String get validationPricePositive;

  /// No description provided for @validationStockInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity.'**
  String get validationStockInvalid;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your customers\' orders will appear here.'**
  String get ordersEmptyBody;

  /// No description provided for @ordersNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get ordersNotFoundTitle;

  /// No description provided for @ordersNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This order no longer exists or could not be loaded.'**
  String get ordersNotFoundBody;

  /// No description provided for @ordersBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to orders'**
  String get ordersBackToList;

  /// No description provided for @ordersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Reference, buyer or product'**
  String get ordersSearchHint;

  /// No description provided for @ordersStatPending.
  ///
  /// In en, this message translates to:
  /// **'To confirm'**
  String get ordersStatPending;

  /// No description provided for @ordersStatConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get ordersStatConfirmed;

  /// No description provided for @ordersStatCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersStatCancelled;

  /// No description provided for @ordersResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders} =1{1 order} other{{count} orders}}'**
  String ordersResultsCount(int count);

  /// No description provided for @ordersNoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching order'**
  String get ordersNoResultTitle;

  /// No description provided for @ordersNoResultBody.
  ///
  /// In en, this message translates to:
  /// **'Change your search or switch the filter to see your orders.'**
  String get ordersNoResultBody;

  /// No description provided for @ordersClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get ordersClearFilters;

  /// No description provided for @ordersConfirmedRevenue.
  ///
  /// In en, this message translates to:
  /// **'Confirmed revenue: {amount}'**
  String ordersConfirmedRevenue(String amount);

  /// No description provided for @ordersMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String ordersMoreItems(int count);

  /// No description provided for @ordersSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get ordersSummaryTitle;

  /// No description provided for @ordersReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get ordersReferenceLabel;

  /// No description provided for @ordersArticlesLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ordersArticlesLabel;

  /// No description provided for @ordersArticlesCount.
  ///
  /// In en, this message translates to:
  /// **'{lines, plural, =1{1 line} other{{lines} lines}} · {total} unit(s)'**
  String ordersArticlesCount(int lines, int total);

  /// No description provided for @ordersBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get ordersBuyerTitle;

  /// No description provided for @ordersPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get ordersPhoneLabel;

  /// No description provided for @ordersConfirmHelp.
  ///
  /// In en, this message translates to:
  /// **'Confirm the order to validate the parcel preparation.'**
  String get ordersConfirmHelp;

  /// No description provided for @ordersItemDetail.
  ///
  /// In en, this message translates to:
  /// **'{quantity} × {price}'**
  String ordersItemDetail(int quantity, String price);

  /// No description provided for @statusOrderPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusOrderPending;

  /// No description provided for @statusOrderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusOrderConfirmed;

  /// No description provided for @statusOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusOrderCancelled;

  /// No description provided for @confirmOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get confirmOrderAction;

  /// No description provided for @confirmingOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirming…'**
  String get confirmingOrder;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed successfully.'**
  String get orderConfirmed;

  /// No description provided for @confirmOrderError.
  ///
  /// In en, this message translates to:
  /// **'The confirmation failed.'**
  String get confirmOrderError;

  /// No description provided for @confirmOrderHint.
  ///
  /// In en, this message translates to:
  /// **'The real status was not updated automatically. Verify it before any new attempt.'**
  String get confirmOrderHint;

  /// No description provided for @verifyStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get verifyStatus;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @activeOrdersStat.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get activeOrdersStat;

  /// No description provided for @statInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get statInTransit;

  /// No description provided for @statDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statDelivered;

  /// No description provided for @featuredCatalog.
  ///
  /// In en, this message translates to:
  /// **'Featured catalog'**
  String get featuredCatalog;

  /// No description provided for @buyerOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get buyerOrdersEmptyTitle;

  /// No description provided for @buyerOrdersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here.'**
  String get buyerOrdersEmptyBody;

  /// No description provided for @buyerOrdersOngoingTitle.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get buyerOrdersOngoingTitle;

  /// No description provided for @buyerOrdersClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get buyerOrdersClosedTitle;

  /// No description provided for @buyerOrdersFilterBody.
  ///
  /// In en, this message translates to:
  /// **'The selected status no longer holds any order. Clear the filter to see them all again.'**
  String get buyerOrdersFilterBody;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No listings available'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Published listings will appear here.'**
  String get catalogEmptyBody;

  /// No description provided for @searchCatalog.
  ///
  /// In en, this message translates to:
  /// **'Search listings'**
  String get searchCatalog;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocation;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Number of products matching the catalog filters.
  ///
  /// In en, this message translates to:
  /// **'{count} result(s)'**
  String resultsCount(int count);

  /// Number of products in the catalog before filtering, read by accessibility.
  ///
  /// In en, this message translates to:
  /// **'{count} products in the catalog'**
  String catalogTotalProducts(int count);

  /// Action that increases the quantity of a product.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get quantityIncrease;

  /// Action that decreases the quantity of a product.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get quantityDecrease;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// Number of items in a line or an order.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String itemsCount(int count);

  /// Selling unit displayed next to a product price.
  ///
  /// In en, this message translates to:
  /// **'/ {unit}'**
  String productPricePerUnit(String unit);

  /// No description provided for @validationAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address.'**
  String get validationAddressRequired;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number.'**
  String get validationPhoneInvalid;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailTitle;

  /// No description provided for @orderItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ordered items'**
  String get orderItemsLabel;

  /// No description provided for @buyerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer email'**
  String get buyerEmailLabel;

  /// No description provided for @orderDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get orderDateLabel;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get orderNotFound;

  /// Displayed reference of an order.
  ///
  /// In en, this message translates to:
  /// **'Order {id}'**
  String orderNumber(String id);

  /// Number of items in an order.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String orderNumberItems(int count);

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on'**
  String get placedOn;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order has been cancelled.'**
  String get orderCancelled;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery tracking'**
  String get trackingTitle;

  /// Delivery progress shown in the order tracking.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String trackingStepOf(int current, int total);

  /// No description provided for @trackingStepDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get trackingStepDone;

  /// No description provided for @statusOrderInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get statusOrderInTransit;

  /// No description provided for @statusOrderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusOrderDelivered;

  /// No description provided for @driverTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverTitle;

  /// No description provided for @driverAssignedLater.
  ///
  /// In en, this message translates to:
  /// **'A driver will be assigned after the order is confirmed.'**
  String get driverAssignedLater;

  /// No description provided for @contactDriver.
  ///
  /// In en, this message translates to:
  /// **'Contact driver'**
  String get contactDriver;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get copyNumber;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Number copied.'**
  String get phoneCopied;

  /// No description provided for @deliveryInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery information'**
  String get deliveryInfoLabel;

  /// No description provided for @deliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddressLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @orderDeliveryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery status'**
  String get orderDeliveryStatusLabel;

  /// No description provided for @sellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerLabel;

  /// No description provided for @driverStatusPickUp.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get driverStatusPickUp;

  /// No description provided for @driverStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get driverStatusInTransit;

  /// No description provided for @driverStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get driverStatusDelivered;

  /// No description provided for @driverStatToCollect.
  ///
  /// In en, this message translates to:
  /// **'To deliver'**
  String get driverStatToCollect;

  /// No description provided for @driverRecentDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Recent deliveries'**
  String get driverRecentDeliveries;

  /// No description provided for @driverUpcomingTrips.
  ///
  /// In en, this message translates to:
  /// **'Upcoming trips'**
  String get driverUpcomingTrips;

  /// No description provided for @tripStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tripStatusUpcoming;

  /// No description provided for @tripStatusActive.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get tripStatusActive;

  /// No description provided for @tripStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tripStatusCompleted;

  /// No description provided for @driverStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get driverStartDelivery;

  /// No description provided for @driverStartingDelivery.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get driverStartingDelivery;

  /// No description provided for @driverMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get driverMarkDelivered;

  /// No description provided for @driverMarkingDelivered.
  ///
  /// In en, this message translates to:
  /// **'Marking…'**
  String get driverMarkingDelivered;

  /// No description provided for @driverDeliveryStarted.
  ///
  /// In en, this message translates to:
  /// **'Delivery started.'**
  String get driverDeliveryStarted;

  /// No description provided for @driverDeliveryDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivery completed successfully.'**
  String get driverDeliveryDelivered;

  /// No description provided for @driverActionError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed.'**
  String get driverActionError;

  /// No description provided for @driverActionHint.
  ///
  /// In en, this message translates to:
  /// **'The real status was not updated automatically. Verify it before any new action.'**
  String get driverActionHint;

  /// No description provided for @driverDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get driverDetailTitle;

  /// No description provided for @driverRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get driverRouteTitle;

  /// No description provided for @driverPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get driverPickupLabel;

  /// No description provided for @driverScheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled on'**
  String get driverScheduledLabel;

  /// No description provided for @driverContactCustomer.
  ///
  /// In en, this message translates to:
  /// **'Contact customer'**
  String get driverContactCustomer;

  /// No description provided for @driverCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get driverCustomerLabel;

  /// No description provided for @driverDeliveriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deliveries'**
  String get driverDeliveriesEmptyTitle;

  /// No description provided for @driverDeliveriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your deliveries will appear here.'**
  String get driverDeliveriesEmptyBody;

  /// No description provided for @driverTripsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips'**
  String get driverTripsEmptyTitle;

  /// No description provided for @driverTripsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your trips will appear here.'**
  String get driverTripsEmptyBody;

  /// No description provided for @driverNoUpcomingTripTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming trip'**
  String get driverNoUpcomingTripTitle;

  /// No description provided for @driverNoUpcomingTripBody.
  ///
  /// In en, this message translates to:
  /// **'Completed routes stay in your history.'**
  String get driverNoUpcomingTripBody;

  /// No description provided for @driverDeliveryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Delivery not found.'**
  String get driverDeliveryNotFound;

  /// No description provided for @driverHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your routes and deliveries, all in one place.'**
  String get driverHeroSubtitle;

  /// No description provided for @driverQuickDeliveries.
  ///
  /// In en, this message translates to:
  /// **'My deliveries'**
  String get driverQuickDeliveries;

  /// No description provided for @driverQuickActiveDelivery.
  ///
  /// In en, this message translates to:
  /// **'Active delivery'**
  String get driverQuickActiveDelivery;

  /// No description provided for @driverQuickHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get driverQuickHistory;

  /// Number of deliveries actually in progress for the driver.
  ///
  /// In en, this message translates to:
  /// **'{count} ongoing delivery(ies)'**
  String driverActiveDeliveriesCount(int count);

  /// No description provided for @driverNoActiveDelivery.
  ///
  /// In en, this message translates to:
  /// **'No ongoing delivery'**
  String get driverNoActiveDelivery;

  /// No description provided for @driverLoadingDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Loading your deliveries…'**
  String get driverLoadingDeliveries;

  /// Progress of a trip: delivered stops over total stops.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} stops delivered'**
  String tripStopsProgress(int completed, int total);

  /// No description provided for @adminStatusPickUp.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get adminStatusPickUp;

  /// No description provided for @adminStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get adminStatusInTransit;

  /// No description provided for @adminStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get adminStatusDelivered;

  /// No description provided for @adminStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get adminStatusCancelled;

  /// No description provided for @adminDeliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get adminDeliveriesTitle;

  /// No description provided for @adminDeliveriesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search a delivery…'**
  String get adminDeliveriesSearch;

  /// No description provided for @adminDeliveriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deliveries'**
  String get adminDeliveriesEmptyTitle;

  /// No description provided for @adminDeliveriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deliveries under supervision will appear here.'**
  String get adminDeliveriesEmptyBody;

  /// No description provided for @adminDeliveryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Delivery not found.'**
  String get adminDeliveryNotFound;

  /// No description provided for @adminDeliveryPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get adminDeliveryPickup;

  /// No description provided for @adminDeliveryDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get adminDeliveryDestination;

  /// No description provided for @adminDeliveryDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get adminDeliveryDistance;

  /// No description provided for @adminDeliveryTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get adminDeliveryTracking;

  /// No description provided for @adminDeliveryBaseFee.
  ///
  /// In en, this message translates to:
  /// **'Base fee'**
  String get adminDeliveryBaseFee;

  /// No description provided for @adminDeliveryTotalFee.
  ///
  /// In en, this message translates to:
  /// **'Total fee'**
  String get adminDeliveryTotalFee;

  /// No description provided for @adminDeliveryMarkInTransit.
  ///
  /// In en, this message translates to:
  /// **'Mark as in transit'**
  String get adminDeliveryMarkInTransit;

  /// No description provided for @adminDeliveryMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get adminDeliveryMarkDelivered;

  /// No description provided for @adminDeliveryAssignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign driver'**
  String get adminDeliveryAssignDriver;

  /// No description provided for @adminDeliveryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Delivery updated successfully.'**
  String get adminDeliveryUpdated;

  /// No description provided for @adminDeliveryAssigned.
  ///
  /// In en, this message translates to:
  /// **'Driver assigned successfully.'**
  String get adminDeliveryAssigned;

  /// No description provided for @adminDeliveryNoDriver.
  ///
  /// In en, this message translates to:
  /// **'No driver'**
  String get adminDeliveryNoDriver;

  /// No description provided for @adminDeliveryAssignHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to assign a driver'**
  String get adminDeliveryAssignHint;

  /// No description provided for @adminDeliveryDriverCaption.
  ///
  /// In en, this message translates to:
  /// **'Driver {id}'**
  String adminDeliveryDriverCaption(Object id);

  /// No description provided for @adminDeliveryDriverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Driver name…'**
  String get adminDeliveryDriverNameHint;

  /// No description provided for @adminDeliveryAssignAction.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get adminDeliveryAssignAction;

  /// No description provided for @adminActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation failed. Please try again.'**
  String get adminActionFailed;

  /// No description provided for @adminFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// No description provided for @adminModerationPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminModerationPending;

  /// No description provided for @adminModerationValidated.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get adminModerationValidated;

  /// No description provided for @adminModerationSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get adminModerationSuspended;

  /// No description provided for @adminModerationRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminModerationRejected;

  /// No description provided for @adminModerationArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get adminModerationArchived;

  /// No description provided for @adminUsersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search an account…'**
  String get adminUsersSearchHint;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No account matches'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated.'**
  String get adminUsersUpdated;

  /// No description provided for @adminUserApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminUserApprove;

  /// No description provided for @adminUserRestrict.
  ///
  /// In en, this message translates to:
  /// **'Restrict'**
  String get adminUserRestrict;

  /// No description provided for @adminUserReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get adminUserReactivate;

  /// No description provided for @adminUserActivityCaption.
  ///
  /// In en, this message translates to:
  /// **'{orders, plural, =0{No orders} =1{1 order} other{{orders} orders}} · {products, plural, =0{No products} =1{1 product} other{{products} products}}'**
  String adminUserActivityCaption(int orders, int products);

  /// No description provided for @adminProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product management'**
  String get adminProductsTitle;

  /// No description provided for @adminProductsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a product…'**
  String get adminProductsSearchHint;

  /// No description provided for @adminProductsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No product matches'**
  String get adminProductsEmpty;

  /// No description provided for @adminProductsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated.'**
  String get adminProductsUpdated;

  /// No description provided for @adminProductsRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject product'**
  String get adminProductsRejectTitle;

  /// No description provided for @adminProductsRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection…'**
  String get adminProductsRejectReasonHint;

  /// No description provided for @adminProductsRejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminProductsRejectAction;

  /// No description provided for @adminProductApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminProductApprove;

  /// No description provided for @adminProductArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get adminProductArchive;

  /// No description provided for @categoryCereals.
  ///
  /// In en, this message translates to:
  /// **'Cereals'**
  String get categoryCereals;

  /// No description provided for @categoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetables;

  /// No description provided for @categoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get categoryFruits;

  /// No description provided for @categoryTubers.
  ///
  /// In en, this message translates to:
  /// **'Tubers'**
  String get categoryTubers;

  /// No description provided for @categorySpices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get categorySpices;

  /// No description provided for @catalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh produce, straight from our partner suppliers.'**
  String get catalogSubtitle;

  /// No description provided for @catalogSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get catalogSearchClear;

  /// No description provided for @catalogFiltersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get catalogFiltersReset;

  /// No description provided for @catalogNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching product'**
  String get catalogNoResultsTitle;

  /// No description provided for @catalogNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or reset the filters to browse the whole catalog.'**
  String get catalogNoResultsBody;

  /// No description provided for @catalogProductStock.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit} available'**
  String catalogProductStock(Object count, Object unit);

  /// No description provided for @buyerCatalogTab.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get buyerCatalogTab;

  /// No description provided for @buyerOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get buyerOrdersTab;

  /// No description provided for @catalogSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get catalogSortLabel;

  /// No description provided for @catalogSortPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get catalogSortPrice;

  /// No description provided for @catalogSortExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get catalogSortExpiry;

  /// No description provided for @catalogSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get catalogSortRecent;

  /// No description provided for @catalogQualityGrade.
  ///
  /// In en, this message translates to:
  /// **'Quality {grade}'**
  String catalogQualityGrade(String grade);

  /// No description provided for @catalogExpiry.
  ///
  /// In en, this message translates to:
  /// **'Best before {date}'**
  String catalogExpiry(String date);

  /// No description provided for @catalogListingDetail.
  ///
  /// In en, this message translates to:
  /// **'Listing details'**
  String get catalogListingDetail;

  /// No description provided for @catalogListingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This listing is no longer available.'**
  String get catalogListingUnavailable;

  /// No description provided for @catalogRequestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request a quote'**
  String get catalogRequestQuote;

  /// No description provided for @quoteQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Requested quantity'**
  String get quoteQuantityHint;

  /// No description provided for @quoteMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Additional message (optional)'**
  String get quoteMessageHint;

  /// No description provided for @quoteRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like {quantity} {unit} of “{title}” ({reference}).'**
  String quoteRequestMessage(
    String quantity,
    String unit,
    String title,
    String reference,
  );

  /// No description provided for @quoteRequestInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than zero.'**
  String get quoteRequestInvalidQuantity;

  /// No description provided for @buyerOrdersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Quotes from the team will appear here.'**
  String get buyerOrdersEmptyMessage;

  /// No description provided for @buyerOrderActionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get buyerOrderActionRequired;

  /// No description provided for @buyerOrderQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get buyerOrderQuoted;

  /// No description provided for @buyerQuoteExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String buyerQuoteExpiresIn(String time);

  /// No description provided for @buyerQuoteExpired.
  ///
  /// In en, this message translates to:
  /// **'Quote expired'**
  String get buyerQuoteExpired;

  /// No description provided for @buyerConfirmQuote.
  ///
  /// In en, this message translates to:
  /// **'Confirm quote'**
  String get buyerConfirmQuote;

  /// No description provided for @buyerCancelQuote.
  ///
  /// In en, this message translates to:
  /// **'Cancel quote'**
  String get buyerCancelQuote;

  /// No description provided for @buyerConfirmQuoteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Confirm this quote?'**
  String get buyerConfirmQuoteQuestion;

  /// No description provided for @buyerCancelQuoteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel this quote?'**
  String get buyerCancelQuoteQuestion;

  /// No description provided for @buyerCancellationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get buyerCancellationReasonHint;

  /// No description provided for @buyerStatusQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quote sent'**
  String get buyerStatusQuoted;

  /// No description provided for @buyerStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get buyerStatusConfirmed;

  /// No description provided for @buyerStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get buyerStatusPreparing;

  /// No description provided for @buyerStatusReadyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get buyerStatusReadyForPickup;

  /// No description provided for @buyerStatusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get buyerStatusOutForDelivery;

  /// No description provided for @buyerStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get buyerStatusCompleted;

  /// No description provided for @buyerStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get buyerStatusCancelled;

  /// No description provided for @buyerDeliveryModePickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup at collection point'**
  String get buyerDeliveryModePickup;

  /// No description provided for @buyerDeliveryModeAgency.
  ///
  /// In en, this message translates to:
  /// **'Agency delivery'**
  String get buyerDeliveryModeAgency;

  /// No description provided for @buyerPickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Collection point address'**
  String get buyerPickupAddress;

  /// No description provided for @buyerDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get buyerDeliveryAddress;

  /// No description provided for @buyerQuoteTotals.
  ///
  /// In en, this message translates to:
  /// **'Amounts provided by the team'**
  String get buyerQuoteTotals;

  /// No description provided for @buyerOrderCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason: {reason}'**
  String buyerOrderCancellationReason(String reason);

  /// No description provided for @buyerOrderItems.
  ///
  /// In en, this message translates to:
  /// **'Quoted listings'**
  String get buyerOrderItems;

  /// No description provided for @buyerOrderSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get buyerOrderSubtotalLabel;

  /// No description provided for @buyerOrderBuyerFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer fee'**
  String get buyerOrderBuyerFeeLabel;

  /// No description provided for @buyerOrderDeliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get buyerOrderDeliveryFeeLabel;

  /// No description provided for @buyerCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buyerCancelOrder;

  /// No description provided for @buyerCancelOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get buyerCancelOrderQuestion;

  /// No description provided for @adminConsoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Administration console'**
  String get adminConsoleLabel;

  /// No description provided for @adminConsoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform supervision'**
  String get adminConsoleSubtitle;

  /// No description provided for @adminRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the dashboard'**
  String get adminRefreshTooltip;

  /// No description provided for @adminTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get adminTodayLabel;

  /// No description provided for @adminOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Key figures'**
  String get adminOverviewTitle;

  /// No description provided for @adminStatRevenue.
  ///
  /// In en, this message translates to:
  /// **'Order revenue'**
  String get adminStatRevenue;

  /// No description provided for @adminStatRevenueCaption.
  ///
  /// In en, this message translates to:
  /// **'All orders recorded by the platform'**
  String get adminStatRevenueCaption;

  /// No description provided for @adminStatUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminStatUsers;

  /// No description provided for @adminStatProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminStatProducts;

  /// No description provided for @adminStatOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminStatOrders;

  /// No description provided for @adminStatDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get adminStatDeliveries;

  /// No description provided for @adminStatUsersCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No account to validate} =1{1 account to validate} other{{count} accounts to validate}}'**
  String adminStatUsersCaption(int count);

  /// No description provided for @adminStatProductsCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No product to moderate} =1{1 product to moderate} other{{count} products to moderate}}'**
  String adminStatProductsCaption(int count);

  /// No description provided for @adminStatOrdersCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to confirm} =1{1 order to confirm} other{{count} orders to confirm}}'**
  String adminStatOrdersCaption(int count);

  /// No description provided for @adminStatDeliveriesCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No delivery running} =1{1 delivery running} other{{count} deliveries running}}'**
  String adminStatDeliveriesCaption(int count);

  /// No description provided for @adminAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get adminAttentionTitle;

  /// No description provided for @adminAttentionUsers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Account awaiting validation} other{{count} accounts awaiting validation}}'**
  String adminAttentionUsers(int count);

  /// No description provided for @adminAttentionProducts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Product to moderate} other{{count} products to moderate}}'**
  String adminAttentionProducts(int count);

  /// No description provided for @adminAttentionOrders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Order awaiting confirmation} other{{count} orders awaiting confirmation}}'**
  String adminAttentionOrders(int count);

  /// No description provided for @adminAttentionDeliveries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delivery in progress} other{{count} deliveries in progress}}'**
  String adminAttentionDeliveries(int count);

  /// No description provided for @adminAttentionClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs your attention'**
  String get adminAttentionClearTitle;

  /// No description provided for @adminAttentionClearBody.
  ///
  /// In en, this message translates to:
  /// **'No account, product or order is waiting for a decision.'**
  String get adminAttentionClearBody;

  /// No description provided for @distributionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to distribute yet'**
  String get distributionEmpty;

  /// No description provided for @adminQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get adminQuickActionsTitle;

  /// No description provided for @adminQuickActionProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminQuickActionProducts;

  /// No description provided for @adminQuickActionUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminQuickActionUsers;

  /// No description provided for @adminQuickActionDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get adminQuickActionDeliveries;

  /// No description provided for @adminQuickActionAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get adminQuickActionAnalytics;

  /// No description provided for @adminDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get adminDistributionTitle;

  /// No description provided for @adminDistributionOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders by status'**
  String get adminDistributionOrders;

  /// No description provided for @adminDistributionDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries by status'**
  String get adminDistributionDeliveries;

  /// No description provided for @adminDistributionUsers.
  ///
  /// In en, this message translates to:
  /// **'Users by role'**
  String get adminDistributionUsers;

  /// No description provided for @adminDistributionProducts.
  ///
  /// In en, this message translates to:
  /// **'Products by status'**
  String get adminDistributionProducts;

  /// No description provided for @adminAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform analytics'**
  String get adminAnalyticsTitle;

  /// No description provided for @adminAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Indicators computed from the administration console data.'**
  String get adminAnalyticsSubtitle;

  /// No description provided for @adminAnalyticsVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform volume'**
  String get adminAnalyticsVolumeTitle;

  /// No description provided for @adminAnalyticsIndicatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking indicators'**
  String get adminAnalyticsIndicatorsTitle;

  /// No description provided for @adminAnalyticsPublished.
  ///
  /// In en, this message translates to:
  /// **'Published products'**
  String get adminAnalyticsPublished;

  /// No description provided for @adminAnalyticsActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get adminAnalyticsActiveOrders;

  /// No description provided for @adminAnalyticsCompletedDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Completed deliveries'**
  String get adminAnalyticsCompletedDeliveries;

  /// No description provided for @adminAnalyticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data to analyze yet'**
  String get adminAnalyticsEmpty;

  /// No description provided for @adminAnalyticsNoHistory.
  ///
  /// In en, this message translates to:
  /// **'History and time series are not available: the administration console does not record history yet.'**
  String get adminAnalyticsNoHistory;

  /// No description provided for @adminModerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Products to moderate'**
  String get adminModerationTitle;

  /// No description provided for @adminModerationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No product is waiting for a decision'**
  String get adminModerationEmpty;

  /// No description provided for @adminRecentOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest orders'**
  String get adminRecentOrdersTitle;

  /// No description provided for @adminRecentOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No order recorded yet'**
  String get adminRecentOrdersEmpty;

  /// No description provided for @adminOrderBuyerCaption.
  ///
  /// In en, this message translates to:
  /// **'{buyer} · {amount}'**
  String adminOrderBuyerCaption(String buyer, String amount);

  /// No description provided for @adminSectionLoadError.
  ///
  /// In en, this message translates to:
  /// **'This section could not be loaded'**
  String get adminSectionLoadError;

  /// No description provided for @adminSectionLoadErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String adminSectionLoadErrorDetail(String message);

  /// No description provided for @adminOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search an order…'**
  String get adminOrdersSearchHint;

  /// No description provided for @adminOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get adminOrdersEmptyTitle;

  /// No description provided for @adminOrdersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Recorded orders will appear here.'**
  String get adminOrdersEmptyBody;

  /// No description provided for @adminOrderArticlesCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String adminOrderArticlesCaption(int count);

  /// No description provided for @adminOrderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order detail'**
  String get adminOrderDetailTitle;

  /// No description provided for @adminOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get adminOrderNotFound;

  /// No description provided for @adminOrderPlacedAt.
  ///
  /// In en, this message translates to:
  /// **'Placed on'**
  String get adminOrderPlacedAt;

  /// No description provided for @adminOrderBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get adminOrderBuyerLabel;

  /// No description provided for @adminOrderSellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get adminOrderSellerLabel;

  /// No description provided for @adminOrderAccountCaption.
  ///
  /// In en, this message translates to:
  /// **'Account {id}'**
  String adminOrderAccountCaption(String id);

  /// No description provided for @adminOrderAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get adminOrderAmountLabel;

  /// No description provided for @adminOrderItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get adminOrderItemsTitle;

  /// No description provided for @adminOrderItemsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No line items available for this order.'**
  String get adminOrderItemsEmpty;

  /// No description provided for @adminOrderLinkedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Linked delivery'**
  String get adminOrderLinkedDelivery;

  /// No description provided for @adminOrderStatusLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Status change unavailable'**
  String get adminOrderStatusLockedTitle;

  /// No description provided for @adminOrderStatusLockedBody.
  ///
  /// In en, this message translates to:
  /// **'The order status transition workflow is not defined yet. Order consultation remains available.'**
  String get adminOrderStatusLockedBody;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @superAdminConsoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide oversight of AgriConnect.'**
  String get superAdminConsoleSubtitle;

  /// No description provided for @superAdminRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the console'**
  String get superAdminRefreshTooltip;

  /// No description provided for @superAdminConsoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform console'**
  String get superAdminConsoleLabel;

  /// No description provided for @superAdminTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get superAdminTodayLabel;

  /// No description provided for @superAdminOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get superAdminOverviewTitle;

  /// No description provided for @superAdminStatUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get superAdminStatUsers;

  /// No description provided for @superAdminStatUsersCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} awaiting verification'**
  String superAdminStatUsersCaption(int count);

  /// No description provided for @superAdminStatStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get superAdminStatStaff;

  /// No description provided for @superAdminStatStaffCaption.
  ///
  /// In en, this message translates to:
  /// **'accounts active on the platform'**
  String get superAdminStatStaffCaption;

  /// No description provided for @superAdminStatProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get superAdminStatProducts;

  /// No description provided for @superAdminStatProductsCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} products published'**
  String superAdminStatProductsCaption(int count);

  /// No description provided for @superAdminStatDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get superAdminStatDeliveries;

  /// No description provided for @superAdminStatDeliveriesCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} currently in progress'**
  String superAdminStatDeliveriesCaption(int count);

  /// No description provided for @superAdminStatGmv.
  ///
  /// In en, this message translates to:
  /// **'Gross merchandise value'**
  String get superAdminStatGmv;

  /// No description provided for @superAdminStatGmvCaption.
  ///
  /// In en, this message translates to:
  /// **'Total value of every recorded order'**
  String get superAdminStatGmvCaption;

  /// No description provided for @superAdminAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs supervision'**
  String get superAdminAttentionTitle;

  /// No description provided for @superAdminAttentionModeration.
  ///
  /// In en, this message translates to:
  /// **'Products to moderate'**
  String get superAdminAttentionModeration;

  /// No description provided for @superAdminAttentionUsers.
  ///
  /// In en, this message translates to:
  /// **'Accounts to verify'**
  String get superAdminAttentionUsers;

  /// No description provided for @superAdminAttentionDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries in progress'**
  String get superAdminAttentionDeliveries;

  /// No description provided for @superAdminAttentionClearTitle.
  ///
  /// In en, this message translates to:
  /// **'The platform asks for nothing'**
  String get superAdminAttentionClearTitle;

  /// No description provided for @superAdminAttentionClearBody.
  ///
  /// In en, this message translates to:
  /// **'No product, account or delivery is waiting for a decision.'**
  String get superAdminAttentionClearBody;

  /// No description provided for @superAdminQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get superAdminQuickActionsTitle;

  /// No description provided for @superAdminQuickActionStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get superAdminQuickActionStaff;

  /// No description provided for @superAdminQuickActionPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get superAdminQuickActionPlatform;

  /// No description provided for @superAdminQuickActionAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get superAdminQuickActionAnalytics;

  /// No description provided for @superAdminDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get superAdminDistributionTitle;

  /// No description provided for @superAdminDistributionStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff by access level'**
  String get superAdminDistributionStaff;

  /// No description provided for @superAdminActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get superAdminActivityTitle;

  /// No description provided for @superAdminActivityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet'**
  String get superAdminActivityEmpty;

  /// No description provided for @superAdminActivityActor.
  ///
  /// In en, this message translates to:
  /// **'{actor} — {action}'**
  String superAdminActivityActor(String actor, String action);

  /// No description provided for @superAdminSectionLoadError.
  ///
  /// In en, this message translates to:
  /// **'This section could not be loaded'**
  String get superAdminSectionLoadError;

  /// No description provided for @superAdminSectionLoadErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String superAdminSectionLoadErrorDetail(String message);

  /// No description provided for @superAdminStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff management'**
  String get superAdminStaffTitle;

  /// No description provided for @superAdminStaffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts and the rights granted to them'**
  String get superAdminStaffSubtitle;

  /// No description provided for @superAdminStaffSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a staff member'**
  String get superAdminStaffSearchHint;

  /// No description provided for @superAdminStaffSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search the staff directory'**
  String get superAdminStaffSearchLabel;

  /// No description provided for @superAdminStaffEmpty.
  ///
  /// In en, this message translates to:
  /// **'No staff member matches this search'**
  String get superAdminStaffEmpty;

  /// No description provided for @superAdminStaffFilterRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get superAdminStaffFilterRole;

  /// No description provided for @superAdminStaffFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get superAdminStaffFilterStatus;

  /// No description provided for @superAdminStaffStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get superAdminStaffStatusActive;

  /// No description provided for @superAdminStaffStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get superAdminStaffStatusSuspended;

  /// No description provided for @superAdminStaffReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get superAdminStaffReset;

  /// No description provided for @superAdminStaffCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No staff member} =1{1 staff member} other{{count} staff members}}'**
  String superAdminStaffCount(int count);

  /// No description provided for @superAdminStaffLastActive.
  ///
  /// In en, this message translates to:
  /// **'Active {date}'**
  String superAdminStaffLastActive(String date);

  /// No description provided for @superAdminStaffPermissionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rights} =1{1 right} other{{count} rights}}'**
  String superAdminStaffPermissionCount(int count);

  /// No description provided for @superAdminStaffProtectedNotice.
  ///
  /// In en, this message translates to:
  /// **'This account cannot be modified from the console.'**
  String get superAdminStaffProtectedNotice;

  /// No description provided for @superAdminStaffAccessReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get superAdminStaffAccessReadOnly;

  /// No description provided for @superAdminStaffAccessFull.
  ///
  /// In en, this message translates to:
  /// **'Full access'**
  String get superAdminStaffAccessFull;

  /// No description provided for @superAdminStaffAccessSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get superAdminStaffAccessSuspended;

  /// No description provided for @superAdminStaffSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend the account'**
  String get superAdminStaffSuspend;

  /// No description provided for @superAdminStaffRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore as read only'**
  String get superAdminStaffRestore;

  /// No description provided for @superAdminStaffPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rights of {name}'**
  String superAdminStaffPermissionsTitle(String name);

  /// No description provided for @superAdminStaffPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Settings rights stay reserved to the Root.'**
  String get superAdminStaffPermissionsSubtitle;

  /// No description provided for @superAdminStaffPermissionsSave.
  ///
  /// In en, this message translates to:
  /// **'Save rights'**
  String get superAdminStaffPermissionsSave;

  /// No description provided for @superAdminStaffPermissionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Rights updated'**
  String get superAdminStaffPermissionsSaved;

  /// No description provided for @superAdminStaffSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get superAdminStaffSuspended;

  /// No description provided for @superAdminStaffRestored.
  ///
  /// In en, this message translates to:
  /// **'Account restored as read only'**
  String get superAdminStaffRestored;

  /// No description provided for @superAdminPermissionMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get superAdminPermissionMarketplace;

  /// No description provided for @superAdminPermissionPeople.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get superAdminPermissionPeople;

  /// No description provided for @superAdminPermissionPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get superAdminPermissionPlatform;

  /// No description provided for @superAdminPermissionModerateProducts.
  ///
  /// In en, this message translates to:
  /// **'Moderate products'**
  String get superAdminPermissionModerateProducts;

  /// No description provided for @superAdminPermissionModerateProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Approve, reject and archive products.'**
  String get superAdminPermissionModerateProductsBody;

  /// No description provided for @superAdminPermissionManageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get superAdminPermissionManageUsers;

  /// No description provided for @superAdminPermissionManageUsersBody.
  ///
  /// In en, this message translates to:
  /// **'Verify accounts and apply sanctions.'**
  String get superAdminPermissionManageUsersBody;

  /// No description provided for @superAdminPermissionSuperviseDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Supervise deliveries'**
  String get superAdminPermissionSuperviseDeliveries;

  /// No description provided for @superAdminPermissionSuperviseDeliveriesBody.
  ///
  /// In en, this message translates to:
  /// **'Follow routes and assign drivers.'**
  String get superAdminPermissionSuperviseDeliveriesBody;

  /// No description provided for @superAdminPermissionManageOrders.
  ///
  /// In en, this message translates to:
  /// **'Process orders'**
  String get superAdminPermissionManageOrders;

  /// No description provided for @superAdminPermissionManageOrdersBody.
  ///
  /// In en, this message translates to:
  /// **'Move orders to the right state.'**
  String get superAdminPermissionManageOrdersBody;

  /// No description provided for @superAdminPermissionViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get superAdminPermissionViewAnalytics;

  /// No description provided for @superAdminPermissionViewAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'Read the platform indicators.'**
  String get superAdminPermissionViewAnalyticsBody;

  /// No description provided for @superAdminPermissionManageSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage settings'**
  String get superAdminPermissionManageSettings;

  /// No description provided for @superAdminPermissionManageSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Change the platform configuration.'**
  String get superAdminPermissionManageSettingsBody;

  /// No description provided for @superAdminPermissionLocked.
  ///
  /// In en, this message translates to:
  /// **'Reserved to the Root'**
  String get superAdminPermissionLocked;

  /// No description provided for @superAdminActionSuspended.
  ///
  /// In en, this message translates to:
  /// **'suspended'**
  String get superAdminActionSuspended;

  /// No description provided for @superAdminActionRestored.
  ///
  /// In en, this message translates to:
  /// **'restored'**
  String get superAdminActionRestored;

  /// No description provided for @superAdminActionUpdatedPermissions.
  ///
  /// In en, this message translates to:
  /// **'changed the rights of'**
  String get superAdminActionUpdatedPermissions;

  /// No description provided for @superAdminActionUpdatedSettings.
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get superAdminActionUpdatedSettings;

  /// No description provided for @superAdminActionModeratedProduct.
  ///
  /// In en, this message translates to:
  /// **'moderated the product'**
  String get superAdminActionModeratedProduct;

  /// No description provided for @superAdminPlatformTitle.
  ///
  /// In en, this message translates to:
  /// **'System settings'**
  String get superAdminPlatformTitle;

  /// No description provided for @superAdminPlatformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration applied to the whole platform'**
  String get superAdminPlatformSubtitle;

  /// No description provided for @superAdminSettingRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Open registrations'**
  String get superAdminSettingRegistrations;

  /// No description provided for @superAdminSettingRegistrationsBody.
  ///
  /// In en, this message translates to:
  /// **'Allows or blocks the creation of new accounts.'**
  String get superAdminSettingRegistrationsBody;

  /// No description provided for @superAdminSettingAutoModeration.
  ///
  /// In en, this message translates to:
  /// **'Automatic moderation'**
  String get superAdminSettingAutoModeration;

  /// No description provided for @superAdminSettingAutoModerationBody.
  ///
  /// In en, this message translates to:
  /// **'Publishes products without a human review.'**
  String get superAdminSettingAutoModerationBody;

  /// No description provided for @superAdminSettingAutoModerationWarning.
  ///
  /// In en, this message translates to:
  /// **'Products will be visible without review.'**
  String get superAdminSettingAutoModerationWarning;

  /// No description provided for @superAdminSettingMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance mode'**
  String get superAdminSettingMaintenance;

  /// No description provided for @superAdminSettingMaintenanceBody.
  ///
  /// In en, this message translates to:
  /// **'Hides the marketplace from users.'**
  String get superAdminSettingMaintenanceBody;

  /// No description provided for @superAdminSettingMaintenanceWarning.
  ///
  /// In en, this message translates to:
  /// **'The marketplace will be unreachable.'**
  String get superAdminSettingMaintenanceWarning;

  /// No description provided for @superAdminSettingSupportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support email'**
  String get superAdminSettingSupportEmail;

  /// No description provided for @superAdminSettingSupportEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Address shown to users when they need help.'**
  String get superAdminSettingSupportEmailBody;

  /// No description provided for @superAdminSettingSupportEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get superAdminSettingSupportEmailInvalid;

  /// No description provided for @superAdminSettingMaxUpload.
  ///
  /// In en, this message translates to:
  /// **'Maximum photo size'**
  String get superAdminSettingMaxUpload;

  /// No description provided for @superAdminSettingMaxUploadBody.
  ///
  /// In en, this message translates to:
  /// **'In megabytes, applied to products.'**
  String get superAdminSettingMaxUploadBody;

  /// No description provided for @superAdminSettingMaxUploadInvalid.
  ///
  /// In en, this message translates to:
  /// **'The value must be between 1 and 20 MB.'**
  String get superAdminSettingMaxUploadInvalid;

  /// No description provided for @superAdminSettingUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String superAdminSettingUpdatedAt(String date);

  /// No description provided for @superAdminSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get superAdminSettingsSaved;

  /// No description provided for @superAdminSettingsUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes. They take effect when you save.'**
  String get superAdminSettingsUnsaved;

  /// No description provided for @superAdminSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get superAdminSettingsSave;

  /// No description provided for @superAdminSettingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'The settings could not be saved.'**
  String get superAdminSettingsSaveError;

  /// No description provided for @superAdminAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform analytics'**
  String get superAdminAnalyticsTitle;

  /// No description provided for @superAdminAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Figures computed across the whole marketplace'**
  String get superAdminAnalyticsSubtitle;

  /// No description provided for @superAdminAnalyticsAudience.
  ///
  /// In en, this message translates to:
  /// **'Accounts by role'**
  String get superAdminAnalyticsAudience;

  /// No description provided for @superAdminAnalyticsOrdersCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} orders in total'**
  String superAdminAnalyticsOrdersCaption(int count);

  /// No description provided for @superAdminAnalyticsOpenOrdersCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} orders still open'**
  String superAdminAnalyticsOpenOrdersCaption(int count);

  /// No description provided for @superAdminAnalyticsPublishedCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} products live'**
  String superAdminAnalyticsPublishedCaption(int count);

  /// No description provided for @superAdminAnalyticsNoTrend.
  ///
  /// In en, this message translates to:
  /// **'History is not available on this demo build yet.'**
  String get superAdminAnalyticsNoTrend;

  /// No description provided for @superAdminAnalyticsStaffCaption.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts'**
  String get superAdminAnalyticsStaffCaption;

  /// No description provided for @superAdminStatOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get superAdminStatOrders;

  /// No description provided for @superAdminAnalyticsOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get superAdminAnalyticsOpenOrders;

  /// No description provided for @superAdminAnalyticsStaffShare.
  ///
  /// In en, this message translates to:
  /// **'Rights granted to staff'**
  String get superAdminAnalyticsStaffShare;

  /// No description provided for @sectionBuyerSupport.
  ///
  /// In en, this message translates to:
  /// **'Buyer support'**
  String get sectionBuyerSupport;

  /// No description provided for @sectionStockValidation.
  ///
  /// In en, this message translates to:
  /// **'Stock validation'**
  String get sectionStockValidation;

  /// No description provided for @sectionOrderProcessing.
  ///
  /// In en, this message translates to:
  /// **'Order processing'**
  String get sectionOrderProcessing;

  /// No description provided for @sectionPaymentFollowup.
  ///
  /// In en, this message translates to:
  /// **'Payment follow-up'**
  String get sectionPaymentFollowup;

  /// No description provided for @agentNavigationGroupOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get agentNavigationGroupOperations;

  /// No description provided for @agentNavigationGroupSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get agentNavigationGroupSupport;

  /// No description provided for @agentNavigationGroupFollowup.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get agentNavigationGroupFollowup;

  /// No description provided for @agentConsoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer support, stock, orders and payments in one workspace.'**
  String get agentConsoleSubtitle;

  /// No description provided for @agentRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh the workspace'**
  String get agentRefreshTooltip;

  /// No description provided for @agentTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get agentTodayLabel;

  /// No description provided for @agentOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get agentOverviewTitle;

  /// No description provided for @agentQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get agentQuickActionsTitle;

  /// No description provided for @agentAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get agentAttentionTitle;

  /// No description provided for @agentAttentionClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get agentAttentionClearTitle;

  /// No description provided for @agentAttentionClearBody.
  ///
  /// In en, this message translates to:
  /// **'No request or case needs a decision right now.'**
  String get agentAttentionClearBody;

  /// No description provided for @agentNoCapabilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'No operational access'**
  String get agentNoCapabilitiesTitle;

  /// No description provided for @agentNoCapabilitiesBody.
  ///
  /// In en, this message translates to:
  /// **'No agent capability has been granted to your account yet.'**
  String get agentNoCapabilitiesBody;

  /// No description provided for @agentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the workspace…'**
  String get agentLoading;

  /// No description provided for @agentRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get agentRefreshing;

  /// No description provided for @agentStaleQueueCount.
  ///
  /// In en, this message translates to:
  /// **'Last known value: {count}'**
  String agentStaleQueueCount(String count);

  /// No description provided for @agentSectionLoadError.
  ///
  /// In en, this message translates to:
  /// **'This section could not be loaded'**
  String get agentSectionLoadError;

  /// No description provided for @agentSectionLoadErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String agentSectionLoadErrorDetail(String message);

  /// No description provided for @agentAccessDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access not allowed'**
  String get agentAccessDeniedTitle;

  /// No description provided for @agentAccessDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account does not hold the capability required for this section.'**
  String get agentAccessDeniedBody;

  /// No description provided for @agentActionError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed.'**
  String get agentActionError;

  /// No description provided for @agentActionHint.
  ///
  /// In en, this message translates to:
  /// **'The real status was not updated automatically. Verify it before any new action.'**
  String get agentActionHint;

  /// No description provided for @agentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a reference or a name'**
  String get agentSearchHint;

  /// No description provided for @agentFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get agentFilterStatus;

  /// No description provided for @agentFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get agentFilterAll;

  /// No description provided for @agentClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get agentClearFilters;

  /// No description provided for @agentResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No case} =1{1 case} other{{count} cases}}'**
  String agentResultsCount(int count);

  /// No description provided for @agentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show'**
  String get agentEmptyTitle;

  /// No description provided for @agentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New cases will appear here.'**
  String get agentEmptyBody;

  /// No description provided for @agentNoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching case'**
  String get agentNoResultTitle;

  /// No description provided for @agentNoResultBody.
  ///
  /// In en, this message translates to:
  /// **'Change the search or the status filter.'**
  String get agentNoResultBody;

  /// No description provided for @agentDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Case details'**
  String get agentDetailTitle;

  /// No description provided for @agentReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get agentReferenceLabel;

  /// No description provided for @agentReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received on'**
  String get agentReceivedLabel;

  /// No description provided for @agentCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get agentCloseAction;

  /// No description provided for @agentBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to the list'**
  String get agentBackToList;

  /// No description provided for @agentStatSupport.
  ///
  /// In en, this message translates to:
  /// **'Support requests'**
  String get agentStatSupport;

  /// No description provided for @agentStatSupportCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing open} =1{1 open request} other{{count} open requests}}'**
  String agentStatSupportCaption(int count);

  /// No description provided for @agentStatStock.
  ///
  /// In en, this message translates to:
  /// **'Stock cases'**
  String get agentStatStock;

  /// No description provided for @agentStatStockCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing pending} =1{1 pending case} other{{count} pending cases}}'**
  String agentStatStockCaption(int count);

  /// No description provided for @agentStatOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders to process'**
  String get agentStatOrders;

  /// No description provided for @agentStatOrdersCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to process} =1{1 order to process} other{{count} orders to process}}'**
  String agentStatOrdersCaption(int count);

  /// No description provided for @agentStatPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments to follow'**
  String get agentStatPayments;

  /// No description provided for @agentStatPaymentsCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to follow} =1{1 payment to follow} other{{count} payments to follow}}'**
  String agentStatPaymentsCaption(int count);

  /// No description provided for @agentAttentionSupport.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Request awaiting an answer} other{{count} requests awaiting an answer}}'**
  String agentAttentionSupport(int count);

  /// No description provided for @agentAttentionStock.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Stock case to validate} other{{count} stock cases to validate}}'**
  String agentAttentionStock(int count);

  /// No description provided for @agentAttentionOrders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Order to process} other{{count} orders to process}}'**
  String agentAttentionOrders(int count);

  /// No description provided for @agentAttentionPayments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Payment to follow up} other{{count} payments to follow up}}'**
  String agentAttentionPayments(int count);

  /// No description provided for @agentQuickSupport.
  ///
  /// In en, this message translates to:
  /// **'Buyer support'**
  String get agentQuickSupport;

  /// No description provided for @agentQuickStock.
  ///
  /// In en, this message translates to:
  /// **'Stock validation'**
  String get agentQuickStock;

  /// No description provided for @agentQuickOrders.
  ///
  /// In en, this message translates to:
  /// **'Order processing'**
  String get agentQuickOrders;

  /// No description provided for @agentQuickPayments.
  ///
  /// In en, this message translates to:
  /// **'Payment follow-up'**
  String get agentQuickPayments;

  /// No description provided for @agentSupportBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get agentSupportBuyerLabel;

  /// No description provided for @agentSupportSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get agentSupportSubjectLabel;

  /// No description provided for @agentSupportPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get agentSupportPriorityLabel;

  /// No description provided for @agentSupportPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get agentSupportPriorityHigh;

  /// No description provided for @agentSupportPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get agentSupportPriorityNormal;

  /// No description provided for @agentSupportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get agentSupportStatusOpen;

  /// No description provided for @agentSupportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get agentSupportStatusInProgress;

  /// No description provided for @agentSupportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get agentSupportStatusResolved;

  /// No description provided for @agentSupportTakeAction.
  ///
  /// In en, this message translates to:
  /// **'Take charge'**
  String get agentSupportTakeAction;

  /// No description provided for @agentSupportResolveAction.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved'**
  String get agentSupportResolveAction;

  /// No description provided for @agentSupportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Request updated.'**
  String get agentSupportUpdated;

  /// No description provided for @agentSupportEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No support request'**
  String get agentSupportEmptyTitle;

  /// No description provided for @agentSupportEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Buyer requests will appear here.'**
  String get agentSupportEmptyBody;

  /// No description provided for @agentStockProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get agentStockProductLabel;

  /// No description provided for @agentStockSupplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get agentStockSupplierLabel;

  /// No description provided for @agentStockLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get agentStockLocationLabel;

  /// No description provided for @agentStockDeclaredQty.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit} declared'**
  String agentStockDeclaredQty(int quantity, String unit);

  /// No description provided for @agentStockStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get agentStockStatusPending;

  /// No description provided for @agentStockStatusValidated.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get agentStockStatusValidated;

  /// No description provided for @agentStockStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get agentStockStatusRejected;

  /// No description provided for @agentStockValidateAction.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get agentStockValidateAction;

  /// No description provided for @agentStockRejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get agentStockRejectAction;

  /// No description provided for @agentStockUpdated.
  ///
  /// In en, this message translates to:
  /// **'Case updated.'**
  String get agentStockUpdated;

  /// No description provided for @agentStockEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stock case'**
  String get agentStockEmptyTitle;

  /// No description provided for @agentStockEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Declared stock to check will appear here.'**
  String get agentStockEmptyBody;

  /// No description provided for @agentOrderBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get agentOrderBuyerLabel;

  /// No description provided for @agentOrderSellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get agentOrderSellerLabel;

  /// No description provided for @agentOrderItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get agentOrderItemsLabel;

  /// No description provided for @agentOrderAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get agentOrderAmountLabel;

  /// No description provided for @agentOrderStatusAwaiting.
  ///
  /// In en, this message translates to:
  /// **'To process'**
  String get agentOrderStatusAwaiting;

  /// No description provided for @agentOrderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get agentOrderStatusProcessing;

  /// No description provided for @agentOrderStatusProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get agentOrderStatusProcessed;

  /// No description provided for @agentOrderStartAction.
  ///
  /// In en, this message translates to:
  /// **'Start processing'**
  String get agentOrderStartAction;

  /// No description provided for @agentOrderCompleteAction.
  ///
  /// In en, this message translates to:
  /// **'Mark as processed'**
  String get agentOrderCompleteAction;

  /// No description provided for @agentOrderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order updated.'**
  String get agentOrderUpdated;

  /// No description provided for @agentOrderEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No order to process'**
  String get agentOrderEmptyTitle;

  /// No description provided for @agentOrderEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Orders to move forward will appear here.'**
  String get agentOrderEmptyBody;

  /// No description provided for @agentPaymentPayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Payer'**
  String get agentPaymentPayerLabel;

  /// No description provided for @agentPaymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get agentPaymentAmountLabel;

  /// No description provided for @agentPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get agentPaymentMethodLabel;

  /// No description provided for @agentPaymentDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due on'**
  String get agentPaymentDueLabel;

  /// No description provided for @agentPaymentStatusDue.
  ///
  /// In en, this message translates to:
  /// **'To follow up'**
  String get agentPaymentStatusDue;

  /// No description provided for @agentPaymentStatusAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get agentPaymentStatusAwaiting;

  /// No description provided for @agentPaymentStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get agentPaymentStatusConfirmed;

  /// No description provided for @agentPaymentConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt'**
  String get agentPaymentConfirmAction;

  /// No description provided for @agentPaymentConfirmHelp.
  ///
  /// In en, this message translates to:
  /// **'Only confirm once the payment is actually received by the platform.'**
  String get agentPaymentConfirmHelp;

  /// No description provided for @agentPaymentNotReceivedNotice.
  ///
  /// In en, this message translates to:
  /// **'This payment is not confirmed as received.'**
  String get agentPaymentNotReceivedNotice;

  /// No description provided for @agentPaymentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment updated.'**
  String get agentPaymentUpdated;

  /// No description provided for @agentPaymentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment to follow'**
  String get agentPaymentEmptyTitle;

  /// No description provided for @agentPaymentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Payments to track will appear here.'**
  String get agentPaymentEmptyBody;

  /// No description provided for @migrationInProgress.
  ///
  /// In en, this message translates to:
  /// **'AgriConnect — migration in progress'**
  String get migrationInProgress;

  /// No description provided for @configurationMissing.
  ///
  /// In en, this message translates to:
  /// **'Configuration is missing'**
  String get configurationMissing;

  /// No description provided for @errUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session is no longer valid. Please sign in again.'**
  String get errUnauthorized;

  /// No description provided for @errProfileNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your profile must be verified to continue.'**
  String get errProfileNotVerified;

  /// No description provided for @errStateConflict.
  ///
  /// In en, this message translates to:
  /// **'This information has changed. Refresh and try again.'**
  String get errStateConflict;

  /// No description provided for @roleHomeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get roleHomeTab;

  /// No description provided for @roleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get roleComingSoon;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page could not be found.'**
  String get pageNotFound;

  /// No description provided for @onboardingPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingPageTitle;

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginPageTitle;

  /// No description provided for @registerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get registerPageTitle;

  /// No description provided for @forgotPasswordPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordPageTitle;

  /// No description provided for @legalPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get legalPageTitle;

  /// No description provided for @sessionExpiredNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get sessionExpiredNotice;

  /// No description provided for @sessionSuspendedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspended.'**
  String get sessionSuspendedNotice;

  /// No description provided for @sessionRevokedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session has been closed.'**
  String get sessionRevokedNotice;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email address or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'This account has been suspended. Contact our team.'**
  String get authAccountSuspended;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait before trying again.'**
  String get authTooManyAttempts;

  /// No description provided for @authUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authUnexpectedError;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check your network and try again.'**
  String get authNetworkError;

  /// No description provided for @authForgotLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotLink;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccount;

  /// No description provided for @authRolePrompt.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use AgriConnect?'**
  String get authRolePrompt;

  /// No description provided for @authSupplierChoice.
  ///
  /// In en, this message translates to:
  /// **'I sell (supplier)'**
  String get authSupplierChoice;

  /// No description provided for @authBuyerChoice.
  ///
  /// In en, this message translates to:
  /// **'I buy (buyer)'**
  String get authBuyerChoice;

  /// No description provided for @authLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get authLanguageLabel;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authPhone;

  /// No description provided for @authLocation.
  ///
  /// In en, this message translates to:
  /// **'City or locality (optional)'**
  String get authLocation;

  /// No description provided for @authFarmName.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get authFarmName;

  /// No description provided for @authBuyerType.
  ///
  /// In en, this message translates to:
  /// **'Buyer type'**
  String get authBuyerType;

  /// No description provided for @authBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business name (optional)'**
  String get authBusinessName;

  /// No description provided for @authReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get authReferralCode;

  /// No description provided for @authBuyerRetailer.
  ///
  /// In en, this message translates to:
  /// **'Retailer'**
  String get authBuyerRetailer;

  /// No description provided for @authBuyerFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get authBuyerFarmer;

  /// No description provided for @authBuyerWholesaler.
  ///
  /// In en, this message translates to:
  /// **'Wholesaler'**
  String get authBuyerWholesaler;

  /// No description provided for @authBuyerOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get authBuyerOther;

  /// No description provided for @authPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, one lowercase, one uppercase, one number and one of @\$!%*?&. Four identical characters in a row are not allowed.'**
  String get authPasswordHelp;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get authAcceptTerms;

  /// No description provided for @authGeneralTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get authGeneralTerms;

  /// No description provided for @authRoleTerms.
  ///
  /// In en, this message translates to:
  /// **'supplier consignment terms'**
  String get authRoleTerms;

  /// No description provided for @authBuyerTerms.
  ///
  /// In en, this message translates to:
  /// **'buyer terms'**
  String get authBuyerTerms;

  /// No description provided for @authTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept both documents to continue.'**
  String get authTermsRequired;

  /// No description provided for @authRegistrationConflict.
  ///
  /// In en, this message translates to:
  /// **'This email address or phone number is already in use.'**
  String get authRegistrationConflict;

  /// No description provided for @authCreate.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get authCreate;

  /// No description provided for @authCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get authCreating;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authForgotIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. If it is associated with an account, you will receive a reset link.'**
  String get authForgotIntro;

  /// No description provided for @authSendReset.
  ///
  /// In en, this message translates to:
  /// **'Send the link'**
  String get authSendReset;

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'If this address matches an account, a password reset link has been sent.'**
  String get authResetSent;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToLogin;

  /// No description provided for @authLegalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This document is not available right now.'**
  String get authLegalUnavailable;

  /// No description provided for @authEmailUnverified.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address to access all features.'**
  String get authEmailUnverified;

  /// No description provided for @authResendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get authResendVerification;

  /// No description provided for @authVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'A new verification link has been sent.'**
  String get authVerificationSent;

  /// No description provided for @authVerificationWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait 5 minutes before requesting another link.'**
  String get authVerificationWait;

  /// No description provided for @authPasswordPolicyInvalid.
  ///
  /// In en, this message translates to:
  /// **'The password does not meet the requirements shown.'**
  String get authPasswordPolicyInvalid;

  /// No description provided for @authOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The connected agricultural marketplace'**
  String get authOnboardingSubtitle;

  /// No description provided for @authValueInvalid.
  ///
  /// In en, this message translates to:
  /// **'This value is invalid.'**
  String get authValueInvalid;

  /// No description provided for @authOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get authOptional;

  /// No description provided for @accountTab.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTab;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get accountTitle;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountProfile;

  /// No description provided for @accountDocuments.
  ///
  /// In en, this message translates to:
  /// **'Verification documents'**
  String get accountDocuments;

  /// No description provided for @accountPayoutAccounts.
  ///
  /// In en, this message translates to:
  /// **'Payout accounts'**
  String get accountPayoutAccounts;

  /// No description provided for @accountReferral.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get accountReferral;

  /// No description provided for @accountSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions and security'**
  String get accountSessions;

  /// No description provided for @accountLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountLanguage;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get accountEmail;

  /// No description provided for @accountLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get accountLocation;

  /// No description provided for @accountFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get accountFirstName;

  /// No description provided for @accountLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get accountLastName;

  /// No description provided for @accountFarmName.
  ///
  /// In en, this message translates to:
  /// **'Farm name'**
  String get accountFarmName;

  /// No description provided for @accountDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get accountDescription;

  /// No description provided for @accountBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get accountBusinessName;

  /// No description provided for @accountBuyerType.
  ///
  /// In en, this message translates to:
  /// **'Buyer type'**
  String get accountBuyerType;

  /// No description provided for @accountZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get accountZone;

  /// No description provided for @accountVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get accountVehicleType;

  /// No description provided for @accountPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get accountPlateNumber;

  /// No description provided for @accountAvatarChange.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get accountAvatarChange;

  /// No description provided for @accountSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your changes.'**
  String get accountSaveFailed;

  /// No description provided for @accountAvatarInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPEG, PNG, or WebP image no larger than 5 MB.'**
  String get accountAvatarInvalid;

  /// No description provided for @accountVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile verification'**
  String get accountVerificationTitle;

  /// No description provided for @accountVerificationUnverified.
  ///
  /// In en, this message translates to:
  /// **'Verify your profile to get started.'**
  String get accountVerificationUnverified;

  /// No description provided for @accountVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Your profile is being reviewed.'**
  String get accountVerificationPending;

  /// No description provided for @accountVerificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your profile was rejected. Submit a new document.'**
  String get accountVerificationRejected;

  /// No description provided for @accountVerificationVerified.
  ///
  /// In en, this message translates to:
  /// **'Profile verified'**
  String get accountVerificationVerified;

  /// No description provided for @accountDocumentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No verification documents submitted.'**
  String get accountDocumentsEmpty;

  /// No description provided for @accountDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get accountDocumentType;

  /// No description provided for @accountSelectDocument.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get accountSelectDocument;

  /// No description provided for @accountDocumentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The document must be no larger than 8 MB.'**
  String get accountDocumentTooLarge;

  /// No description provided for @accountDocumentInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or a JPEG, PNG, or WebP image.'**
  String get accountDocumentInvalid;

  /// No description provided for @accountDocumentPendingLimit.
  ///
  /// In en, this message translates to:
  /// **'You already have five documents awaiting review.'**
  String get accountDocumentPendingLimit;

  /// No description provided for @accountUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Submit document'**
  String get accountUploadDocument;

  /// No description provided for @accountFileName.
  ///
  /// In en, this message translates to:
  /// **'Selected file'**
  String get accountFileName;

  /// No description provided for @accountPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Payout accounts'**
  String get accountPayoutTitle;

  /// No description provided for @accountAddPayout.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountAddPayout;

  /// No description provided for @accountPayoutMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get accountPayoutMethod;

  /// No description provided for @accountProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider or bank'**
  String get accountProvider;

  /// No description provided for @accountAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountAccountNumber;

  /// No description provided for @accountAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get accountAccountName;

  /// No description provided for @accountDefault.
  ///
  /// In en, this message translates to:
  /// **'Default account'**
  String get accountDefault;

  /// No description provided for @accountNoPayout.
  ///
  /// In en, this message translates to:
  /// **'No payout accounts saved.'**
  String get accountNoPayout;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this payout account?'**
  String get accountDeleteConfirm;

  /// No description provided for @accountReferralTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite people you know'**
  String get accountReferralTitle;

  /// No description provided for @accountReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get accountReferralCode;

  /// No description provided for @accountCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get accountCopyCode;

  /// No description provided for @accountCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied.'**
  String get accountCopied;

  /// No description provided for @accountReferralNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Referral rewards are available after your profile is verified.'**
  String get accountReferralNotVerified;

  /// No description provided for @accountPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get accountPending;

  /// No description provided for @accountEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible'**
  String get accountEligible;

  /// No description provided for @accountPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get accountPaid;

  /// No description provided for @accountNoReferrals.
  ///
  /// In en, this message translates to:
  /// **'No referrals yet.'**
  String get accountNoReferrals;

  /// No description provided for @accountSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get accountSessionsTitle;

  /// No description provided for @accountCurrentSession.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get accountCurrentSession;

  /// No description provided for @accountCloseSession.
  ///
  /// In en, this message translates to:
  /// **'Close session'**
  String get accountCloseSession;

  /// No description provided for @accountLogoutOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out other devices'**
  String get accountLogoutOthers;

  /// No description provided for @accountLogoutOthersConfirm.
  ///
  /// In en, this message translates to:
  /// **'Other sessions will be closed. This device will stay signed in.'**
  String get accountLogoutOthersConfirm;

  /// No description provided for @accountLogoutOthersDone.
  ///
  /// In en, this message translates to:
  /// **'Other sessions have been closed.'**
  String get accountLogoutOthersDone;

  /// No description provided for @accountSessionCreated.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get accountSessionCreated;

  /// No description provided for @accountSessionLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get accountSessionLastActive;

  /// No description provided for @accountSessionExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get accountSessionExpires;

  /// No description provided for @accountSessionIp.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get accountSessionIp;

  /// No description provided for @accountLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get accountLanguageTitle;

  /// No description provided for @verificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile not verified'**
  String get verificationRequiredTitle;

  /// No description provided for @verificationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Verify your profile to use this feature.'**
  String get verificationRequiredMessage;

  /// No description provided for @verificationOpenDocuments.
  ///
  /// In en, this message translates to:
  /// **'View documents'**
  String get verificationOpenDocuments;

  /// No description provided for @accountLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this information.'**
  String get accountLoadError;

  /// No description provided for @accountSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get accountSearch;

  /// No description provided for @accountCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get accountCategory;

  /// No description provided for @accountAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get accountAllCategories;

  /// No description provided for @accountNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get accountNoResults;

  /// No description provided for @accountDocumentsIntro.
  ///
  /// In en, this message translates to:
  /// **'Submit the requested documents to verify your profile.'**
  String get accountDocumentsIntro;

  /// No description provided for @accountDocumentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document submitted for verification.'**
  String get accountDocumentUploaded;

  /// No description provided for @accountDocumentId.
  ///
  /// In en, this message translates to:
  /// **'Identity document'**
  String get accountDocumentId;

  /// No description provided for @accountDocumentBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business registration'**
  String get accountDocumentBusiness;

  /// No description provided for @accountDocumentFarm.
  ///
  /// In en, this message translates to:
  /// **'Proof of farming'**
  String get accountDocumentFarm;

  /// No description provided for @accountDocumentOther.
  ///
  /// In en, this message translates to:
  /// **'Other document'**
  String get accountDocumentOther;

  /// No description provided for @accountRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get accountRejected;

  /// No description provided for @accountEditPayout.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get accountEditPayout;

  /// No description provided for @accountSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get accountSaved;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteTitle;

  /// No description provided for @accountCurrentNumber.
  ///
  /// In en, this message translates to:
  /// **'Saved number'**
  String get accountCurrentNumber;

  /// No description provided for @accountNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 4 and 64 characters.'**
  String get accountNumberInvalid;

  /// No description provided for @accountMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get accountMobileMoney;

  /// No description provided for @accountBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get accountBankTransfer;

  /// No description provided for @accountCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountCash;

  /// No description provided for @accountEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accountEdit;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDelete;

  /// No description provided for @accountSessionClosed.
  ///
  /// In en, this message translates to:
  /// **'Session closed.'**
  String get accountSessionClosed;

  /// No description provided for @accountCloseSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close this session?'**
  String get accountCloseSessionConfirm;

  /// No description provided for @accountUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get accountUnknownDevice;

  /// No description provided for @accountRetailer.
  ///
  /// In en, this message translates to:
  /// **'Retailer'**
  String get accountRetailer;

  /// No description provided for @accountFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get accountFarmer;

  /// No description provided for @accountWholesaler.
  ///
  /// In en, this message translates to:
  /// **'Wholesaler'**
  String get accountWholesaler;

  /// No description provided for @accountOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountOther;

  /// No description provided for @accountReferralBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get accountReferralBuyer;

  /// No description provided for @accountReferralSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get accountReferralSupplier;

  /// No description provided for @accountStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get accountStatusPending;

  /// No description provided for @accountStatusEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible'**
  String get accountStatusEligible;

  /// No description provided for @accountStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get accountStatusPaid;

  /// No description provided for @accountStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get accountStatusRejected;

  /// No description provided for @supplierLotsTab.
  ///
  /// In en, this message translates to:
  /// **'My lots'**
  String get supplierLotsTab;

  /// No description provided for @supplierRevenueTab.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get supplierRevenueTab;

  /// No description provided for @supplierLotDashboard.
  ///
  /// In en, this message translates to:
  /// **'Lot overview'**
  String get supplierLotDashboard;

  /// No description provided for @supplierDeclareLot.
  ///
  /// In en, this message translates to:
  /// **'Declare a lot'**
  String get supplierDeclareLot;

  /// No description provided for @supplierLotPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get supplierLotPendingCount;

  /// No description provided for @supplierLotAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get supplierLotAvailableCount;

  /// No description provided for @supplierLotReservedCount.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get supplierLotReservedCount;

  /// No description provided for @supplierLotSoldCount.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get supplierLotSoldCount;

  /// No description provided for @supplierAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get supplierAllStatuses;

  /// No description provided for @supplierLotStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting validation'**
  String get supplierLotStatusPending;

  /// No description provided for @supplierLotStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get supplierLotStatusAvailable;

  /// No description provided for @supplierLotStatusReserved.
  ///
  /// In en, this message translates to:
  /// **'Fully reserved'**
  String get supplierLotStatusReserved;

  /// No description provided for @supplierLotStatusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get supplierLotStatusSold;

  /// No description provided for @supplierLotStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get supplierLotStatusExpired;

  /// No description provided for @supplierLotStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get supplierLotStatusReturned;

  /// No description provided for @supplierLotStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get supplierLotStatusRejected;

  /// No description provided for @supplierLotStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get supplierLotStatusWithdrawn;

  /// No description provided for @supplierLotEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lots yet. Declare your first lot.'**
  String get supplierLotEmpty;

  /// No description provided for @supplierLotProductStep.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get supplierLotProductStep;

  /// No description provided for @supplierLotQuantityStep.
  ///
  /// In en, this message translates to:
  /// **'Quantity and price'**
  String get supplierLotQuantityStep;

  /// No description provided for @supplierLotStorageStep.
  ///
  /// In en, this message translates to:
  /// **'Storage and area'**
  String get supplierLotStorageStep;

  /// No description provided for @supplierLotPhotosStep.
  ///
  /// In en, this message translates to:
  /// **'Photos and details'**
  String get supplierLotPhotosStep;

  /// No description provided for @supplierLotNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Declare a lot'**
  String get supplierLotNewTitle;

  /// No description provided for @supplierLotEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit lot'**
  String get supplierLotEditTitle;

  /// No description provided for @supplierLotProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get supplierLotProduct;

  /// No description provided for @supplierLotQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get supplierLotQuantity;

  /// No description provided for @supplierLotAgreedPrice.
  ///
  /// In en, this message translates to:
  /// **'Agreed unit price'**
  String get supplierLotAgreedPrice;

  /// No description provided for @supplierLotUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String supplierLotUnitHint(String unit);

  /// No description provided for @supplierLotZone.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get supplierLotZone;

  /// No description provided for @supplierLotStorageType.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get supplierLotStorageType;

  /// No description provided for @supplierLotHubStorage.
  ///
  /// In en, this message translates to:
  /// **'At a collection hub'**
  String get supplierLotHubStorage;

  /// No description provided for @supplierLotSiteStorage.
  ///
  /// In en, this message translates to:
  /// **'At my farm'**
  String get supplierLotSiteStorage;

  /// No description provided for @supplierLotHub.
  ///
  /// In en, this message translates to:
  /// **'Collection hub'**
  String get supplierLotHub;

  /// No description provided for @supplierLotPickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get supplierLotPickupAddress;

  /// No description provided for @supplierLotLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get supplierLotLatitude;

  /// No description provided for @supplierLotLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get supplierLotLongitude;

  /// No description provided for @supplierUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get supplierUseLocation;

  /// No description provided for @supplierLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location could not be obtained. Enter it manually.'**
  String get supplierLocationUnavailable;

  /// No description provided for @supplierLotChoosePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get supplierLotChoosePhotos;

  /// No description provided for @supplierLotPhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'Add between 1 and 5 photos.'**
  String get supplierLotPhotosRequired;

  /// No description provided for @supplierLotPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Each photo must be 5 MB or smaller.'**
  String get supplierLotPhotoTooLarge;

  /// No description provided for @supplierLotHarvestedAt.
  ///
  /// In en, this message translates to:
  /// **'Harvest date (optional)'**
  String get supplierLotHarvestedAt;

  /// No description provided for @supplierLotExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get supplierLotExpiresAt;

  /// No description provided for @supplierLotPackagingNote.
  ///
  /// In en, this message translates to:
  /// **'Packaging notes'**
  String get supplierLotPackagingNote;

  /// No description provided for @supplierLotQualityNote.
  ///
  /// In en, this message translates to:
  /// **'Quality notes'**
  String get supplierLotQualityNote;

  /// No description provided for @supplierLotNotesLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum 500 characters.'**
  String get supplierLotNotesLimit;

  /// No description provided for @supplierLotNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get supplierLotNext;

  /// No description provided for @supplierLotPrevious.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get supplierLotPrevious;

  /// No description provided for @supplierLotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit lot'**
  String get supplierLotSubmit;

  /// No description provided for @supplierLotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Lot submitted for validation.'**
  String get supplierLotSubmitted;

  /// No description provided for @supplierLotQuantityError.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity above zero with up to 3 decimal places.'**
  String get supplierLotQuantityError;

  /// No description provided for @supplierLotPriceError.
  ///
  /// In en, this message translates to:
  /// **'Enter an agreed price above zero with up to 2 decimal places.'**
  String get supplierLotPriceError;

  /// No description provided for @supplierLotSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose a product.'**
  String get supplierLotSelectProduct;

  /// No description provided for @supplierLotSelectZone.
  ///
  /// In en, this message translates to:
  /// **'Choose an area.'**
  String get supplierLotSelectZone;

  /// No description provided for @supplierLotSelectHub.
  ///
  /// In en, this message translates to:
  /// **'Choose a collection hub.'**
  String get supplierLotSelectHub;

  /// No description provided for @supplierLotPickupRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the pickup address and valid coordinates.'**
  String get supplierLotPickupRequired;

  /// No description provided for @supplierLotExpiryRequired.
  ///
  /// In en, this message translates to:
  /// **'An expiry date is required for perishable products.'**
  String get supplierLotExpiryRequired;

  /// No description provided for @supplierLotNotesError.
  ///
  /// In en, this message translates to:
  /// **'Notes must not exceed 500 characters.'**
  String get supplierLotNotesError;

  /// No description provided for @supplierLotInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial quantity'**
  String get supplierLotInitial;

  /// No description provided for @supplierLotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available quantity'**
  String get supplierLotAvailable;

  /// No description provided for @supplierLotReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved quantity'**
  String get supplierLotReserved;

  /// No description provided for @supplierLotSold.
  ///
  /// In en, this message translates to:
  /// **'Sold quantity'**
  String get supplierLotSold;

  /// No description provided for @supplierLotLost.
  ///
  /// In en, this message translates to:
  /// **'Lost quantity'**
  String get supplierLotLost;

  /// No description provided for @supplierLotRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get supplierLotRejectionReason;

  /// No description provided for @supplierLotContactTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact the team'**
  String get supplierLotContactTeam;

  /// No description provided for @supplierLotChatPrefill.
  ///
  /// In en, this message translates to:
  /// **'I have a question about lot {code}.'**
  String supplierLotChatPrefill(String code);

  /// No description provided for @supplierLotDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete lot'**
  String get supplierLotDelete;

  /// No description provided for @supplierLotDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this lot?'**
  String get supplierLotDeleteConfirm;

  /// No description provided for @supplierLotWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw lot'**
  String get supplierLotWithdraw;

  /// No description provided for @supplierLotWithdrawReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for withdrawal'**
  String get supplierLotWithdrawReason;

  /// No description provided for @supplierLotWithdrawError.
  ///
  /// In en, this message translates to:
  /// **'Enter a reason of up to 500 characters.'**
  String get supplierLotWithdrawError;

  /// No description provided for @supplierLotEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get supplierLotEdit;

  /// No description provided for @supplierLotIncomePayouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get supplierLotIncomePayouts;

  /// No description provided for @supplierLotIncomeCompensations.
  ///
  /// In en, this message translates to:
  /// **'Compensations'**
  String get supplierLotIncomeCompensations;

  /// No description provided for @supplierIncomeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet.'**
  String get supplierIncomeEmpty;

  /// No description provided for @supplierPayoutGross.
  ///
  /// In en, this message translates to:
  /// **'Gross amount'**
  String get supplierPayoutGross;

  /// No description provided for @supplierPayoutCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get supplierPayoutCommission;

  /// No description provided for @supplierPayoutNet.
  ///
  /// In en, this message translates to:
  /// **'Net amount'**
  String get supplierPayoutNet;

  /// No description provided for @supplierPayoutStatusOnHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get supplierPayoutStatusOnHold;

  /// No description provided for @supplierPayoutStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get supplierPayoutStatusReady;

  /// No description provided for @supplierPayoutStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get supplierPayoutStatusPaid;

  /// No description provided for @supplierPayoutStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get supplierPayoutStatusCancelled;

  /// No description provided for @supplierCompensationReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get supplierCompensationReason;

  /// No description provided for @supplierCompensationQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get supplierCompensationQuantity;

  /// No description provided for @supplierCompensationAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get supplierCompensationAmount;

  /// No description provided for @supplierCompensationNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get supplierCompensationNote;

  /// No description provided for @supplierCompensationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get supplierCompensationStatusPending;

  /// No description provided for @supplierCompensationStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get supplierCompensationStatusApproved;

  /// No description provided for @supplierCompensationStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get supplierCompensationStatusPaid;

  /// No description provided for @supplierCompensationStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get supplierCompensationStatusRejected;

  /// No description provided for @supplierOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get supplierOptional;

  /// No description provided for @supplierClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get supplierClear;

  /// No description provided for @supplierSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get supplierSave;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
