import 'package:flutter/material.dart';
import 'package:waqf_insight/app.dart';
import 'package:waqf_insight/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initDependencies();

  runApp(const App());
}
