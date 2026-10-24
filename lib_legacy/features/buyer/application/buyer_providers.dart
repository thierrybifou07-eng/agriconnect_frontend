import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/buyer/data/demo_buyer_repository.dart';
import 'package:agri_connect/features/buyer/domain/buyer_repository.dart';

/// Entry point of the buyer data layer; overridden by tests.
final buyerRepositoryProvider = Provider<BuyerRepository>(
  (ref) => DemoBuyerRepository(),
);
