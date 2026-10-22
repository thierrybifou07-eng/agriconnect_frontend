import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/driver/domain/driver_delivery.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';
import 'package:agri_connect/features/driver/domain/driver_trip.dart';

/// In-memory repository backing the driver workspace demo for "Ibrahim Cissé".
///
/// Swapping this class for a real remote implementation must be the only
/// change required to go live (see [DriverRepository]).
final class DemoDriverRepository implements DriverRepository {
  DemoDriverRepository();

  final List<DriverDelivery> _deliveries = [
    DriverDelivery(
      id: 'del_7001',
      orderId: 'b_4006',
      customerName: 'Marie Koné',
      customerPhone: '+225 07 01 23 45 67',
      pickupLocation: 'Ferme de Bouaké, zone industrielle',
      deliveryAddress: 'Complexe sportif, Yopougon',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3011',
          productName: 'Mangues mûres',
          quantity: 6,
          unit: 'kg',
        ),
        DriverDeliveryItem(
          productId: 'p_3025',
          productName: 'Avocats',
          quantity: 4,
          unit: 'kg',
        ),
      ],
      status: DriverDeliveryStatus.inTransit,
      scheduledAt: DateTime.now().add(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      note: 'Demander le gardien à l\'entrée nord.',
    ),
    DriverDelivery(
      id: 'del_7002',
      orderId: 'b_4007',
      customerName: 'Aminata Diarra',
      customerPhone: '+225 07 05 43 21 09',
      pickupLocation: 'Marché de gros d\'Adjamé',
      deliveryAddress: 'Marché de Yopougon, allée 12',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3001',
          productName: 'Tomates fraîches',
          quantity: 10,
          unit: 'kg',
        ),
        DriverDeliveryItem(
          productId: 'p_3002',
          productName: 'Oignons rouges',
          quantity: 4,
          unit: 'sac',
        ),
      ],
      status: DriverDeliveryStatus.pickUp,
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    DriverDelivery(
      id: 'del_7003',
      orderId: 'b_4008',
      customerName: 'Fatoumata Keïta',
      customerPhone: '+225 07 08 32 10 76',
      pickupLocation: 'Entrepôt de Yamoussoukro',
      deliveryAddress: 'Marché de Cocody, stand 8',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3004',
          productName: 'Riz local',
          quantity: 20,
          unit: 'sac',
        ),
      ],
      status: DriverDeliveryStatus.pickUp,
      scheduledAt: DateTime.now().add(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
    ),
    DriverDelivery(
      id: 'del_7004',
      orderId: 'b_4009',
      customerName: 'Souleymane Bamba',
      customerPhone: '+225 07 14 56 78 32',
      pickupLocation: 'Marché de gros d\'Adjamé',
      deliveryAddress: 'Marché de Singrobo',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3003',
          productName: 'Manioc frais',
          quantity: 30,
          unit: 'kg',
        ),
      ],
      status: DriverDeliveryStatus.inTransit,
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    DriverDelivery(
      id: 'del_7005',
      orderId: 'b_4011',
      customerName: 'Kadiatou Sow',
      customerPhone: '+225 07 23 45 67 89',
      pickupLocation: 'Marché de gros d\'Adjamé',
      deliveryAddress: 'Restaurant Le Baobab, Plateau',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3005',
          productName: 'Ananas',
          quantity: 12,
          unit: 'pièce',
        ),
      ],
      status: DriverDeliveryStatus.delivered,
      scheduledAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DriverDelivery(
      id: 'del_7006',
      orderId: 'b_4012',
      customerName: 'Moussa Traoré',
      customerPhone: '+225 07 21 43 65 87',
      pickupLocation: 'Ferme de Bouaké, zone industrielle',
      deliveryAddress: 'Marché de Treichville',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3006',
          productName: 'Piment frais',
          quantity: 2,
          unit: 'kg',
        ),
        DriverDeliveryItem(
          productId: 'p_3008',
          productName: 'Maïs bio',
          quantity: 8,
          unit: 'kg',
        ),
      ],
      status: DriverDeliveryStatus.delivered,
      scheduledAt: DateTime.now().subtract(const Duration(days: 0, hours: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    ),
    DriverDelivery(
      id: 'del_7007',
      orderId: 'b_4013',
      customerName: 'Awa Cissé',
      customerPhone: '+225 07 10 98 76 54',
      pickupLocation: 'Marché de gros d\'Adjamé',
      deliveryAddress: 'Résidence Cocody Riviera',
      items: const [
        DriverDeliveryItem(
          productId: 'p_3007',
          productName: 'Tomates cerises',
          quantity: 6,
          unit: 'kg',
        ),
        DriverDeliveryItem(
          productId: 'p_3002',
          productName: 'Oignons rouges',
          quantity: 3,
          unit: 'sac',
        ),
      ],
      status: DriverDeliveryStatus.delivered,
      scheduledAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<DeliveryTrip> _trips = [
    DeliveryTrip(
      id: 'trp_8001',
      routeLabel: 'Adjamé → Yopougon',
      vehicleLabel: 'Fourgonnette · CD-456-EF',
      deliveryIds: const ['del_7001', 'del_7002', 'del_7004'],
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
    ),
    DeliveryTrip(
      id: 'trp_8002',
      routeLabel: 'Bouaké → Cocody',
      vehicleLabel: 'Fourgonnette · CD-456-EF',
      deliveryIds: const ['del_7001', 'del_7003'],
      scheduledAt: DateTime.now().add(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    DeliveryTrip(
      id: 'trp_8003',
      routeLabel: 'Adjamé → Plateau',
      vehicleLabel: 'Fourgonnette · CD-456-EF',
      deliveryIds: const ['del_7005'],
      scheduledAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<DriverDelivery>> fetchDeliveries() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<DriverDelivery>.unmodifiable(_deliveries);
  }

  @override
  Future<List<DeliveryTrip>> fetchTrips() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<DeliveryTrip>.unmodifiable(_trips);
  }

  @override
  Future<DriverDelivery> updateDeliveryStatus(
    String deliveryId,
    DriverDeliveryStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index < 0) throw const ServerFailure('delivery_not_found');
    final current = _deliveries[index];
    if (current.status == status) return current;
    final updated = current.copyWith(status: status);
    _deliveries[index] = updated;
    return updated;
  }
}
