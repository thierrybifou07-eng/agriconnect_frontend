import 'package:agri_connect/core/errors/failures.dart';
import 'package:agri_connect/features/supplier/domain/supplier_order.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';
import 'package:agri_connect/features/supplier/domain/product.dart';

/// In-memory repository backing the supplier workspace demo.
///
/// Swapping this class for a real remote implementation must be the only
/// change required to go live (see [SupplierRepository]).
///
/// DEMO ONLY: these declarations live in an in-memory list scoped to the app
/// process. They are never read by the buyer catalog, and the [DeclarationStatus]
/// values carried here are sample data, not the result of any real review.
final class DemoSupplierRepository implements SupplierRepository {
  DemoSupplierRepository();

  final List<Product> _products = [
    Product(
      id: 'p_1001',
      name: 'Tomates fraîches',
      description: 'Tomates de saison, cueillies à maturité.',
      price: 1200,
      stockQuantity: 150,
      unit: 'kg',
      imageUrl: 'assets/images/products/tomates.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      declaration: DeclarationStatus.approvedForPublication,
    ),
    Product(
      id: 'p_1002',
      name: 'Oignons rouges',
      description: 'Oignons rouges doux, sac de 25 kg.',
      price: 800,
      stockQuantity: 320,
      unit: 'sac',
      imageUrl: 'assets/images/products/oignons.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      declaration: DeclarationStatus.approvedForPublication,
    ),
    Product(
      id: 'p_1003',
      name: 'Manioc',
      description: 'Manioc frais, morceaux épluchés.',
      price: 500,
      stockQuantity: 0,
      unit: 'kg',
      imageUrl: 'assets/images/products/manioc.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      declaration: DeclarationStatus.draft,
    ),
    Product(
      id: 'p_1004',
      name: 'Arachides coques',
      description: 'Arachides grillées au soleil.',
      price: 900,
      stockQuantity: 210,
      unit: 'sac',
      imageUrl: 'assets/images/products/arachides.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      declaration: DeclarationStatus.pendingReview,
    ),
    Product(
      id: 'p_1005',
      name: 'Piments verts',
      description: 'Piments verts très parfumés.',
      price: 1500,
      stockQuantity: 45,
      unit: 'kg',
      imageUrl: 'assets/images/products/piment.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      declaration: DeclarationStatus.approvedForPublication,
    ),
    Product(
      id: 'p_1006',
      name: 'Tomates cerises',
      description: 'Petites tomates cerises sucrées, idéales en salade.',
      price: 1500,
      stockQuantity: 90,
      unit: 'kg',
      imageUrl: 'assets/images/products/tomates.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      declaration: DeclarationStatus.additionalInfoRequired,
    ),
    Product(
      id: 'p_1007',
      name: 'Maïs bio',
      description: 'Maïs bio cultivé sans pesticides, récolte fraîche.',
      price: 700,
      stockQuantity: 180,
      unit: 'kg',
      imageUrl: 'assets/images/products/mais.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      declaration: DeclarationStatus.underDiscussion,
    ),
    Product(
      id: 'p_1008',
      name: 'Bananes plantain',
      description: 'Bananes plantain prêtes à cuisiner.',
      price: 650,
      stockQuantity: 100,
      unit: 'kg',
      imageUrl: 'assets/images/products/ananas.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      declaration: DeclarationStatus.approvedForPublication,
    ),
    Product(
      id: 'p_1009',
      name: 'Mangues locales',
      description: 'Mangues juteuses de saison, cueillies à maturité.',
      price: 1000,
      stockQuantity: 0,
      unit: 'kg',
      imageUrl: 'assets/images/products/ananas.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      declaration: DeclarationStatus.draft,
    ),
    Product(
      id: 'p_1010',
      name: 'Patates douces',
      description: 'Patates douces à chair jaune, riches en saveur.',
      price: 600,
      stockQuantity: 140,
      unit: 'kg',
      imageUrl: 'assets/images/products/manioc.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      declaration: DeclarationStatus.pendingReview,
    ),
  ];

