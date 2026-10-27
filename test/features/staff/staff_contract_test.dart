import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/auth/data/dto/auth_user_dto.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('agent capabilities fixture parses all nine known capabilities', () {
    final user = AuthUserDto.fromJson(fixture('me_agent_caps.json'));
    expect(user.agent?.capabilities.length, 9);
    expect(user.can(AgentCapability.stockValidation), isTrue);
  });

  test('staff inbox and messages use paginated staff DTOs', () {
    final conversations = Paginated<StaffConversation>.fromJson(
      fixture('staff_conversations_page.json'),
      StaffConversation.fromJson,
    );
    final messages = Paginated<StaffMessage>.fromJson(
      fixture('staff_messages_page.json'),
      StaffMessage.fromJson,
    );
    expect(conversations.items.single.customer['firstname'], 'Awa');
    expect(conversations.items.single.type, 'BUYER_SUPPORT');
    expect(messages.items.last.isInternal, isTrue);
  });

  test('staff lot and listing include staff-only context', () {
    final lot = StaffLot.fromJson(fixture('staff_lot.json'));
    final listing = StaffListing.fromJson(fixture('staff_listing.json'));
    expect(lot.supplier['profileVerificationStatus'], 'VERIFIED');
    expect(lot.qualityGrade, 'A');
    expect(listing.reference, 'ANN-000051');
    expect(listing.images, hasLength(1));
  });
}
