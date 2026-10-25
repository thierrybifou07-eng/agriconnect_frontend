import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/app/routes/app_routes.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/core/utils/validators.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_page_controllers.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.agriculture_rounded, size: 64),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).splashLoading),
          const SizedBox(height: 18),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingPageTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: Get.locale?.languageCode == 'en' ? 'en' : 'fr',
              underline: const SizedBox.shrink(),
              onChanged: (value) {
                if (value != null) controller.chooseLanguage(value);
              },
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('FR')),
                DropdownMenuItem(value: 'en', child: Text('EN')),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Icon(Icons.agriculture_rounded, size: 72),
              const SizedBox(height: 20),
              Text(
                l10n.authOnboardingSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              Text(l10n.authRolePrompt, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: [
                    _RoleChoice(
                      label: l10n.authSupplierChoice,
                      selected:
                          controller.selectedRole.value == RoleCode.supplier,
                      icon: Icons.spa_outlined,
                      onTap: () => controller.chooseRole(RoleCode.supplier),
                    ),
                    const SizedBox(height: 12),
                    _RoleChoice(
                      label: l10n.authBuyerChoice,
                      selected: controller.selectedRole.value == RoleCode.buyer,
                      icon: Icons.shopping_basket_outlined,
                      onTap: () => controller.chooseRole(RoleCode.buyer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: controller.continueToRegister,
                child: Text(l10n.authContinue),
              ),
              TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                child: Text(l10n.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginPageTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                const Icon(Icons.agriculture_rounded, size: 62),
                const SizedBox(height: 20),
                Text(
                  l10n.loginGreeting,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(l10n.loginSubtitle, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Obx(
                  () => _AuthErrorBanner(
                    failure: _failure(controller.auth),
                    message: (failure) => _failureMessage(failure, l10n),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => TextFormField(
                    controller: controller.email,
                    enabled: !controller.loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      errorText: controller.auth.fieldErrors['email'],
                    ),
                    validator: Validators.email(l10n),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => TextFormField(
                    controller: controller.password,
                    enabled: !controller.loading,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => controller.submit(),
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      errorText: controller.auth.fieldErrors['password'],
                    ),
                    validator: (value) => (value ?? '').isEmpty
                        ? l10n.validationPasswordRequired
                        : null,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    child: Text(l10n.authForgotLink),
                  ),
                ),
                Obx(
                  () => FilledButton.icon(
                    onPressed: controller.loading ? null : controller.submit,
                    icon: controller.loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login_rounded),
                    label: Text(
                      controller.loading ? l10n.signingIn : l10n.signIn,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.authNoAccount),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.onboarding),
                      child: Text(l10n.authCreateAccount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends GetView<RegisterPageController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerPageTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Obx(() {
            final isSupplier = controller.role.value == RoleCode.supplier;
            final busy = controller.loading;
            final l10n = AppLocalizations.of(context);
            return Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    l10n.registerTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.registerSubtitle),
                  const SizedBox(height: 20),
                  SegmentedButton<RoleCode>(
                    segments: [
                      ButtonSegment(
                        value: RoleCode.supplier,
                        label: Text(l10n.authSupplierChoice),
                        icon: const Icon(Icons.spa_outlined),
                      ),
                      ButtonSegment(
                        value: RoleCode.buyer,
                        label: Text(l10n.authBuyerChoice),
                        icon: const Icon(Icons.shopping_basket_outlined),
                      ),
                    ],
                    selected: {controller.role.value},
                    onSelectionChanged: busy
                        ? null
                        : (values) => controller.selectRole(values.first),
                  ),
                  const SizedBox(height: 16),
                  _AuthErrorBanner(
                    failure: _failure(controller.auth),
                    message: (failure) => _failureMessage(failure, l10n),
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: controller.firstname,
                    label: l10n.authFirstName,
                    serverError: controller.auth.fieldErrors['firstname'],
                    validator: (value) => _minimumLength(value, 2, l10n),
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: controller.lastname,
                    label: l10n.authLastName,
                    serverError: controller.auth.fieldErrors['lastname'],
                    validator: (value) => _minimumLength(value, 2, l10n),
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: controller.phone,
                    label: l10n.authPhone,
                    keyboardType: TextInputType.phone,
                    serverError: controller.auth.fieldErrors['phone'],
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(input)
                          ? null
                          : l10n.validationPhoneInvalid;
                    },
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: controller.email,
                    label: l10n.emailLabel,
                    keyboardType: TextInputType.emailAddress,
                    serverError: controller.auth.fieldErrors['email'],
                    validator: Validators.email(l10n),
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: controller.password,
                    label: l10n.passwordLabel,
                    obscureText: true,
                    serverError: controller.auth.fieldErrors['password'],
                    onChanged: (value) =>
                        controller.passwordValue.value = value,
                    validator: (value) => _passwordMatches(value ?? '')
                        ? null
                        : l10n.authPasswordPolicyInvalid,
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      l10n.authPasswordHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _passwordMatches(controller.passwordValue.value)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isSupplier) ...[
                    _RegisterField(
                      controller: controller.farmName,
                      label: l10n.authFarmName,
                      serverError: controller.auth.fieldErrors['farmName'],
                      validator: (value) => _lengthRange(value, 2, 120, l10n),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    DropdownButtonFormField<String>(
                      initialValue: controller.buyerType.value,
                      decoration: InputDecoration(
                        labelText: l10n.authBuyerType,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'RETAILER',
                          child: Text(l10n.authBuyerRetailer),
                        ),
                        DropdownMenuItem(
                          value: 'FARMER',
                          child: Text(l10n.authBuyerFarmer),
                        ),
                        DropdownMenuItem(
                          value: 'WHOLESALER',
                          child: Text(l10n.authBuyerWholesaler),
                        ),
                        DropdownMenuItem(
                          value: 'OTHER',
                          child: Text(l10n.authBuyerOther),
                        ),
                      ],
                      onChanged: busy
                          ? null
                          : (value) {
                              if (value != null) {
                                controller.buyerType.value = value;
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    _RegisterField(
                      controller: controller.businessName,
                      label: l10n.authBusinessName,
                      serverError: controller.auth.fieldErrors['businessName'],
                      validator: (value) => _maximumLength(value, 120, l10n),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _RegisterField(
                    controller: controller.location,
                    label: l10n.authLocation,
                    serverError: controller.auth.fieldErrors['location'],
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: controller.referralCode,
                    label: l10n.authReferralCode,
                    serverError: controller.auth.fieldErrors['referralCode'],
                    validator: (value) => _maximumLength(value, 20, l10n),
                  ),
                  const SizedBox(height: 14),
                  _TermsCheck(
                    value: controller.acceptedGeneralTerms.value,
                    prefix: l10n.authAcceptTerms,
                    title: l10n.authGeneralTerms,
                    onChanged: (value) =>
                        controller.acceptedGeneralTerms.value = value,
                    onRead: () => Get.toNamed(AppRoutes.legalDocument('CGU')),
                  ),
                  _TermsCheck(
                    value: controller.acceptedRoleTerms.value,
                    title: isSupplier
                        ? l10n.authRoleTerms
                        : l10n.authBuyerTerms,
                    onChanged: (value) =>
                        controller.acceptedRoleTerms.value = value,
                    onRead: () => Get.toNamed(
                      AppRoutes.legalDocument(
                        isSupplier
                            ? 'SUPPLIER_CONSIGNMENT_TERMS'
                            : 'BUYER_TERMS',
                      ),
                    ),
                  ),
                  if (controller.termsError.value)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        l10n.authTermsRequired,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: busy ? null : controller.submit,
                    child: busy
                        ? Text(l10n.authCreating)
                        : Text(l10n.authCreate),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    child: Text(l10n.authHaveAccount),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPasswordPageTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Obx(
            () => ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(l10n.authForgotIntro),
                const SizedBox(height: 20),
                if (controller.submitted.value)
                  Text(
                    l10n.authResetSent,
                    key: const ValueKey('reset-confirmation'),
                  )
                else
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.emailLabel,
                          ),
                          validator: Validators.email(l10n),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: controller.loading.value
                              ? null
                              : controller.submit,
                          child: Text(l10n.authSendReset),
                        ),
                      ],
                    ),
                  ),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  child: Text(l10n.authBackToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LegalPage extends GetView<LegalPageController> {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.legalPageTitle)),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notFound.value) {
          return Center(child: Text(l10n.authLegalUnavailable));
        }
        if (controller.failure.value != null ||
            controller.document.value == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.authUnexpectedError),
                TextButton(onPressed: controller.load, child: Text(l10n.retry)),
              ],
            ),
          );
        }
        final document = controller.document.value!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              document.title ?? l10n.legalPageTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (document.version != null) Text(document.version!),
            const SizedBox(height: 20),
            SelectableText(document.content ?? ''),
          ],
        );
      }),
    );
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle) : null,
      minVerticalPadding: 18,
    ),
  );
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.label,
    this.validator,
    this.serverError,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final String? serverError;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label, errorText: serverError),
    validator: validator,
  );
}

