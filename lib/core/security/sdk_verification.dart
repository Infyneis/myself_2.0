/// SDK Verification for Privacy and Security
///
/// This file documents the verification of all third-party dependencies
/// to ensure no user data collection or tracking occurs.
///
/// Feature: SEC-004 - No Third-party Data SDKs
/// Requirement: NFR-012 - Verify no third-party SDKs that collect user data

library;

/// Complete list of third-party dependencies and their privacy assessment
/// Last verified: 2026-01-13
class SdkVerification {
  /// All dependencies from pubspec.yaml with privacy assessment
  static const Map<String, DependencyPrivacyInfo> dependencies = {
    // Core Flutter SDK - No data collection
    'flutter': DependencyPrivacyInfo(
      name: 'flutter',
      purpose: 'Flutter framework SDK',
      dataCollection: DataCollectionStatus.none,
      verification: 'Official Flutter SDK - no data collection',
      source: 'Google/Flutter team',
      isFirstParty: true,
    ),

    // Production Dependencies
    'cupertino_icons': DependencyPrivacyInfo(
      name: 'cupertino_icons',
      purpose: 'iOS-style icons for Flutter',
      dataCollection: DataCollectionStatus.none,
      verification: 'Asset package only - no runtime code or data collection',
      source: 'flutter.dev',
      isFirstParty: true,
    ),

    'provider': DependencyPrivacyInfo(
      name: 'provider',
      purpose: 'State management for Flutter',
      dataCollection: DataCollectionStatus.none,
      verification: 'Pure state management library - no network or analytics',
      source: 'Remi Rousselet (Flutter team)',
      isFirstParty: false,
    ),

    'hive': DependencyPrivacyInfo(
      name: 'hive',
      purpose: 'Local NoSQL database for Flutter',
      dataCollection: DataCollectionStatus.none,
      verification: 'Offline-only local storage - no network capabilities',
      source: 'Simon Leier',
      isFirstParty: false,
    ),

    'hive_flutter': DependencyPrivacyInfo(
      name: 'hive_flutter',
      purpose: 'Flutter integration for Hive database',
      dataCollection: DataCollectionStatus.none,
      verification: 'Extension of Hive for Flutter - offline only',
      source: 'Simon Leier',
      isFirstParty: false,
    ),

    'home_widget': DependencyPrivacyInfo(
      name: 'home_widget',
      purpose: 'Native home screen widget support',
      dataCollection: DataCollectionStatus.none,
      verification: 'Platform channel bridge only - no data collection',
      source: 'ABausG',
      isFirstParty: false,
    ),

    'uuid': DependencyPrivacyInfo(
      name: 'uuid',
      purpose: 'UUID generation for unique identifiers',
      dataCollection: DataCollectionStatus.none,
      verification: 'Pure UUID generation - no network or external services',
      source: 'Yulian Kuncheff',
      isFirstParty: false,
    ),

    'intl': DependencyPrivacyInfo(
      name: 'intl',
      purpose: 'Internationalization and localization',
      dataCollection: DataCollectionStatus.none,
      verification: 'Official Dart package - formatting only, no data collection',
      source: 'Dart team',
      isFirstParty: true,
    ),

    'google_fonts': DependencyPrivacyInfo(
      name: 'google_fonts',
      purpose: 'Google Fonts for typography',
      dataCollection: DataCollectionStatus.fontDownloadOnly,
      verification: 'Downloads fonts from Google Fonts API - uses caching, can work offline after first download',
      source: 'Flutter team',
      isFirstParty: true,
      notes: 'Font downloads are cached locally. No user data sent to Google.',
    ),

    'flutter_animate': DependencyPrivacyInfo(
      name: 'flutter_animate',
      purpose: 'Animation library for Flutter',
      dataCollection: DataCollectionStatus.none,
      verification: 'Pure animation library - no network or analytics',
      source: 'gskinner',
      isFirstParty: false,
    ),

    'path_provider': DependencyPrivacyInfo(
      name: 'path_provider',
      purpose: 'Access to platform-specific file system paths',
      dataCollection: DataCollectionStatus.none,
      verification: 'Official Flutter plugin - file system access only',
      source: 'Flutter team',
      isFirstParty: true,
    ),

    'flutter_secure_storage': DependencyPrivacyInfo(
      name: 'flutter_secure_storage',
      purpose: 'Secure local storage using platform keychain',
      dataCollection: DataCollectionStatus.none,
      verification: 'Platform keychain wrapper - all data stored locally',
      source: 'Mogol',
      isFirstParty: false,
    ),

    // Dev Dependencies
    'flutter_test': DependencyPrivacyInfo(
      name: 'flutter_test',
      purpose: 'Flutter testing framework',
      dataCollection: DataCollectionStatus.none,
      verification: 'Official Flutter testing SDK - dev only',
      source: 'Flutter team',
      isFirstParty: true,
    ),

    'flutter_lints': DependencyPrivacyInfo(
      name: 'flutter_lints',
      purpose: 'Linting rules for Flutter',
      dataCollection: DataCollectionStatus.none,
      verification: 'Static analysis only - dev dependency',
      source: 'Flutter team',
      isFirstParty: true,
    ),

    'hive_generator': DependencyPrivacyInfo(
      name: 'hive_generator',
      purpose: 'Code generation for Hive type adapters',
      dataCollection: DataCollectionStatus.none,
      verification: 'Build-time code generation only - dev dependency',
      source: 'Simon Leier',
      isFirstParty: false,
    ),

    'build_runner': DependencyPrivacyInfo(
      name: 'build_runner',
      purpose: 'Build system for code generation',
      dataCollection: DataCollectionStatus.none,
      verification: 'Official Dart build system - dev dependency',
      source: 'Dart team',
      isFirstParty: true,
    ),

    'mocktail': DependencyPrivacyInfo(
      name: 'mocktail',
      purpose: 'Mocking library for tests',
      dataCollection: DataCollectionStatus.none,
      verification: 'Testing library only - dev dependency',
      source: 'VGV',
      isFirstParty: false,
    ),
  };

