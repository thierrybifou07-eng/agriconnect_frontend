import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/buyer/data/buyer_welcome_storage.dart';

/// Tracks whether the buyer dashboard welcome has been dismissed.
///
/// The state is read from local storage on first build. A storage failure must
/// never keep the buyer out of the dashboard, so the banner is simply treated
/// as dismissed for the session when persistence is unavailable.
class BuyerWelcomeController extends Notifier<bool> {
  bool _restored = false;

  @override
  bool build() {
    _restore();
    return false;
  }

  Future<void> _restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final storage = ref.read(buyerWelcomeStorageProvider);
      state = await storage.readSeen();
    } catch (_) {
      state = true;
    }
  }

  Future<void> markSeen() async {
    state = true;
    try {
      await ref.read(buyerWelcomeStorageProvider).writeSeen(true);
    } catch (_) {
      // Persisting is best-effort: the banner stays dismissed for the session.
    }
  }
}

final buyerWelcomeControllerProvider =
    NotifierProvider<BuyerWelcomeController, bool>(BuyerWelcomeController.new);
