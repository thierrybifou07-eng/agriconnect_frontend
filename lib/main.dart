import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/config/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // A misconfigured API_BASE_URL would send every call to a 404: fail fast
  // in debug builds instead of letting each screen show a vague error.
  assert(() {
    final problem = Env.validate(Env.apiBaseUrl);
    if (problem != null) throw StateError(problem);
    return true;
  }());
  runApp(const ProviderScope(child: AgriConnectApp()));
}
