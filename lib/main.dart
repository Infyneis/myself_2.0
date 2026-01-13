/// Myself 2.0 - Personal Affirmation App
///
/// Transform through repetition and intention — see who you want to become,
/// become who you see.
///
/// This is the main entry point for the application.
library;

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/hive_service.dart';

/// Main entry point for Myself 2.0.
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await HiveService.initialize();

  // TODO: Initialize providers (INFRA-004)

  runApp(const MyselfApp());
}
