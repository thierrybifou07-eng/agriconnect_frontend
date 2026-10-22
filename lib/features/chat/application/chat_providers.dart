import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/auth/application/auth_controller.dart';
import 'package:agri_connect/features/chat/data/demo_chat_repository.dart';
import 'package:agri_connect/features/chat/domain/chat_repository.dart';

/// Entry point of the chat data layer; overridden by tests.
///
/// The inbox is derived from the signed-in user, so the repository is rebuilt
/// whenever the session identity changes.
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => DemoChatRepository(
    currentUser: ref.watch(authControllerProvider.select((s) => s.user))!,
  ),
);
