import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/network/api_failure.dart';
import 'package:agri_connect/features/reference/domain/reference_entities.dart';
import 'package:agri_connect/features/reference/domain/reference_repository.dart';
import 'package:agri_connect/features/staff/domain/staff_entities.dart';
import 'package:agri_connect/features/staff/domain/staff_workflow_entities.dart';
import 'package:agri_connect/features/staff/presentation/controllers/staff_workflow_controllers.dart';

class QuoteLineDraft {
  final Rxn<StaffListing> listing = Rxn<StaffListing>();
  final quantity = TextEditingController(text: '1');
  final unitPrice = TextEditingController();

  void dispose() {
    quantity.dispose();
    unitPrice.dispose();
  }
}

class StaffQuoteController extends GetxController {
  StaffQuoteController({
    required this.buyerId,
    required this.conversationId,
    required this.ordersController,
    required this.referenceRepository,
  });

  final int buyerId;
  final int? conversationId;
  final StaffOrdersController ordersController;
  final ReferenceRepository referenceRepository;

  final RxList<QuoteLineDraft> lines = <QuoteLineDraft>[].obs;
  final RxString deliveryMode = 'HUB_PICKUP'.obs;
  final Rxn<RefHub> pickupHub = Rxn<RefHub>();
  final Rxn<RefZone> zone = Rxn<RefZone>();
  final address = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();
  final notes = TextEditingController();
  final Rxn<ApiFailure> validationFailure = Rxn<ApiFailure>();
  final RxInt formVersion = 0.obs;

  double priceFloor(StaffListing listing) => math.max(
    listing.unitPrice,
    listing.lot?.lot.agreedUnitPrice ?? 0.0,
  );

  bool get isValid {
    if (lines.isEmpty) return false;
    for (final line in lines) {
      final listing = line.listing.value;
      final quantityValue = double.tryParse(line.quantity.text);
      final priceValue = double.tryParse(line.unitPrice.text);
      if (listing == null || quantityValue == null || quantityValue <= 0) {
        return false;
      }
      if (priceValue != null &&
          (priceValue <= 0 ||
              priceValue < priceFloor(listing))) {
        return false;
      }
    }
    if (notes.text.length > 1000) return false;
    if (deliveryMode.value == 'HUB_PICKUP') return pickupHub.value != null;
    final latitudeValue = double.tryParse(latitude.text);
    final longitudeValue = double.tryParse(longitude.text);
    return zone.value != null &&
        address.text.trim().length >= 3 &&
        latitudeValue != null &&
        latitudeValue >= -90 &&
        latitudeValue <= 90 &&
        longitudeValue != null &&
        longitudeValue >= -180 &&
        longitudeValue <= 180;
  }

  @override
  void onInit() {
    super.onInit();
    lines.add(QuoteLineDraft());
    ordersController.loadActiveListings();
  }

  void addLine() => lines.add(QuoteLineDraft());

  void removeLine(QuoteLineDraft line) {
    if (lines.length <= 1) return;
    lines.remove(line);
    line.dispose();
  }

  void refreshForm() => formVersion.value++;

  Map<String, Object?>? buildBody() {
    if (!isValid) return null;
    final items = <Map<String, Object?>>[];
    for (final line in lines) {
      final listing = line.listing.value!;
      final price = double.tryParse(line.unitPrice.text);
      if (price != null && price < priceFloor(listing)) {
        validationFailure.value = const ApiFailure(
          status: 409,
          code: 'PRICE_BELOW_SUPPLIER',
          message: 'PRICE_BELOW_SUPPLIER',
          fieldErrors: {},
          kind: ApiFailureKind.client,
        );
        return null;
      }
      items.add({
        'listingId': listing.id,
        'quantity': double.parse(line.quantity.text),
        'unitPrice': ?price,
      });
    }
    final delivery = deliveryMode.value == 'HUB_PICKUP'
        ? {'pickupHubId': pickupHub.value!.id}
        : {
            'delivery': {
              'zoneId': zone.value!.id,
              'address': address.text.trim(),
              'latitude': double.parse(latitude.text),
              'longitude': double.parse(longitude.text),
            },
          };
    return {
      'buyerId': buyerId,
      'conversationId': ?conversationId,
      'items': items,
      'deliveryMode': deliveryMode.value,
      ...delivery,
      if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
    };
  }

  Future<StaffOrder?> submit(String Function(StaffOrder) quoteMessage) async {
    final body = buildBody();
    if (body == null) return null;
    return ordersController.createQuote(body, quoteMessage: quoteMessage);
  }

  @override
  void onClose() {
    for (final line in lines) {
      line.dispose();
    }
    address.dispose();
    latitude.dispose();
    longitude.dispose();
    notes.dispose();
    super.onClose();
  }
}
