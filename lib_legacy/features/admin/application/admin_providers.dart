import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/features/admin/data/demo_admin_repository.dart';
import 'package:agri_connect/features/admin/domain/admin_repository.dart';

/// Entry point of the admin data layer; overridden by tests.
///
/// Not `const`: the demo repository holds the mutable state its operations
/// write to, so a new container must get its own instance.
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => DemoAdminRepository(),
);
