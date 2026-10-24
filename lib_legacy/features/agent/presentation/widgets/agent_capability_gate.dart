import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';

/// Guards an agent section behind the capability it requires.
///
/// Hiding the tab in the shell is ergonomics; this is the enforcement. A
/// session that reaches the route without the capability — a deep link, a
/// capability revoked mid-session — is shown a clear refusal instead of the
/// data. Every agent section wraps its body in this gate.
class AgentCapabilityGate extends ConsumerWidget {
  const AgentCapabilityGate({
    super.key,
    required this.capability,
    required this.child,
  });

  final UserCapability capability;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    if (user != null && user.hasCapability(capability)) return child;

    return EmptyState(
      icon: Icons.lock_outline_rounded,
      title: l10n.agentAccessDeniedTitle,
      body: l10n.agentAccessDeniedBody,
    );
  }
}
