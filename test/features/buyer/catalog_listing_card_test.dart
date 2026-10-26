import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/core/localization/generated/app_localizations.dart';
import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/features/buyer/presentation/widgets/catalog_listing_card.dart';

void main() {
  testWidgets('listing card shows buyer fields without supplier identity', (
    tester,
  ) async {
    const listing = CatalogListing(
      id: 1,
      reference: 'ANN-1',
      title: 'Riz local',
      description: 'Riz récolté localement.',
      category: ListingReference(code: 'CEREALS', label: 'Céréales'),
      unit: ListingReference(code: 'KG', label: 'kg'),
      unitPrice: 1500,
      quantityAvailable: 100,
      zone: ListingZone(id: 1, name: 'Centre', city: 'Yaoundé'),
      images: [],
      qualityGrade: null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CatalogListingCard(listing: listing, onTap: _noop),
        ),
      ),
    );

    expect(find.text('Riz local'), findsOneWidget);
    expect(find.textContaining('1 500 FCFA'), findsOneWidget);
    expect(find.textContaining('Centre, Yaoundé'), findsOneWidget);
    expect(find.textContaining('fournisseur'), findsNothing);
    expect(find.textContaining('supplier'), findsNothing);
  });
}

void _noop() {}
