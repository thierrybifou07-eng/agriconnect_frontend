import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/validators.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/shared/widgets/app_text_field.dart';
import 'package:agri_connect/shared/widgets/sign_out_button.dart';

/// Shared profile page for every role.
class RoleProfilePage extends ConsumerStatefulWidget {
  const RoleProfilePage({super.key});

  @override
  ConsumerState<RoleProfilePage> createState() => _RoleProfilePageState();
}

class _RoleProfilePageState extends ConsumerState<RoleProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  Failure? _saveFailure;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing(AuthUser user) {
    _nameController.text = user.fullName;
    setState(() {
      _isEditing = true;
      _saveFailure = null;
    });
  }

  Future<void> _cancelEditing(AuthUser user) async {
    if (_isSaving) return;
    final hasChanges = _nameController.text.trim() != user.fullName;
    if (hasChanges) {
      final l10n = context.l10n;
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.profileDiscardTitle),
          content: Text(l10n.profileDiscardBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.profileKeepEditingAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.profileDiscardAction),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }

    setState(() {
      _isEditing = false;
      _saveFailure = null;
    });
    _nameController.text = user.fullName;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveFailure = null;
    });
    final failure = await ref
        .read(authControllerProvider.notifier)
        .updateProfileName(_nameController.text);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _saveFailure = failure;
      if (failure == null) _isEditing = false;
    });
    if (failure == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.profileUpdated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    if (user == null) return const SizedBox.shrink();

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (!_isEditing)
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  )
                else ...[
                  Text(
                    l10n.profileEditTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.profileEditDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: AppTextField(
                      controller: _nameController,
                      label: l10n.fullNameLabel,
                      icon: Icons.person_outline_rounded,
                      validator: Validators.name(l10n),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                    ),
                  ),
                  if (_saveFailure != null) ...[
                    const SizedBox(height: 12),
                    _ProfileFailure(message: _saveFailure!.message(l10n)),
                  ],
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final save = FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(l10n.profileSaveAction),
                      );
                      final cancel = OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => _cancelEditing(user),
                        child: Text(l10n.cancel),
                      );
                      if (constraints.maxWidth < 420) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [save, const SizedBox(height: 10), cancel],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: save),
                          const SizedBox(width: 12),
                          Expanded(child: cancel),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Center(
                  child: Chip(
                    avatar: Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: Text(user.role.label(l10n)),
                  ),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _startEditing(user),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.profileEditAction),
                  ),
                ],
                const SizedBox(height: 24),
                Text(l10n.accountInfo, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: colorScheme.primary,
                        ),
                        title: Text(user.email),
                        subtitle: Text(l10n.emailLabel),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: colorScheme.primary,
                        ),
                        title: Text(user.role.label(l10n)),
                        subtitle: Text(l10n.connectedAs),
                      ),
                    ],
                  ),
                ),
                if (user.capabilities.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.permissionsTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final capability in user.capabilities)
                            Chip(
                              avatar: Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              label: Text(capability.label(l10n)),
                              labelStyle: theme.textTheme.labelMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const SizedBox(width: double.infinity, child: SignOutButton()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileFailure extends StatelessWidget {
  const _ProfileFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: colors.onErrorContainer),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
