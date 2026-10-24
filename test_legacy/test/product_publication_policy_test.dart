import 'package:flutter_test/flutter_test.dart';

import 'package:agri_connect/features/supplier/domain/product.dart';

void main() {
  group('product publication policy', () {
    test('approval alone does not publish a product', () {
      const product = Product(
        id: 'p1',
        name: 'Tomates',
        price: 1200,
        stockQuantity: 10,
        unit: 'kg',
        declaration: DeclarationStatus.approvedForPublication,
      );

      expect(product.declaration.isApprovedForPublication, isTrue);
      expect(product.publicationStatus, ProductPublicationStatus.unpublished);
      expect(product.isPublished, isFalse);
    });

    test('only an approved product explicitly marked published is public', () {
      for (final declaration in DeclarationStatus.values) {
        final product = Product(
          id: 'p1',
          name: 'Tomates',
          price: 1200,
          stockQuantity: 10,
          unit: 'kg',
          declaration: declaration,
          publicationStatus: ProductPublicationStatus.published,
        );

        expect(
          product.isPublished,
          declaration == DeclarationStatus.approvedForPublication,
          reason: 'publication state with declaration $declaration',
        );
      }
    });

    test('only published products are public when approved', () {
      for (final publicationStatus in ProductPublicationStatus.values) {
        final product = Product(
          id: 'p1',
          name: 'Tomates',
          price: 1200,
          stockQuantity: 10,
          unit: 'kg',
          declaration: DeclarationStatus.approvedForPublication,
          publicationStatus: publicationStatus,
        );

        expect(
          product.isPublished,
          publicationStatus == ProductPublicationStatus.published,
          reason: 'publication status $publicationStatus',
        );
      }
    });

    test('rejected declarations cannot be published', () {
      final product = Product(
        id: 'p1',
        name: 'Tomates',
        price: 1200,
        stockQuantity: 10,
        unit: 'kg',
        declaration: DeclarationStatus.rejected,
        publicationStatus: ProductPublicationStatus.published,
      );

      expect(product.declaration.isApprovedForPublication, isFalse);
      expect(product.isPublished, isFalse);
    });
  });
}
