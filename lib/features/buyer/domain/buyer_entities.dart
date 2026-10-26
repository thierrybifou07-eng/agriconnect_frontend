import 'package:agri_connect/shared/domain/order_status.dart';

class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.code,
    required this.label,
  });

  final int id;
  final String code;
  final String label;
}

class ListingReference {
  const ListingReference({required this.code, required this.label});

  final String code;
  final String label;
}

class ListingZone {
  const ListingZone({required this.id, required this.name, required this.city});

  final int id;
  final String name;
  final String city;
}

class CatalogListing {
  const CatalogListing({
    required this.id,
    required this.reference,
    required this.title,
    required this.category,
    required this.unit,
    required this.unitPrice,
    required this.quantityAvailable,
    required this.zone,
    required this.images,
    this.description,
    this.expiresAt,
    this.qualityGrade,
  });

  final int id;
  final String reference;
  final String title;
  final String? description;
  final ListingReference category;
  final ListingReference unit;
  final double unitPrice;
  final double quantityAvailable;
  final DateTime? expiresAt;
  final ListingZone zone;
  final List<String> images;
  final String? qualityGrade;
}

class BuyerOrderItem {
  const BuyerOrderItem({
    required this.id,
    required this.listingId,
    required this.listingReference,
    required this.listingTitle,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int id;
  final int listingId;
  final String listingReference;
  final String listingTitle;
  final double quantity;
  final double unitPrice;
  final double lineTotal;
}

class BuyerDelivery {
  const BuyerDelivery({
    required this.zoneId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final int zoneId;
  final String address;
  final double latitude;
  final double longitude;
}

class BuyerPickup {
  const BuyerPickup({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
  });

  final int id;
  final String name;
  final String address;
  final String city;
}

class BuyerOrder {
  const BuyerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.deliveryMode,
    required this.items,
    required this.subtotal,
    required this.buyerFee,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    this.delivery,
    this.pickup,
    this.notes,
    this.reservedUntil,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  final int id;
  final String orderNumber;
  final OrderStatus status;
  final String? deliveryMode;
  final List<BuyerOrderItem> items;
  final double subtotal;
  final double buyerFee;
  final double deliveryFee;
  final double total;
  final BuyerDelivery? delivery;
  final BuyerPickup? pickup;
  final String? notes;
  final DateTime? reservedUntil;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
}
