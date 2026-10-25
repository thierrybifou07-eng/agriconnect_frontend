import 'package:get/get.dart';

import 'package:agri_connect/core/localization/locale_controller.dart';
import 'package:agri_connect/core/network/api_client.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/realtime/socket_service.dart';
import 'package:agri_connect/core/storage/prefs_storage.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/auth/data/auth_api.dart';
import 'package:agri_connect/features/auth/data/auth_repository_impl.dart';
import 'package:agri_connect/features/auth/domain/auth_repository.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    final prefsStorage = PrefsStorage();
    final tokenStorage = SecureTokenStorage();
    final sessionEvents = SessionEvents();

    Get.put<PrefsStorage>(prefsStorage, permanent: true);
    Get.put<TokenStorage>(tokenStorage, permanent: true);
    Get.put<SessionEvents>(sessionEvents, permanent: true);
    Get.put<ApiClient>(
      ApiClient(tokenStorage: tokenStorage, sessionEvents: sessionEvents),
      permanent: true,
    );
    final authRepository = AuthRepositoryImpl(AuthApi(Get.find<ApiClient>()));
    Get.put<AuthRepository>(authRepository);
    Get.put<AuthController>(
      AuthController(
        tokenStorage: tokenStorage,
        sessionEvents: sessionEvents,
        repository: authRepository,
      ),
      permanent: true,
    );
    Get.put<SocketService>(SocketService(), permanent: true);
    Get.put<LocaleController>(LocaleController(prefsStorage), permanent: true);
  }
}
