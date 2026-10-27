import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_connect/core/network/paginated.dart';
import 'package:agri_connect/features/auth/data/dto/auth_user_dto.dart';
import 'package:agri_connect/features/auth/domain/agent_capability.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name').readAsStringSync());

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

  test(
    'staff order contract retains staff-only pricing and origin details',
    () {
      final order = StaffOrder.fromJson(fixture('staff_order.json'));
      expect(order.items.single.lotId, 18);
      expect(order.items.single.supplierUnitPrice, 1000);
      expect(order.items.single.commissionAmount, 350);
      expect(order.items.single.supplierNetAmount, 3150);
      expect(order.origins, hasLength(1));
      expect(order.buyer['id'], 12);
      expect(order.paymentStatus, 'UNPAID');
      expect(order.conversationId, 44);
      expect(order.reservedUntil, DateTime.utc(2026, 10, 28, 10));
    },
  );

  test('payments and staff delivery contracts parse server amounts', () {
    final payments = fixture('payments_list.json') as List;
    final payment = StaffPayment.fromJson(payments.single);
    final deliveryPage = Paginated<StaffDelivery>.fromJson(
      fixture('staff_delivery.json'),
      StaffDelivery.fromJson,
    );
    expect(payment.amount, 1200);
    expect(payment.method, 'MOBILE_MONEY');
    expect(deliveryPage.items.single.agencyCost, 900);
    expect(deliveryPage.items.single.insuredValue, 3500);
  });

  test('verification detail includes a short-lived URL only in detail DTO', () {
    final detail = StaffVerificationDetail.fromJson(
      fixture('verification_detail.json'),
    );
    final queueItem = StaffVerification.fromJson({
      'id': 5,
      'type': 'ID_CARD',
      'status': 'PENDING',
      'user': {
        'id': 12,
        'role': 'BUYER',
        'profileVerificationStatus': 'PENDING',
      },
      'media': {'mimeType': 'image/jpeg', 'fileSize': 245120},
    });
    expect(detail.signedUrl, contains('temporary-signed-token'));
    expect(detail.mimeType, 'image/jpeg');
    expect(queueItem.fileSize, 245120);
  });
}
