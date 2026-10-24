import 'package:flutter/material.dart';

/// Bounds a driver screen to the measure it reads best in.
///
/// A phone is narrower than [maxContentWidth], so nothing changes there; on a
/// tablet or a desktop window the line length stops growing, which keeps the
/// route, the items and the status of a delivery legible instead of stretched
/// across a browser. Every driver screen shares this measure, so the dashboard,
/// the lists, the sheet and its action bar stay aligned with each other.
class DriverContent extends StatelessWidget {
  const DriverContent({super.key, required this.child});

  final Widget child;

  /// Longest line a driver screen may take on a wide window.
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
