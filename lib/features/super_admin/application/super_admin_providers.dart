import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/super_admin/data/demo_super_admin_repository.dart';
import 'package:agri_connect/features/super_admin/domain/super_admin_repository.dart';

/// Entry point of the Super Admin data layer; overridden by tests.
final superAdminRepositoryProvider = Provider<SuperAdminRepository>(
  (ref) => DemoSuperAdminRepository(),
);
