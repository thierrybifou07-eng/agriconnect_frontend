import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';
import 'package:agri_connect/core/ui/ui_state.dart';
import 'package:agri_connect/features/admin/domain/admin_operations.dart';
import 'package:agri_connect/features/admin/presentation/controllers/admin_operations_controller.dart';
import 'package:agri_connect/features/admin/presentation/widgets/admin_widgets.dart';

part 'admin_referentials_page.dart';
part 'admin_agencies_page.dart';
part 'admin_financial_pages.dart';
part 'admin_legal_page.dart';
part 'admin_operation_form_widgets.dart';

class AdminOperationsPage extends StatelessWidget {
  const AdminOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.adminReferentials),
              Tab(text: l10n.adminAgencies),
              Tab(text: l10n.adminPayouts),
              Tab(text: l10n.adminReferrals),
              Tab(text: l10n.adminCompensations),
              Tab(text: l10n.adminLegalVersions),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _ReferentialsPanel(),
                _AgenciesPanel(),
                _MoneyPanel(kind: 'payouts'),
                _MoneyPanel(kind: 'referrals'),
                _MoneyPanel(kind: 'compensations'),
                _LegalPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
