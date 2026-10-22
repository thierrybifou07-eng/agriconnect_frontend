import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';
import 'package:agri_connect/features/super_admin/domain/platform_settings.dart';
import 'package:agri_connect/features/super_admin/domain/super_admin_repository.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/platform_setting_switch.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_states.dart';
import 'package:agri_connect/shared/widgets/primary_button.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// System settings: the parameters the Super Admin owns.
///
/// Toggles and fields edit a local draft and are written once, on save. That
/// matters here more than on a list screen: a maintenance switch applied the
/// moment it is touched would take the marketplace offline before the Super
/// Admin could read what they were about to do.
class SuperAdminPlatformPage extends ConsumerStatefulWidget {
  const SuperAdminPlatformPage({super.key, this.repository});

  /// Injected in tests; defaults to the production provider.
  final SuperAdminRepository? repository;

  @override
  ConsumerState<SuperAdminPlatformPage> createState() =>
      _SuperAdminPlatformPageState();
}

class _SuperAdminPlatformPageState
    extends ConsumerState<SuperAdminPlatformPage> {
  late Future<PlatformSettings> _settings;

  /// Controllers for the two text fields.
  ///
  /// Owned by the state rather than rebuilt in [build]: a controller created
  /// inside a build method is thrown away on every rebuild, which would move the
  /// caret and discard what the reader had typed.
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _upload = TextEditingController();

  /// The saved configuration. Null until the first load, which is also what
  /// keeps the form out of the way while the page reads.
  PlatformSettings? _saved;

  /// The configuration being edited. Only the whole snapshot is written, so a
  /// rejected draft cannot leave two fields disagreeing with each other.
  PlatformSettings? _draft;

  String? _emailError;
  String? _uploadError;
  bool _saving = false;

  SuperAdminRepository get _repository =>
      widget.repository ?? ref.read(superAdminRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _settings = _guard(_load());
  }

  /// Keeps an immediate failure from escaping before the first frame.
  ///
  /// The future is created in [initState] and only subscribed to by the builder
  /// on the next frame, so a repository that fails immediately would otherwise
  /// surface as an unhandled error instead of the retry card.
  static Future<T> _guard<T>(Future<T> future) {
    unawaited(future.then<void>((_) {}, onError: (Object _) {}));
    return future;
  }

  @override
  void dispose() {
    _email.dispose();
    _upload.dispose();
    super.dispose();
  }

  Future<PlatformSettings> _load() async {
    final settings = await _repository.fetchSettings();
    // Applied after the await: the load can complete after the widget is gone.
    if (mounted) {
      setState(() {
        _saved = settings;
        _draft = settings;
      });
      _syncFields(settings);
    }
    return settings;
  }

  /// Puts the stored values into the fields after a load or a save, so the form
  /// always shows what the repository holds rather than a stale draft.
  void _syncFields(PlatformSettings settings) {
    _email.text = settings.supportEmail;
    _upload.text = '${settings.maxUploadMb}';
  }

  void _reload() {
    setState(() {
      _settings = _guard(_repository.fetchSettings());
      _saved = null;
      _draft = null;
      _emailError = null;
      _uploadError = null;
    });
  }

  /// True when the draft differs from what is stored, which is what enables the
  /// save button and drives the "unsaved changes" notice.
  bool get _hasChanges {
    final saved = _saved;
    final draft = _draft;
    if (saved == null || draft == null) return false;
    return saved.registrationsOpen != draft.registrationsOpen ||
        saved.autoModeration != draft.autoModeration ||
        saved.maintenanceMode != draft.maintenanceMode ||
        saved.supportEmail != draft.supportEmail ||
        saved.maxUploadMb != draft.maxUploadMb;
  }

  /// Validates both text fields, because a save that silently discards an
  /// invalid entry would look like the console dropped the change.
  bool _validate(PlatformSettings draft) {
    final l10n = context.l10n;
    final emailValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(draft.supportEmail.trim());
    final uploadValid = draft.maxUploadMb >= 1 && draft.maxUploadMb <= 20;

    setState(() {
      _emailError = emailValid
          ? null
          : l10n.superAdminSettingSupportEmailInvalid;
      _uploadError = uploadValid
          ? null
          : l10n.superAdminSettingMaxUploadInvalid;
    });
    return emailValid && uploadValid;
  }

  Future<void> _save() async {
    final draft = _draft;
    if (_saving || draft == null) return;
    if (!_validate(draft)) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await _repository.saveSettings(
        draft.copyWith(supportEmail: draft.supportEmail.trim()),
      );
      if (!mounted) return;
      // Reads back what the repository stored, so the form shows the saved
      // timestamp and normalized values rather than the local draft.
      setState(() => _saving = false);
      _reload();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.superAdminSettingsSaved)),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      // The repository's message is the useful one; the localized copy only
      // covers an error that arrived without one.
      final message = '$error';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message.trim().isEmpty ? l10n.superAdminSettingsSaveError : message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    AppSizes.pagePadding,
                    AppSizes.pagePadding,
                    0,
                  ),
                  child: SectionHeader(title: l10n.superAdminPlatformTitle),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    4,
                    AppSizes.pagePadding,
                    0,
                  ),
                  child: Text(
                    l10n.superAdminPlatformSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<PlatformSettings>(
                    future: _settings,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SuperAdminPageError(
                          message: '${snapshot.error}',
                          onRetry: _reload,
                        );
                      }
                      if (snapshot.data == null) {
                        return const SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.pagePadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SkeletonBox(height: 84, radius: 16),
                                SizedBox(height: 12),
                                SkeletonBox(height: 84, radius: 16),
                                SizedBox(height: 12),
                                SkeletonBox(height: 84, radius: 16),
                                SizedBox(height: 12),
                                SkeletonBox(height: 140, radius: 16),
                              ],
                            ),
                          ),
                        );
                      }
                      return _buildForm(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final draft = _draft;
    if (draft == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
        28,
      ),
      children: [
        PlatformSettingSwitch(
          settingId: 'registrations',
          value: draft.registrationsOpen,
          icon: Icons.person_add_alt_rounded,
          title: l10n.superAdminSettingRegistrations,
          body: l10n.superAdminSettingRegistrationsBody,
          warning: null,
          onChanged: _saving
              ? null
              : (value) => setState(
                  () => _draft = draft.copyWith(registrationsOpen: value),
                ),
        ),
        const SizedBox(height: 10),
        PlatformSettingSwitch(
          settingId: 'autoModeration',
          value: draft.autoModeration,
          icon: Icons.auto_awesome_rounded,
          title: l10n.superAdminSettingAutoModeration,
          body: l10n.superAdminSettingAutoModerationBody,
          warning: l10n.superAdminSettingAutoModerationWarning,
          onChanged: _saving
              ? null
              : (value) => setState(
                  () => _draft = draft.copyWith(autoModeration: value),
                ),
        ),
        const SizedBox(height: 10),
        PlatformSettingSwitch(
          settingId: 'maintenance',
          value: draft.maintenanceMode,
          icon: Icons.construction_rounded,
          title: l10n.superAdminSettingMaintenance,
          body: l10n.superAdminSettingMaintenanceBody,
          warning: l10n.superAdminSettingMaintenanceWarning,
          onChanged: _saving
              ? null
              : (value) => setState(
                  () => _draft = draft.copyWith(maintenanceMode: value),
                ),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.superAdminPlatformSubtitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        // Support email and upload ceiling live in one card because both are
        // text inputs validated together before the write.
        Card(
          key: const ValueKey('superAdmin.setting.fields'),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('superAdmin.setting.supportEmail'),
                  enabled: !_saving,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  controller: _email,
                  onChanged: (value) => setState(
                    () => _draft = draft.copyWith(supportEmail: value),
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.superAdminSettingSupportEmail,
                    helperText: l10n.superAdminSettingSupportEmailBody,
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.support_agent_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const ValueKey('superAdmin.setting.maxUpload'),
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  controller: _upload,
                  onChanged: (value) {
                    final parsed = int.tryParse(value.trim());
                    setState(
                      () => _draft = draft.copyWith(
                        // An empty or malformed field keeps the previous value,
                        // so the field can be cleared without the draft
                        // silently becoming zero.
                        maxUploadMb: parsed ?? draft.maxUploadMb,
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: l10n.superAdminSettingMaxUpload,
                    helperText: l10n.superAdminSettingMaxUploadBody,
                    errorText: _uploadError,
                    prefixIcon: const Icon(Icons.image_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PlatformSettingsStamp(settings: draft),
        const SizedBox(height: 18),
        PrimaryButton(
          key: const ValueKey('superAdmin.settings.save'),
          label: l10n.superAdminSettingsSave,
          onPressed: _saving || !_hasChanges ? null : _save,
          icon: Icons.save_rounded,
          loading: _saving,
        ),
        if (_hasChanges) ...[
          const SizedBox(height: 10),
          // A visible reminder that the toggles above are not live yet: the
          // whole point of a draft is that nothing is applied before saving.
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.superAdminSettingsUnsaved,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
