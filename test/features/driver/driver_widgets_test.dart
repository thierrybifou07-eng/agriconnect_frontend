import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/presentation/pages/driver_page.dart';
import 'package:agri_connect/shared/domain/delivery_status.dart';

import '../../support/get_test_harness.dart';

void main() {
  setupGetTestHarness();

  testWidgets('delivery card never presents a monetary value', (tester) async {
    final delivery = DriverDelivery(
      id: 37,
      status: DeliveryStatus.pending,
      pickupAddress: 'Marché central',
      pickupLatitude: 3.8667,
      pickupLongitude: 11.5167,
      dropoffAddress: 'Quartier Bastos',
      dropoffLatitude: 3.8892,
      dropoffLongitude: 11.5174,
      distanceKm: 4.8,
      items: const [
        DriverDeliveryItem(
          productName: 'Riz local',
          categoryName: 'Céréales',
          quantity: 12.5,
        ),
      ],
    );
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DeliveryCard(delivery: delivery)),
      ),
    );

    expect(find.textContaining('Marché central'), findsOneWidget);
    expect(find.textContaining('Riz local'), findsOneWidget);
    expect(find.textContaining('XAF'), findsNothing);
    expect(find.textContaining('FCFA'), findsNothing);
    expect(find.textContaining('€'), findsNothing);
  });
}
