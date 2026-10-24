import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/validators.dart';
import 'package:agri_connect/features/auth/application/login_controller.dart';
import 'package:agri_connect/features/auth/data/demo_auth_repository.dart';
import 'package:agri_connect/features/auth/presentation/widgets/selected_role_banner.dart';
import 'package:agri_connect/features/onboarding/application/welcome_controller.dart';
import 'package:agri_connect/shared/widgets/auth_page_layout.dart';
import 'package:agri_connect/shared/widgets/app_text_field.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';
import 'package:agri_connect/shared/widgets/role_avatar.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final expectedRole = ref.read(
      welcomeControllerProvider.select((s) => s.selectedRole),
    );
    await ref
        .read(loginControllerProvider.notifier)
        .submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          expectedRole: expectedRole,
        );
  }

  Future<void> _fillFromAccount(DemoAccount account) async {
    _emailController.text = account.email;
    _passwordController.text = account.password;
    // Staff accounts cannot be picked on the role page, which only offers the
    // self-registerable roles. Selecting the role for them keeps the
    // expected-role guard and the signed-in redirect in sync with the demo
    // account, while marketplace demo chips keep the currently selected role
    // so the guard can still reject a mismatched account.
    if (account.role.isStaff) {
      await ref
          .read(welcomeControllerProvider.notifier)
          .selectRole(account.role);
    }
    return _submit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final state = ref.watch(loginControllerProvider);

    return AuthPageLayout(
      title: l10n.loginGreeting,
      subtitle: l10n.loginSubtitle,
      brandMessage: l10n.tagline,
      form: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SelectedRoleBanner(),
            if (state.failure != null) ...[
              const SizedBox(height: 20),
              Material(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.failure!.message(l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            AppTextField(
              controller: _emailController,
              label: l10n.emailLabel,
              icon: Icons.alternate_email_rounded,
              validator: Validators.email(l10n),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !state.isLoading,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _passwordController,
              label: l10n.passwordLabel,
              icon: Icons.lock_outline_rounded,
              obscure: true,
              validator: Validators.password(l10n),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              enabled: !state.isLoading,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: state.isLoading ? l10n.signingIn : l10n.signIn,
              loading: state.isLoading,
              onPressed: _submit,
              icon: Icons.login_rounded,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.demoAccountsTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.demoAccountsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final account in DemoAuthRepository.accounts)
                        ActionChip(
                          tooltip: account.role.label(l10n),
                          avatar: Icon(
                            account.role.icon,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          label: Text(
                            account.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: state.isLoading
                              ? null
                              : () => _fillFromAccount(account),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  l10n.loginNoAccount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.go(RoutePaths.register),
                  child: Text(l10n.loginCreateAccount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
