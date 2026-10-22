import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/shared/widgets/app_logo.dart';

class WelcomePageLayout extends StatelessWidget {
  const WelcomePageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget content;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final compact = viewport.maxWidth < 380;
            final short = viewport.maxHeight < 700;
            final verticalPadding = compact ? 20.0 : (short ? 16.0 : 32.0);
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : AppSizes.pagePadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewport.maxHeight - verticalPadding * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppLogo(size: 44),
                        SizedBox(height: short ? 20 : 32),
                        Text(
                          title,
                          textAlign: TextAlign.left,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: short ? 16 : 24),
                        Container(
                          padding: EdgeInsets.all(
                            compact ? 14 : (short ? 16 : 20),
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowSoft,
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: content,
                        ),
                        if (footer != null) ...[
                          SizedBox(height: short ? 8 : 12),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
