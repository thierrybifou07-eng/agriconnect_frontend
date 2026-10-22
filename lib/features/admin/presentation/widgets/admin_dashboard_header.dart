import 'package:flutter/material.dart';

import 'package:agri_connect/app/theme/app_colors.dart';
import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/shared/widgets/app_logo.dart';
import 'package:agri_connect/shared/widgets/user_avatar.dart';

/// Branded header of the Administrator dashboard.
///
/// Carries the identity of the signed-in administrator, what the console is
/// for, and the only contextual fact that is always true — the current date —
/// plus an explicit refresh for readers who do not think to pull the page.
///
/// Nothing here is decorative data: the greeting comes from the session, the
/// date from the device clock, and the refresh button calls the real reload.
class AdminDashboardHeader extends StatelessWidget {
  const AdminDashboardHeader({
    super.key,
    required this.fullName,
    required this.onRefresh,
  });

  /// Session administrator, used for the greeting and the avatar.
  final String fullName;

  /// Real reload of every dashboard section.
  final VoidCallback onRefresh;

  /// First word of [fullName], the form a greeting actually uses.
  String get _firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppSizes.imageRadius),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // The mark sits on a translucent plate: the brand gradient on top
              // of the brand gradient would leave an unreadable green square.
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppLogo(size: 30, withWordmark: false),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardWelcome(_firstName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.adminConsoleSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const ValueKey('admin.refresh'),
                onPressed: onRefresh,
                tooltip: l10n.adminRefreshTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Wrap, not Row: two labels that no longer fit on one line belong on
          // two lines, and a fixed row would overflow them instead.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderPill(
                icon: Icons.today_rounded,
                label:
                    '${l10n.adminTodayLabel} · ${AppFormats.date(DateTime.now(), locale: context.localeCode)}',
              ),
              _HeaderPill(
                icon: Icons.admin_panel_settings_rounded,
                label: l10n.adminConsoleLabel,
              ),
              _HeaderPill(
                icon: Icons.person_rounded,
                label: fullName,
                avatar: UserAvatar(name: fullName, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Translucent chip laid over the branded header.
class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label, this.avatar});

  final IconData icon;
  final String label;

  /// Optional avatar replacing [icon], used for the administrator identity.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatar != null) ...[
            avatar!,
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ],
          // Flexible so a long identity ellipsizes inside its pill rather than
          // pushing the pill past the header at a large font size.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
