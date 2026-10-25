import 'package:flutter/material.dart';

import 'package:agri_connect/app/app.dart';
import 'package:agri_connect/core/utils/dates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Dates.initialize();
  runApp(const AgriConnectApp());
}
