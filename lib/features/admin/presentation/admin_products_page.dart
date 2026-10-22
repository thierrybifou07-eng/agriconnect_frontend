import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/core/utils/formatting.dart';
import 'package:agri_connect/features/admin/domain/admin_moderation_status.dart';
import 'package:agri_connect/features/admin/domain/admin_product.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_category_l10n.dart';
import 'package:agri_connect/features/admin/presentation/extensions/admin_moderation_status_l10n.dart';
import 'package:agri_connect/features/auth/domain/capability.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/section_states.dart';
import 'package:agri_connect/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';

/// Administrator — product moderation queue.
///
/// Strictly serial wiring, PHASE 08E. Mirrors [AdminUsersPage]: every field and
/// every repository method used here is checked against the committed models
/// and the real abstract [AdminRepository].
///
/// Moderation is a fine-grained action guarded by the [UserCapability.stockValidation]
/// capability: without it the decision menu is not even offered, so the
/// capability guard protects the action itself, not only the route.
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({
    super.key,
    required this.repository,
    this.capabilities = const {},
  });

  final AdminRepository repository;

  /// Capabilities granted to the signed-in session; moderation requires
  /// [UserCapability.stockValidation]. Defaults empty (least privilege).
  final Set<UserCapability> capabilities;

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  late Future<List<AdminProduct>> _products;
  String _query = '';
  AdminModerationStatus? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _products = widget.repository.fetchProducts();
  }

  void _reload() {
    setState(() {
      _products = widget.repository.fetchProducts(
        query: _query.trim().isEmpty ? null : _query,
        status: _status,
      );
    });
  }

  Future<void> _moderate(Future<void> Function() job) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final updated = context.l10n.adminProductsUpdated;
    final failed = context.l10n.adminActionFailed;
    setState(() => _busy = true);
    try {
      await job();
      messenger.showSnackBar(SnackBar(content: Text(updated)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) _reload();
  }

  Future<void> _confirmReject(AdminProduct product) async {
    final controller = TextEditingController();
    final l10n = context.l10n;
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        // Without this the field is pushed under the Android keyboard, which
        // cannot scroll the dialog out of the way.
        scrollable: true,
        title: Text(l10n.adminProductsRejectTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.adminProductsRejectReasonHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.adminProductsRejectAction),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return;
    await _moderate(
      () => widget.repository.rejectProduct(product.id, reason: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The shell already owns the app bar for the workspace: a nested one would
    // stack a second title bar under it on a phone.
    //
    // The header, the search field and the filters live in slivers instead of a
    // rigid Column. Stacked above an Expanded list they could not shrink, so a
    // short screen with large fonts pushed the list off the bottom and painted
    // the overflow stripes; here the whole page scrolls instead.
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.pagePadding,
              AppSizes.pagePadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(title: context.l10n.adminProductsTitle),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverToBoxAdapter(
              child: TextField(
                decoration: InputDecoration(
                  hintText: context.l10n.adminProductsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _query = value;
                  _reload();
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 12),
            sliver: SliverToBoxAdapter(child: _buildStatusFilter()),
          ),
          FutureBuilder<List<AdminProduct>>(
            future: _products,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _SectionError(
                    id: 'products',
                    message: '${snapshot.error}',
                    onRetry: _reload,
                  ),
                );
              }
              final products = snapshot.data;
              if (products == null) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (products.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.l10n.adminProductsEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverList.separated(
                itemCount: products.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final canModerate = widget.capabilities.contains(
                    UserCapability.stockValidation,
                  );
                  return _ProductTile(
                    product: product,
                    onApprove: canModerate && product.moderation.isUnderReview
                        ? () => _moderate(
                            () => widget.repository.approveProduct(product.id),
                          )
                        : null,
                    onReject: canModerate && product.moderation.isUnderReview
                        ? () => _confirmReject(product)
                        : null,
                    onArchive: canModerate && product.moderation.isDecided
                        ? () => _moderate(
                            () => widget.repository.archiveProduct(product.id),
                          )
                        : null,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final options = <AdminModerationStatus?>[
      null,
      AdminModerationStatus.pending,
      AdminModerationStatus.validated,
      AdminModerationStatus.suspended,
      AdminModerationStatus.rejected,
      AdminModerationStatus.archived,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        children: [
          for (final option in options)
            ChoiceChip(
              label: Text(_filterLabel(option)),
              selected: _status == option,
              onSelected: (_) {
                _status = option;
                _reload();
              },
            ),
        ],
      ),
    );
  }

  String _filterLabel(AdminModerationStatus? status) {
    final l10n = context.l10n;
    return status == null ? l10n.adminFilterAll : status.label(l10n);
  }
}

/// Section-level failure of the queue, retryable like the dashboard's.
class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.id,
    required this.message,
    required this.onRetry,
  });

  final String id;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: SectionErrorCard(
        keyPrefix: 'admin',
        id: id,
        title: l10n.adminSectionLoadError,
        detail: l10n.adminSectionLoadErrorDetail(message),
        retryLabel: l10n.retry,
        onRetry: onRetry,
      ),
    );
  }
}

/// Moderation decisions offered by a product tile.
///
/// An enum rather than bare strings so the menu cannot send a value no case
/// handles, and so the labels stay free to be translated.
enum _ProductAction { approve, reject, archive }

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    this.onApprove,
    this.onReject,
    this.onArchive,
  });

  final AdminProduct product;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasActions =
        onApprove != null || onReject != null || onArchive != null;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(product.name.isEmpty ? '?' : product.name[0].toUpperCase()),
      ),
      title: Text(product.name),
      // The badge gets a line of its own under the metadata rather than sharing
      // it. Sharing worked until a French status ("En attente") met a 1.5x text
      // scale on a 360dp screen: the row of metadata, gap and badge was then
      // wider than the tile and the tile refused to lay out. Stacked, the badge
      // is never squeezed and the metadata line keeps its full width to
      // ellipsize.
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${product.ownerName} — '
            '${adminCategoryLabel(l10n, product.category)} · '
            '${Money.format(product.price.round(), locale: context.localeCode)} '
            '${product.unit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: StatusBadge(
              label: product.moderation.label(l10n),
              color: product.moderation.color(),
              icon: product.moderation.icon,
            ),
          ),
        ],
      ),
      isThreeLine: false,
      // Without a granted moderation capability there is no decision to
      // offer, so the menu is hidden rather than shown empty.
      trailing: hasActions
          ? PopupMenuButton<_ProductAction>(
              key: ValueKey('admin.products.menu.${product.id}'),
              onSelected: (action) => switch (action) {
                _ProductAction.approve => onApprove?.call(),
                _ProductAction.reject => onReject?.call(),
                _ProductAction.archive => onArchive?.call(),
              },
              itemBuilder: (context) => [
                if (onApprove != null)
                  PopupMenuItem(
                    value: _ProductAction.approve,
                    child: Text(l10n.adminProductApprove),
                  ),
                if (onReject != null)
                  PopupMenuItem(
                    value: _ProductAction.reject,
                    child: Text(l10n.adminProductsRejectAction),
                  ),
                if (onArchive != null)
                  PopupMenuItem(
                    value: _ProductAction.archive,
                    child: Text(l10n.adminProductArchive),
                  ),
              ],
            )
          : null,
    );
  }
}
