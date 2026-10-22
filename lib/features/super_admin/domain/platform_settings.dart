import 'package:flutter/foundation.dart';

/// Tunable platform parameters owned by the Super Admin.
///
/// Modelled as one immutable snapshot with a [copyWith], so the settings screen
/// edits a local draft and writes it once, and so two screens reading the
/// settings can never observe half of a change.
@immutable
class PlatformSettings {
  const PlatformSettings({
    required this.registrationsOpen,
    required this.autoModeration,
    required this.maintenanceMode,
    required this.supportEmail,
    required this.maxUploadMb,
    required this.updatedAt,
  });

  /// Whether the platform still accepts new sign-ups.
  final bool registrationsOpen;

  /// Whether moderation decisions are applied without a human review.
  ///
  /// Surfaced as a warning in the settings screen: turning it on means products
  /// go live before anyone has looked at them.
  final bool autoModeration;

  /// Whether the marketplace is hidden from buyers and farmers.
  final bool maintenanceMode;

  final String supportEmail;

  /// Upload ceiling applied to product photos, in megabytes.
  final int maxUploadMb;

  final DateTime updatedAt;

  /// Settings that would keep an end user from transacting.
  bool get blocksMarketplace => maintenanceMode || !registrationsOpen;

  PlatformSettings copyWith({
    bool? registrationsOpen,
    bool? autoModeration,
    bool? maintenanceMode,
    String? supportEmail,
    int? maxUploadMb,
    DateTime? updatedAt,
  }) {
    return PlatformSettings(
      registrationsOpen: registrationsOpen ?? this.registrationsOpen,
      autoModeration: autoModeration ?? this.autoModeration,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      supportEmail: supportEmail ?? this.supportEmail,
      maxUploadMb: maxUploadMb ?? this.maxUploadMb,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
