import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/super_admin/domain/platform_settings.dart';

/// One switchable platform parameter.
///
/// A setting that changes what an end user can do carries a warning line, so
/// the reader understands the effect before flipping it rather than after.
class PlatformSettingSwitch extends StatelessWidget {
  const PlatformSettingSwitch({
    super.key,
    required this.settingId,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.body,
    this.warning,
    this.enabled = true,
  });

  /// Stable identifier of the setting, used for keys.
  ///
  /// Keys must not be built from [title]: that text is localized, so a key made
  /// of it changes with the language and a test or a state lookup would miss.
  final String settingId;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData icon;
  final String title;
  final String body;

  /// Effect worth repeating when the switch is on, such as a maintenance mode
  /// that takes the marketplace offline.
  final String? warning;

  /// False while a write is in flight, which greys the row instead of letting
  /// the reader queue conflicting changes.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isWarningVisible = value && warning != null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isWarningVisible
                          ? AppColors.warning.withValues(alpha: 0.12)
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isWarningVisible
                          ? AppColors.warning
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    key: PlatformSettingSwitch.keyFor(settingId),
                    value: value,
                    // The row also toggles, so the switch itself must swallow
                    // the gesture instead of firing the callback twice.
                    onChanged: enabled ? onChanged : null,
                  ),
                ],
              ),
              if (isWarningVisible) ...[
                const SizedBox(height: 10),
                Container(
                  key: ValueKey('superAdmin.settingWarning.$settingId'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Convenience for the switch's key, kept stable across languages.
  static Key keyFor(String id) => ValueKey('superAdmin.setting.$id');
}

/// Read-only line stating when the settings were last written.
class PlatformSettingsStamp extends StatelessWidget {
  const PlatformSettingsStamp({super.key, required this.settings});

  final PlatformSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.history_rounded, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.superAdminSettingUpdatedAt(
              AppFormats.date(settings.updatedAt, locale: context.localeCode),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
