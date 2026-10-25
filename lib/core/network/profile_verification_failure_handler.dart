import 'dart:async';

import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/api_failure_events.dart';
import 'package:agri_connect/core/ui/app_notifier.dart';

class ProfileVerificationFailureHandler extends GetxService {
  ProfileVerificationFailureHandler(this._events);

  final ApiFailureEvents _events;
  StreamSubscription<ApiFailure>? _subscription;
  bool _showingDialog = false;

  @override
  void onInit() {
    super.onInit();
    _subscription = _events.stream.listen((_) {
      if (_showingDialog) return;
      _showingDialog = true;
      unawaited(
        AppNotifier.showProfileNotVerifiedDialog().whenComplete(() {
          _showingDialog = false;
        }),
      );
    });
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    super.onClose();
  }
}
