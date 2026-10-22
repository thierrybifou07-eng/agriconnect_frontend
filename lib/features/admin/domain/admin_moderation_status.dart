/// Moderation lifecycle of an entity supervised by the Administrator.
///
/// * [pending]  — submitted, waiting for an admin decision.
/// * [validated] — approved and live in the marketplace.
/// * [rejected] — refused by an admin (a reason is recorded at decision time).
/// * [suspended] — removed pending a decision; reversible.
/// * [archived] — soft-deleted; kept only for the audit trail.
enum AdminModerationStatus { pending, validated, rejected, suspended, archived }

extension AdminModerationStatusX on AdminModerationStatus {
  String keyName() => switch (this) {
    AdminModerationStatus.pending => 'pending',
    AdminModerationStatus.validated => 'validated',
    AdminModerationStatus.rejected => 'rejected',
    AdminModerationStatus.suspended => 'suspended',
    AdminModerationStatus.archived => 'archived',
  };

  bool get isUnderReview => this == AdminModerationStatus.pending;
  bool get isLive => this == AdminModerationStatus.validated;
  bool get isDecided =>
      this == AdminModerationStatus.validated ||
      this == AdminModerationStatus.rejected;
}