class _TermsCheck extends StatelessWidget {
  const _TermsCheck({
    required this.value,
    required this.title,
    required this.onChanged,
    required this.onRead,
    this.prefix = '',
  });

  final bool value;
  final String title;
  final String prefix;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Checkbox(value: value, onChanged: (next) => onChanged(next ?? false)),
      Expanded(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (prefix.isNotEmpty) Text('$prefix '),
            TextButton(
              onPressed: onRead,
              child: Text(title, textAlign: TextAlign.start),
            ),
          ],
        ),
      ),
    ],
  );
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.failure, required this.message});

  final ApiFailure? failure;
  final String Function(ApiFailure) message;

  @override
  Widget build(BuildContext context) {
    if (failure == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message(failure!),
        style: TextStyle(color: colors.onErrorContainer),
      ),
    );
  }
}

ApiFailure? _failure(AuthController auth) {
  final state = auth.authState.value;
  return state is Failure<void> ? state.failure : null;
}

String _failureMessage(ApiFailure failure, AppLocalizations l10n) {
  if (failure.status == 401) return l10n.authInvalidCredentials;
  if (failure.isSuspended || failure.status == 403) {
    return l10n.authAccountSuspended;
  }
  if (failure.status == 429) return l10n.authTooManyAttempts;
  if (failure.status == 409) return l10n.authRegistrationConflict;
  if (failure.kind == ApiFailureKind.network ||
      failure.kind == ApiFailureKind.timeout) {
    return l10n.authNetworkError;
  }
  return l10n.authUnexpectedError;
}

bool _passwordMatches(String password) => RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])(?!.*(.)\1\1\1)[A-Za-z\d@$!%*?&]{8,}$',
).hasMatch(password);

String? _minimumLength(String? value, int minimum, AppLocalizations l10n) =>
    (value ?? '').trim().length >= minimum ? null : l10n.validationNameTooShort;

String? _lengthRange(
  String? value,
  int minimum,
  int maximum,
  AppLocalizations l10n,
) {
  final length = (value ?? '').trim().length;
  return length >= minimum && length <= maximum ? null : l10n.authValueInvalid;
}

String? _maximumLength(String? value, int maximum, AppLocalizations l10n) =>
    (value ?? '').trim().length <= maximum ? null : l10n.authValueInvalid;
