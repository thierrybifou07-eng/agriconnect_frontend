import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/validators.dart';
import 'package:agri_connect/features/auth/application/register_controller.dart';
import 'package:agri_connect/features/auth/presentation/widgets/selected_role_banner.dart';
import 'package:agri_connect/features/onboarding/application/welcome_controller.dart';
import 'package:agri_connect/shared/widgets/auth_page_layout.dart';
import 'package:agri_connect/shared/widgets/app_text_field.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final role = ref.read(
      welcomeControllerProvider.select((s) => s.selectedRole),
    );
    if (role == null) return;
    await ref
        .read(registerControllerProvider.notifier)
        .submit(
          fullName: _nameController.text,
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: role,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final state = ref.watch(registerControllerProvider);

    return AuthPageLayout(
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      brandMessage: l10n.tagline,
      form: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                iconSize: 28,
                onPressed: () => context.go(RoutePaths.login),
              ),
            ),
            SelectedRoleBanner(title: l10n.registerAsRoleTitle),
            if (state.failure != null) ...[
              const SizedBox(height: 16),
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
              controller: _nameController,
              label: l10n.fullNameLabel,
              icon: Icons.person_outline_rounded,
              validator: Validators.name(l10n),
              textInputAction: TextInputAction.next,
              enabled: !state.isLoading,
            ),
            const SizedBox(height: 14),
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
              textInputAction: TextInputAction.next,
              enabled: !state.isLoading,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _confirmController,
              label: l10n.confirmPasswordLabel,
              icon: Icons.lock_outline_rounded,
              obscure: true,
              validator: Validators.confirmPassword(
                () => _passwordController.text,
                l10n,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              enabled: !state.isLoading,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: state.isLoading
                  ? l10n.registerCreating
                  : l10n.registerCreate,
              loading: state.isLoading,
              onPressed: _submit,
              icon: Icons.person_add_alt_1_rounded,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  l10n.registerAlreadyAccount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.go(RoutePaths.login),
                  child: Text(l10n.registerSignIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
