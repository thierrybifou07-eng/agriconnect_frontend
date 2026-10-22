import 'package:flutter/material.dart';

/// Bounds an agent screen to the measure it reads best in.
///
/// A phone is narrower than [maxContentWidth], so nothing changes there; on a
/// tablet or a desktop window the line length stops growing, which keeps the
/// reference, the names and the status of a case legible instead of stretched
/// across a browser. Every agent screen shares this measure, so the dashboard
/// and the four section lists stay aligned with each other.
class AgentContent extends StatelessWidget {
  const AgentContent({super.key, required this.child});

  final Widget child;

  /// Longest line an agent screen may take on a wide window.
  static const double maxContentWidth = 720;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
