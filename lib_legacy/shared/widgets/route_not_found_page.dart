import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_connect/core/constants/route_paths.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/application/auth_controller.dart';

/// Fallback shown by GoRouter when no route matches the requested address.
///
/// Unknown top-level addresses are already sent home by [RedirectPolicy];
/// this page covers the addresses that match a role prefix but no declared
/// sub-route (e.g. `/supplier/bogus`), so the user sees a friendly, localized
/// page and a way back to their workspace instead of a bare error screen and
/// the risk of a redirect loop.
class RouteNotFoundPage extends ConsumerWidget {
  const RouteNotFoundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    final home = user?.role.homePath ?? RoutePaths.login;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.alt_route,
                  size: 56,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.routeNotFoundTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.routeNotFoundBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(home),
                  child: Text(l10n.routeNotFoundHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
