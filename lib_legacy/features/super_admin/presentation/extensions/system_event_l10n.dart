import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/super_admin/domain/system_event.dart';

/// Localized wording of a [SystemEventAction].
///
/// Kept beside the action set rather than in the trail card, so the dashboard
/// and any future export describe the same recorded action the same way.
extension SystemEventActionL10n on SystemEventAction {
  /// The verb as it reads after the actor's name.
  ///
  /// French and English put the verb in the same slot here, which is why the
  /// trail can interpolate this into a sentence.
  String label(AppLocalizations l10n) => switch (this) {
    SystemEventAction.suspended => l10n.superAdminActionSuspended,
    SystemEventAction.restored => l10n.superAdminActionRestored,
    SystemEventAction.updatedPermissions =>
      l10n.superAdminActionUpdatedPermissions,
    SystemEventAction.updatedSettings => l10n.superAdminActionUpdatedSettings,
    SystemEventAction.moderatedProduct => l10n.superAdminActionModeratedProduct,
  };
}