  /// Verify all dependencies are privacy-compliant
  static VerificationResult verifyAllDependencies() {
    final issues = <String>[];
    final warnings = <String>[];

    for (final entry in dependencies.entries) {
      final dep = entry.value;

      // Check for data collection
      if (dep.dataCollection == DataCollectionStatus.collects) {
        issues.add('${dep.name}: Collects user data - ${dep.verification}');
      } else if (dep.dataCollection == DataCollectionStatus.fontDownloadOnly) {
        warnings.add('${dep.name}: ${dep.notes ?? dep.verification}');
      }
    }

    return VerificationResult(
      isCompliant: issues.isEmpty,
      issues: issues,
      warnings: warnings,
      totalDependencies: dependencies.length,
      verifiedDate: DateTime.now(),
    );
  }

  /// Get summary report
  static String getSummaryReport() {
    final result = verifyAllDependencies();
    final buffer = StringBuffer();

    buffer.writeln('=== SDK Privacy Verification Report ===');
    buffer.writeln('Date: ${result.verifiedDate}');
    buffer.writeln('Total Dependencies: ${result.totalDependencies}');
    buffer.writeln('Status: ${result.isCompliant ? "✓ COMPLIANT" : "✗ NON-COMPLIANT"}');
    buffer.writeln();

    if (result.issues.isNotEmpty) {
      buffer.writeln('ISSUES (${result.issues.length}):');
      for (final issue in result.issues) {
        buffer.writeln('  ✗ $issue');
      }
      buffer.writeln();
    }

    if (result.warnings.isNotEmpty) {
      buffer.writeln('WARNINGS (${result.warnings.length}):');
      for (final warning in result.warnings) {
        buffer.writeln('  ⚠ $warning');
      }
      buffer.writeln();
    }

    buffer.writeln('DEPENDENCY DETAILS:');
    for (final dep in dependencies.values) {
      buffer.writeln('  • ${dep.name}');
      buffer.writeln('    Purpose: ${dep.purpose}');
      buffer.writeln('    Status: ${dep.dataCollection.label}');
      buffer.writeln('    Verification: ${dep.verification}');
      if (dep.notes != null) {
        buffer.writeln('    Notes: ${dep.notes}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

/// Privacy information for a single dependency
class DependencyPrivacyInfo {
  const DependencyPrivacyInfo({
    required this.name,
    required this.purpose,
    required this.dataCollection,
    required this.verification,
    required this.source,
    required this.isFirstParty,
    this.notes,
  });

  final String name;
  final String purpose;
  final DataCollectionStatus dataCollection;
  final String verification;
  final String source;
  final bool isFirstParty;
  final String? notes;
}

/// Data collection status for a dependency
enum DataCollectionStatus {
  /// No data collection whatsoever
  none('No data collection'),

  /// Only downloads fonts, no user data collection
  fontDownloadOnly('Font download only (cached)'),

  /// Actively collects user data
  collects('Collects user data');

  const DataCollectionStatus(this.label);
  final String label;
}

/// Result of verification
class VerificationResult {
  const VerificationResult({
    required this.isCompliant,
    required this.issues,
    required this.warnings,
    required this.totalDependencies,
    required this.verifiedDate,
  });

  final bool isCompliant;
  final List<String> issues;
  final List<String> warnings;
  final int totalDependencies;
  final DateTime verifiedDate;
}
