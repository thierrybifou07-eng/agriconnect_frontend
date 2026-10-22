import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/driver/data/demo_driver_repository.dart';
import 'package:agri_connect/features/driver/domain/driver_repository.dart';

/// Entry point of the driver data layer; overridden by tests.
final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DemoDriverRepository(),
);
