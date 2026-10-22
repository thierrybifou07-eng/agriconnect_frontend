import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/core/constants/app_constants.dart';
import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/localization/locale_x.dart';
import 'package:agri_connect/features/auth/domain/user_role.dart';
import 'package:agri_connect/features/super_admin/application/super_admin_providers.dart';
import 'package:agri_connect/features/super_admin/domain/staff_account.dart';
import 'package:agri_connect/features/super_admin/domain/staff_permission.dart';
import 'package:agri_connect/features/super_admin/domain/super_admin_repository.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_staff_tile.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/super_admin_states.dart';
import 'package:agri_connect/features/super_admin/presentation/widgets/staff_permissions_sheet.dart';
import 'package:agri_connect/shared/widgets/empty_state.dart';
import 'package:agri_connect/shared/widgets/section_header.dart';
import 'package:agri_connect/shared/widgets/skeletons.dart';

/// Staff directory: who works on the platform and what each may do.
///
/// The screen owns the query and the reload; every write goes through the
/// repository and reports its own outcome, so a rejected change leaves the list
/// untouched instead of diverging from the repository.
class SuperAdminStaffPage extends ConsumerStatefulWidget {
  const SuperAdminStaffPage({super.key, this.repository, this.currentUserId});

  /// Injected in tests; defaults to the production provider.
  final SuperAdminRepository? repository;

  /// Session identifier, so the account in use cannot be edited or suspended.
  final String? currentUserId;

  @override
  ConsumerState<SuperAdminStaffPage> createState() =>
      _SuperAdminStaffPageState();
}

class _SuperAdminStaffPageState extends ConsumerState<SuperAdminStaffPage> {
  late Future<List<StaffAccount>> _staff;
  final TextEditingController _search = TextEditingController();
  String _query = '';
  UserRole? _role;
  StaffAccountStatus? _status;
  bool _mutating = false;

