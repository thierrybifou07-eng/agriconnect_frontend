import 'package:agri_connect/features/buyer/domain/buyer_entities.dart';
import 'package:agri_connect/shared/domain/order_status.dart';

class CatalogCategoryDto extends CatalogCategory {
  const CatalogCategoryDto({
    required super.id,
    required super.code,
    required super.label,
  });

  factory CatalogCategoryDto.fromJson(Object? json) {
    final map = _object(json, 'catalog category');
    return CatalogCategoryDto(
      id: _integer(map['id'], 'category.id'),
      code: _string(map['code'], 'category.code'),
      label: _string(map['label'], 'category.label'),
    );
  }
}

class CatalogListingDto extends CatalogListing {
  const CatalogListingDto({
    required super.id,
    required super.reference,
    required super.title,
    required super.category,
    required super.unit,
    required super.unitPrice,
    required super.quantityAvailable,
    required super.zone,
    required super.images,
    super.description,
    super.expiresAt,
    super.qualityGrade,
  });

  factory CatalogListingDto.fromJson(Object? json) {
    final map = _object(json, 'catalog listing');
    final category = _object(map['category'], 'listing category');
    final unit = _object(map['unit'], 'listing unit');
    final zone = _object(map['zone'], 'listing zone');
    final rawImages = map['images'];
    if (rawImages is! List || rawImages.any((item) => item is! String)) {
      throw const FormatException('Expected listing images to be strings');
    }
    return CatalogListingDto(
      id: _integer(map['id'], 'listing.id'),
      reference: _string(map['reference'], 'listing.reference'),
      title: _string(map['title'], 'listing.title'),
      description: _nullableString(map['description']),
      category: ListingReference(
        code: _string(category['code'], 'category.code'),
        label: _string(category['label'], 'category.label'),
      ),
      unit: ListingReference(
        code: _string(unit['code'], 'unit.code'),
        label: _string(unit['label'], 'unit.label'),
      ),
      unitPrice: _double(map['unitPrice'], 'listing.unitPrice'),
      quantityAvailable: _double(
        map['quantityAvailable'],
        'listing.quantityAvailable',
      ),
      expiresAt: _date(map['expiresAt'], 'listing.expiresAt'),
      zone: ListingZone(
        id: _integer(zone['id'], 'zone.id'),
        name: _string(zone['name'], 'zone.name'),
        city: _string(zone['city'], 'zone.city'),
      ),
      images: List<String>.unmodifiable(rawImages.cast<String>()),
      qualityGrade: _nullableString(map['qualityGrade']),
    );
  }
}

class BuyerOrderDto extends BuyerOrder {
  const BuyerOrderDto({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.deliveryMode,
    required super.items,
    required super.subtotal,
    required super.buyerFee,
    required super.deliveryFee,
    required super.total,
    required super.createdAt,
    super.delivery,
    super.pickup,
    super.notes,
    super.reservedUntil,
    super.confirmedAt,
    super.completedAt,
    super.cancelledAt,
    super.cancellationReason,
  });

  factory BuyerOrderDto.fromJson(Object? json) {
    final map = _object(json, 'buyer order');
    final rawItems = map['items'];
    if (rawItems is! List) {
      throw const FormatException('Buyer order is missing items');
    }
    return BuyerOrderDto(
      id: _integer(map['id'], 'order.id'),
      orderNumber: _string(map['orderNumber'], 'order.orderNumber'),
      status: _orderStatus(map['status']),
      deliveryMode: _nullableString(map['deliveryMode']),
      items: List<BuyerOrderItem>.unmodifiable(rawItems.map(_buyerOrderItem)),
      subtotal: _double(map['subtotal'], 'order.subtotal'),
      buyerFee: _double(map['buyerFee'], 'order.buyerFee'),
      deliveryFee: _double(map['deliveryFee'], 'order.deliveryFee'),
      total: _double(map['total'], 'order.total'),
      delivery: _nullableObject(
        map['delivery'],
        'order.delivery',
        _buyerDelivery,
      ),
      pickup: _nullableObject(map['pickup'], 'order.pickup', _buyerPickup),
      notes: _nullableString(map['notes']),
      reservedUntil: _date(map['reservedUntil'], 'order.reservedUntil'),
      confirmedAt: _date(map['confirmedAt'], 'order.confirmedAt'),
      completedAt: _date(map['completedAt'], 'order.completedAt'),
      cancelledAt: _date(map['cancelledAt'], 'order.cancelledAt'),
      cancellationReason: _nullableString(map['cancellationReason']),
      createdAt: _requiredDate(map['createdAt'], 'order.createdAt'),
    );
  }
}

BuyerOrderItem _buyerOrderItem(Object? json) {
  final map = _object(json, 'buyer order item');
  return BuyerOrderItem(
    id: _integer(map['id'], 'item.id'),
    listingId: _integer(map['listingId'], 'item.listingId'),
    listingReference: _string(map['listingReference'], 'item.listingReference'),
    listingTitle: _string(map['listingTitle'], 'item.listingTitle'),
    quantity: _double(map['quantity'], 'item.quantity'),
    unitPrice: _double(map['unitPrice'], 'item.unitPrice'),
    lineTotal: _double(map['lineTotal'], 'item.lineTotal'),
  );
}

BuyerDelivery _buyerDelivery(Object? json) {
  final map = _object(json, 'delivery');
  return BuyerDelivery(
    zoneId: _integer(map['zoneId'], 'delivery.zoneId'),
    address: _string(map['address'], 'delivery.address'),
    latitude: _double(map['latitude'], 'delivery.latitude'),
    longitude: _double(map['longitude'], 'delivery.longitude'),
  );
}

BuyerPickup _buyerPickup(Object? json) {
  final map = _object(json, 'pickup');
  return BuyerPickup(
    id: _integer(map['id'], 'pickup.id'),
    name: _string(map['name'], 'pickup.name'),
    address: _string(map['address'], 'pickup.address'),
    city: _string(map['city'], 'pickup.city'),
  );
}

T? _nullableObject<T>(Object? value, String field, T Function(Object?) parse) =>
    value == null ? null : parse(value);

OrderStatus _orderStatus(Object? value) {
  if (value is! String) {
    throw const FormatException('Expected order status string');
  }
  return OrderStatus.fromApi(value);
}

DateTime? _date(Object? value, String field) {
  if (value == null) return null;
  if (value is! String) throw FormatException('Expected $field string');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('Invalid $field');
  return parsed.toUtc();
}

DateTime _requiredDate(Object? value, String field) =>
    _date(value, field) ?? (throw FormatException('Missing $field'));

Map<Object?, Object?> _object(Object? value, String field) {
  if (value is Map) return value;
  throw FormatException('Expected $field object');
}

String _string(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Expected $field string');
}

String? _nullableString(Object? value) =>
    value == null ? null : _string(value, 'nullable field');

int _integer(Object? value, String field) {
  if (value is int) return value;
  if (value is num && value == value.toInt()) return value.toInt();
  throw FormatException('Expected $field integer');
}

double _double(Object? value, String field) {
  if (value is num) return value.toDouble();
  throw FormatException('Expected $field number');
}
