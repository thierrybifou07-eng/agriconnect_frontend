import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/supplier/data/demo_supplier_repository.dart';
import 'package:agri_connect/features/supplier/domain/supplier_repository.dart';

/// Entry point of the supplier data layer; overridden by tests.
final supplierRepositoryProvider = Provider<SupplierRepository>(
  (ref) => DemoSupplierRepository(),
);
