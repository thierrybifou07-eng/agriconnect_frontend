import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';

/// Brand mark: a rounded gradient tile with the AgriConnect glyph,
/// optionally followed by the wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 44, this.withWordmark = true});

  final double size;
  final bool withWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Icon(Icons.eco_rounded, color: Colors.white, size: size * 0.58),
    );

    if (!withWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        // The wordmark gives way instead of pushing past the card: at the size
        // the login and onboarding screens ask for, a rigid wordmark overflowed
        // a 360dp phone while staying fine on a desktop window.
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Agri',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: 'Connect',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
