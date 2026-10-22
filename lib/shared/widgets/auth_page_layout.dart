import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/shared/widgets/app_logo.dart';

/// Responsive presentation frame shared by sign-in and registration.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.brandMessage,
    required this.form,
  });

  final String title;
  final String subtitle;
  final String brandMessage;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final wide = viewport.maxWidth >= 900 && textScale < 1.5;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 32 : AppSizes.pagePadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight - 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(
                                child: _BrandPanel(
                                  message: brandMessage,
                                  textTheme: theme.textTheme,
                                ),
                              ),
                              const SizedBox(width: 40),
                              SizedBox(
                                width: 460,
                                child: _FormSurface(
                                  title: title,
                                  subtitle: subtitle,
                                  form: form,
                                  compactHeader: true,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AppLogo(size: 56),
                              const SizedBox(height: 20),
                              _FormSurface(
                                title: title,
                                subtitle: subtitle,
                                form: form,
                              ),
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

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.message, required this.textTheme});

  final String message;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 520),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_rounded, color: Colors.white, size: 58),
          const SizedBox(height: 28),
          Text(
            AppInfo.name,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              message,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Container(
            width: 72,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSurface extends StatelessWidget {
  const _FormSurface({
    required this.title,
    required this.subtitle,
    required this.form,
    this.compactHeader = false,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final bool compactHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compactHeader ? 32 : 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: compactHeader ? TextAlign.left : TextAlign.center,
            style: compactHeader
                ? theme.textTheme.headlineSmall
                : theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: compactHeader ? TextAlign.left : TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          form,
        ],
      ),
    );
  }
}
