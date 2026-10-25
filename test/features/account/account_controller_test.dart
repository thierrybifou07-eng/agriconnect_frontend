import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/core/network/session_events.dart';
import 'package:agri_connect/core/storage/token_storage.dart';
import 'package:agri_connect/features/account/presentation/controllers/sessions_controller.dart';
import 'package:agri_connect/features/account/presentation/controllers/verification_documents_controller.dart';
import 'package:agri_connect/features/auth/domain/auth_user.dart';
import 'package:agri_connect/features/auth/domain/role_code.dart';
import 'package:agri_connect/features/auth/presentation/controllers/auth_controller.dart';

import '../../support/get_test_harness.dart';
import '../auth/fake_auth_repository.dart';
import 'fake_account_repository.dart';

void main() {
  setupGetTestHarness();

  test(
    'verification upload rejects a file over 8 MB before API call',
    () async {
      final repository = FakeAccountRepository();
      final controller = VerificationDocumentsController(repository, _auth());

      final uploaded = await controller.upload(
        bytes: Uint8List(8 * 1024 * 1024 + 1),
        filename: 'proof.pdf',
        type: 'FARM_PROOF',
      );

      expect(uploaded, isFalse);
      expect(controller.uploadFailure.value?.code, 'FILE_TOO_LARGE');
      expect(repository.uploadDocumentCalls, 0);
    },
  );

  test('verification upload exposes the pending-document 409 code', () async {
    final repository = FakeAccountRepository()
      ..documentError = const ApiFailure(
        status: 409,
        code: 'TOO_MANY_PENDING_DOCUMENTS',
        message: 'Pending document limit reached',
        fieldErrors: {},
        kind: ApiFailureKind.client,
      );
    final controller = VerificationDocumentsController(repository, _auth());

    final uploaded = await controller.upload(
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      filename: 'proof.pdf',
      type: 'FARM_PROOF',
    );

    expect(uploaded, isFalse);
    expect(repository.uploadDocumentCalls, 1);
    expect(controller.uploadFailure.value?.code, 'TOO_MANY_PENDING_DOCUMENTS');
  });

  test(
    'logout other sessions preserves the current authenticated session',
    () async {
      final authRepository = FakeAuthRepository();
      final storage = InMemoryTokenStorage();
      await storage.save(access: 'access', refresh: 'refresh');
      final auth = _auth(repository: authRepository, storage: storage)
        ..setUser(
          const AuthUser(
            id: 1,
            email: 'user@example.test',
            role: RoleCode.supplier,
          ),
        );
      final controller = SessionsController(auth, authRepository);

      expect(await controller.logoutOtherSessions(), isTrue);

      expect(authRepository.logoutAllCalls, 1);
      expect(auth.currentUser?.role, RoleCode.supplier);
      expect((await storage.read())?.refresh, 'refresh');
    },
  );
}

AuthController _auth({FakeAuthRepository? repository, TokenStorage? storage}) =>
    AuthController(
      tokenStorage: storage ?? InMemoryTokenStorage(),
      sessionEvents: SessionEvents(),
      repository: repository ?? FakeAuthRepository(),
    );