  SuperAdminRepository get _repository =>
      widget.repository ?? ref.read(superAdminRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _staff = _fetch();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Starts a read and makes sure a failure cannot escape before the rebuild.
  ///
  /// The future is created outside a build, while the builder only subscribes
  /// on the next frame. A repository that fails immediately would therefore
  /// leave a failed future with no listener for a microtask, which the zone
  /// reports as an unhandled error: the screen would crash instead of showing
  /// the retry card. Listening here marks the error as handled while the
  /// builder still receives it.
  Future<List<StaffAccount>> _fetch() {
    // Filtering happens in the repository rather than on a full list: the
    // console must show what the platform would return for these filters, not
    // what happens to be in memory here.
    final future = _repository.fetchStaff(
      query: _query,
      role: _role,
      status: _status,
    );
    unawaited(future.then<void>((_) {}, onError: (Object _) {}));
    return future;
  }

  void _reload() {
    setState(() {
      _staff = _fetch();
    });
  }

  /// Returns the directory to its unfiltered state.
  ///
  /// Assigned once and reused by the header and the empty state so the field
  /// and the query can never drift apart.
  void _clearQuery() {
    _search.clear();
    setState(() => _query = '');
    _reload();
  }

  /// Returns the directory to the whole staff, dropping search and filters.
  void _resetFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _role = null;
      _status = null;
    });
    _reload();
  }

  /// True while a filter narrows the directory.
  ///
  /// The empty state reads differently when a filter is responsible: a reader
  /// who filtered by role and got nothing needs the reset, not the search field.
  bool get _filtered => _query.isNotEmpty || _role != null || _status != null;

  void _setRole(UserRole? role) {
    setState(() => _role = role);
    _reload();
  }

  void _setStatus(StaffAccountStatus? status) {
    setState(() => _status = status);
    _reload();
  }

  /// Runs a write, then reloads and reports the outcome.
  ///
  /// The reload happens whether the write succeeded or failed: a rejected write
  /// may still have changed something server side, and a directory that kept
  /// showing the attempted state would be lying.
  Future<void> _mutate(
    Future<void> Function() job, {
    required String successLabel,
  }) async {
    if (_mutating) return;
    setState(() => _mutating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await job();
      _reload();
      messenger.showSnackBar(SnackBar(content: Text(successLabel)));
    } on Exception catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
    if (mounted) setState(() => _mutating = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            // One scrollable for the whole page, header and search field
            // included: a short viewport (landscape, keyboard open) leaves too
            // little room for a fixed header block, and a Column that overflows
            // there hides the very search the reader came for.
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePadding,
                        AppSizes.pagePadding,
                        AppSizes.pagePadding,
                        0,
                      ),
                      child: SectionHeader(
                        title: l10n.superAdminStaffTitle,
                        // One reset covers the search and the filters, so the
                        // header never offers a way out of only one of them.
                        actionLabel: _filtered
                            ? l10n.superAdminStaffReset
                            : null,
                        onAction: _filtered ? _resetFilters : null,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePadding,
                        4,
                        AppSizes.pagePadding,
                        0,
                      ),
                      child: Text(
                        l10n.superAdminStaffSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.pagePadding,
                        0,
                        AppSizes.pagePadding,
                        AppSizes.pagePadding,
                      ),
                      child: TextField(
                        key: const ValueKey('superAdmin.staff.search'),
                        controller: _search,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.superAdminStaffSearchHint,
                          labelText: l10n.superAdminStaffSearchLabel,
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.fieldRadius,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          _query = value;
                          _reload();
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSizes.pagePadding,
                      ),
                      child: _buildFilters(l10n),
                    ),
                  ),
                  ..._buildList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Role and status filters, as one scrolling row.
  ///
  /// Only the staff roles are offered: the directory never holds a farmer or a
  /// buyer, so a filter on those would return nothing by construction rather
  /// than by data. A horizontal scroll keeps the row on a 320 dp phone and at
  /// large fonts, where three lines of chips would leave no room for the list.
  ///
  /// The row is a plain scroll view rather than a lazy list: with a handful of
  /// chips a lazy list cannot know how far it scrolls until every chip has been
  /// laid out, so it reports no scrollable extent and strands the chips beyond
  /// the right edge, where they can never be tapped.
  Widget _buildFilters(AppLocalizations l10n) {
    final staffRoles = UserRole.values
        .where((role) => role == UserRole.admin || role == UserRole.root)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Row(
        children: [
          _chip(
            l10n: l10n,
            key: 'superAdmin.staff.filter.role',
            label: l10n.superAdminStaffFilterRole,
            selected: _role == null,
            onSelected: () => _setRole(null),
          ),
          for (final role in staffRoles)
            _chip(
              l10n: l10n,
              key: 'superAdmin.staff.filter.role.${role.name}',
              label: role.label(l10n),
              selected: _role == role,
              onSelected: () => _setRole(_role == role ? null : role),
            ),
          const SizedBox(width: 8),
          _chip(
            l10n: l10n,
            key: 'superAdmin.staff.filter.status',
            label: l10n.superAdminStaffFilterStatus,
            selected: _status == null,
            onSelected: () => _setStatus(null),
          ),
          for (final status in StaffAccountStatus.values)
            _chip(
              l10n: l10n,
              key: 'superAdmin.staff.filter.status.${status.name}',
              label: status == StaffAccountStatus.active
                  ? l10n.superAdminStaffStatusActive
                  : l10n.superAdminStaffStatusSuspended,
              selected: _status == status,
              onSelected: () => _setStatus(_status == status ? null : status),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required AppLocalizations l10n,
    required String key,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        key: ValueKey(key),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
      ),
    );
  }

  /// The directory itself, as slivers so it scrolls with the header.
  List<Widget> _buildList() {
    final l10n = context.l10n;

    return [
      FutureBuilder<List<StaffAccount>>(
        future: _staff,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: SuperAdminPageError(
                message: '${snapshot.error}',
                onRetry: _reload,
              ),
            );
          }
          final staff = snapshot.data;
          if (staff == null) {
            return const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                0,
                AppSizes.pagePadding,
                28,
              ),
              sliver: SliverToBoxAdapter(child: CardListSkeleton(itemCount: 4)),
            );
          }
          if (staff.isEmpty) {
            final reset = _filtered ? _resetFilters : _clearQuery;
            return SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                key: const ValueKey('superAdmin.staff.empty'),
                icon: Icons.person_search_rounded,
                title: l10n.superAdminStaffTitle,
                body: l10n.superAdminStaffEmpty,
                // A filter that matched nothing is cleared or reset here: the
                // repository offers no way to add a member, so offering that
                // would be a dead end.
                actionLabel: _filtered
                    ? l10n.superAdminStaffReset
                    : l10n.cancel,
                onAction: reset,
                actionIcon: Icons.clear_rounded,
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              0,
              AppSizes.pagePadding,
              28,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Trailing row states how many members the query matched,
                  // so a filtered directory never looks accidentally short.
                  if (index == staff.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.superAdminStaffCount(staff.length),
                        key: const ValueKey('superAdmin.staff.count'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final account = staff[index];
                  final manageable = account.canBeManagedBy(
                    widget.currentUserId ?? '',
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SuperAdminStaffTile(
                      account: account,
                      onEditPermissions: manageable
                          ? () => _editPermissions(account)
                          : null,
                      onSuspend: manageable && account.isActive
                          ? () => _mutate(
                              () => _repository.suspendStaff(account.id),
                              successLabel: l10n.superAdminStaffSuspended,
                            )
                          : null,
                      onRestore: manageable && !account.isActive
                          ? () => _mutate(
                              () => _repository.restoreStaff(account.id),
                              successLabel: l10n.superAdminStaffRestored,
                            )
                          : null,
                      enabled: !_mutating,
                    ),
                  );
                },
                childCount: staff.length + 1,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// Opens the rights editor and reloads once it reports its outcome.
  Future<void> _editPermissions(StaffAccount account) async {
    await StaffPermissionsSheet.show(
      context,
      account: account,
      // The sheet reports success itself when the write lands, and failure when
      // the repository refuses it, so this only has to perform the write.
      // A failure is rethrown rather than swallowed: the sheet catches it, keeps
      // its draft and shows the repository's reason, so the reader keeps what
      // they selected instead of watching it vanish.
      onSave: (Set<StaffPermission> permissions) =>
          _repository.updateStaffPermissions(account.id, permissions),
    );
    // Reloads after the sheet closes, so a save performed there is reflected
    // even when the repository accepted it silently.
    _reload();
  }
}
