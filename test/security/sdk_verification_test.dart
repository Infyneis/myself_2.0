import 'package:flutter_test/flutter_test.dart';
import 'package:myself_2_0/core/security/sdk_verification.dart';

void main() {
  group('SDK Verification Tests', () {
    test('All dependencies should be privacy compliant', () {
      final result = SdkVerification.verifyAllDependencies();

      // Verify no issues
      expect(result.issues, isEmpty,
          reason: 'No dependencies should collect user data');

      // Verify compliance
      expect(result.isCompliant, isTrue,
          reason: 'All dependencies must be privacy compliant');
    });

    test('Should have documented all pubspec.yaml dependencies', () {
      final verifiedDeps = SdkVerification.dependencies.keys.toSet();

      // Expected dependencies from pubspec.yaml
      final expectedDeps = {
        'flutter',
        'cupertino_icons',
        'provider',
        'hive',
        'hive_flutter',
        'home_widget',
        'uuid',
        'intl',
        'google_fonts',
        'flutter_animate',
        'path_provider',
        'flutter_secure_storage',
        'flutter_test',
        'flutter_lints',
        'hive_generator',
        'build_runner',
        'mocktail',
      };

      expect(verifiedDeps, equals(expectedDeps),
          reason: 'All dependencies must be documented and verified');
    });

    test('All dependencies should have verification notes', () {
      for (final dep in SdkVerification.dependencies.values) {
        expect(dep.name, isNotEmpty);
        expect(dep.purpose, isNotEmpty);
        expect(dep.verification, isNotEmpty);
        expect(dep.source, isNotEmpty);
      }
    });

    test('No dependency should actively collect user data', () {
      for (final dep in SdkVerification.dependencies.values) {
        expect(
          dep.dataCollection,
          isNot(equals(DataCollectionStatus.collects)),
          reason: '${dep.name} should not collect user data',
        );
      }
    });

    test('Verification result should include all metadata', () {
      final result = SdkVerification.verifyAllDependencies();

      expect(result.totalDependencies, greaterThan(0));
      expect(result.verifiedDate, isNotNull);
      expect(result.issues, isNotNull);
      expect(result.warnings, isNotNull);
    });

    test('Summary report should be comprehensive', () {
      final report = SdkVerification.getSummaryReport();

      expect(report, contains('SDK Privacy Verification Report'));
      expect(report, contains('Total Dependencies:'));
      expect(report, contains('DEPENDENCY DETAILS:'));

      // Check that all dependencies are listed
      for (final dep in SdkVerification.dependencies.values) {
        expect(report, contains(dep.name));
      }
    });

    test('google_fonts should be the only dependency with network access', () {
      final depsWithNetwork = SdkVerification.dependencies.values
          .where((dep) =>
              dep.dataCollection == DataCollectionStatus.fontDownloadOnly)
          .toList();

      expect(depsWithNetwork.length, equals(1));
      expect(depsWithNetwork.first.name, equals('google_fonts'));
      expect(depsWithNetwork.first.notes, contains('cached locally'));
    });

    test('Dev dependencies should all be marked as such', () {
      final devDeps = [
        'flutter_test',
        'flutter_lints',
        'hive_generator',
        'build_runner',
        'mocktail',
      ];

      for (final depName in devDeps) {
        final dep = SdkVerification.dependencies[depName];
        expect(dep, isNotNull, reason: '$depName should be documented');
        expect(dep!.verification, contains('dev'),
            reason: '$depName should be marked as dev dependency');
      }
    });

    test('All offline storage dependencies should have no data collection', () {
      final storageDeps = [
        'hive',
        'hive_flutter',
        'flutter_secure_storage',
        'path_provider',
      ];

      for (final depName in storageDeps) {
        final dep = SdkVerification.dependencies[depName];
        expect(dep, isNotNull);
        expect(dep!.dataCollection, equals(DataCollectionStatus.none),
            reason: '$depName should not collect data - it\'s for local storage');
      }
    });
  });
}
