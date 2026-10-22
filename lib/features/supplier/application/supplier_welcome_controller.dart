import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/supplier/data/supplier_welcome_storage.dart';

/// Tracks whether the supplier dashboard welcome has been dismissed.
class SupplierWelcomeController extends Notifier<bool> {
  bool _restored = false;

  @override
  bool build() {
    _restore();
    return false;
  }

  Future<void> _restore() async {
    if (_restored) return;
    _restored = true;
    final storage = ref.read(supplierWelcomeStorageProvider);
    state = await storage.readSeen();
  }

  Future<void> markSeen() async {
    if (state) return;
    state = true;
    final storage = ref.read(supplierWelcomeStorageProvider);
    await storage.writeSeen(true);
  }
}

final supplierWelcomeControllerProvider =
    NotifierProvider<SupplierWelcomeController, bool>(SupplierWelcomeController.new);
