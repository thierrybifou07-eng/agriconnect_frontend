import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/chat/data/dto/chat_dto.dart';
import 'package:agri_connect/features/chat/domain/chat_entities.dart';

void main() {
  test('conversation page DTO matches the client API contract', () {
    final json = jsonDecode(
      File('test/fixtures/api/conversations_page.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final page = Paginated<Conversation>.fromJson(json, ChatDto.conversation);

    expect(page.total, 2);
    expect(page.items.first.type, ConversationType.buyerSupport);
    expect(page.items.last.status, ConversationStatus.waitingCustomer);
    expect(page.items.first.listingId, 17);
  });

  test('messages page DTO exposes only the customer-safe sender label', () {
    final json = jsonDecode(
      File('test/fixtures/api/messages_page.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final page = Paginated<ChatMessage>.fromJson(json, ChatDto.message);

    expect(page.items.first.isMine, isTrue);
    expect(page.items.last.senderLabel, 'Équipe AgriConnect');
    expect(page.items.last.isAi, isFalse);
  });
}
