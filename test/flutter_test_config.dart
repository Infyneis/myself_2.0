import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom HTTP overrides to allow Google Fonts to work in tests.
/// This prevents the HttpClient from being blocked by TestWidgetsFlutterBinding.
class _TestHttpOverrides extends HttpOverrides {}

/// Configuration for all Flutter tests.
/// This file is automatically loaded by the test framework.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up HTTP overrides to allow Google Fonts to fetch fonts.
  HttpOverrides.global = _TestHttpOverrides();

  // Allow runtime fetching of Google Fonts.
  GoogleFonts.config.allowRuntimeFetching = true;

  await testMain();
}