  final List<SupplierOrder> _orders = [
    SupplierOrder(
      id: 'c_2001',
      buyerName: 'Aminata Diarra',
      buyerEmail: 'aminata.diarra@example.com',
      buyerPhone: '+225 07 01 23 45 67',
      items: const [
        OrderItem(
          productId: 'p_1001',
          productName: 'Tomates fraîches',
          unitPrice: 1200,
          quantity: 10,
        ),
        OrderItem(
          productId: 'p_1004',
          productName: 'Arachides coques',
          unitPrice: 900,
          quantity: 4,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SupplierOrder(
      id: 'c_2002',
      buyerName: 'Fatoumata Keïta',
      buyerEmail: 'fatoumata.keita@example.com',
      items: const [
        OrderItem(
          productId: 'p_1002',
          productName: 'Oignons rouges',
          unitPrice: 800,
          quantity: 20,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
    ),
    SupplierOrder(
      id: 'c_2003',
      buyerName: 'Souleymane Bamba',
      buyerEmail: 'souleymane.bamba@example.com',
      items: const [
        OrderItem(
          productId: 'p_1005',
          productName: 'Piments verts',
          unitPrice: 1500,
          quantity: 8,
        ),
        OrderItem(
          productId: 'p_1002',
          productName: 'Oignons rouges',
          unitPrice: 800,
          quantity: 5,
        ),
      ],
      status: OrderStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    SupplierOrder(
      id: 'c_2004',
      buyerName: 'Kadiatou Sow',
      buyerEmail: 'kadiatou.sow@example.com',
      items: const [
        OrderItem(
          productId: 'p_1003',
          productName: 'Manioc',
          unitPrice: 500,
          quantity: 30,
        ),
      ],
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    SupplierOrder(
      id: 'c_2005',
      buyerName: 'Awa Cissé',
      buyerEmail: 'awa.cisse@example.com',
      buyerPhone: '+225 07 10 98 76 54',
      items: const [
        OrderItem(
          productId: 'p_1001',
          productName: 'Tomates fraîches',
          unitPrice: 1200,
          quantity: 6,
        ),
        OrderItem(
          productId: 'p_1007',
          productName: 'Maïs bio',
          unitPrice: 700,
          quantity: 2,
        ),
      ],
      status: OrderStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
    ),
    SupplierOrder(
      id: 'c_2006',
      buyerName: 'Moussa Traoré',
      buyerEmail: 'moussa.traore@example.com',
      buyerPhone: '+225 07 21 43 65 87',
      items: const [
        OrderItem(
          productId: 'p_1005',
          productName: 'Piments verts',
          unitPrice: 1500,
          quantity: 12,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  @override
  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<Product>.unmodifiable(_products);
  }

  @override
  Future<Product> saveProduct({
    String? productId,
    required ProductDraft draft,
    required DeclarationStatus declaration,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (productId != null) {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index < 0) throw const ServerFailure('product_not_found');
      _products[index] = Product(
        id: productId,
        name: draft.name,
        description: draft.description,
        price: draft.price,
        stockQuantity: draft.stockQuantity,
        unit: draft.unit,
        photos: draft.photos,
        imageUrl: draft.imageUrl ?? _products[index].imageUrl,
        createdAt: _products[index].createdAt,
        declaration: declaration,
      );
      return _products[index];
    }
    final now = DateTime.now();
    final product = Product(
      id: 'p_${now.millisecondsSinceEpoch}',
      name: draft.name,
      description: draft.description,
      price: draft.price,
      stockQuantity: draft.stockQuantity,
      unit: draft.unit,
      photos: draft.photos,
      imageUrl: draft.imageUrl,
      createdAt: now,
      declaration: declaration,
    );
    _products.insert(0, product);
    return product;
  }

  @override
  Future<List<SupplierOrder>> fetchOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<SupplierOrder>.unmodifiable(_orders);
  }

  @override
  Future<SupplierOrder> confirmOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw const ServerFailure('order_not_found');
    final current = _orders[index];
    if (!current.isPending) return current;
    final updated = current.copyWith(status: OrderStatus.confirmed);
    _orders[index] = updated;
    return updated;
  }
}
