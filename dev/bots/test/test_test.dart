// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' hide Platform;

import 'package:file/file.dart' as fs;
import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';

import '../test.dart';
import 'common.dart';

/// Fails a test if the exit code of `result` is not the expected value. This
/// is favored over `expect(result.exitCode, expectedExitCode)` because this
/// will include the process result's stdio in the failure message.
void expectExitCode(ProcessResult result, int expectedExitCode) {
  if (result.exitCode != expectedExitCode) {
    fail(
      'Process ${result.pid} exited with the wrong exit code.\n'
      '\n'
      'EXPECTED: exit code $expectedExitCode\n'
      'ACTUAL: exit code ${result.exitCode}\n'
      '\n'
      'STDOUT:\n'
      '${result.stdout}\n'
      'STDERR:\n'
      '${result.stderr}'
    );
  }
}

void main() {
  group('verifyVersion()', () {
    late MemoryFileSystem fileSystem;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
    });

    test('passes for valid version strings', () async {
      const List<String> valid_versions = <String>[
        '1.2.3',
        '12.34.56',
        '1.2.3.pre.1',
        '1.2.3-4.5.pre',
        '1.2.3-5.0.pre.12',
      ];
      for (final String version in valid_versions) {
        final File file = fileSystem.file('version');
        file.writeAsStringSync(version);

        expect(
          await verifyVersion(file),
          isNull,
          reason: '$version is valid but verifyVersionFile said it was bad',
        );
      }
    });

    test('fails for invalid version strings', () async {
      const List<String> invalid_versions = <String>[
        '1.2.3.4',
        '1.2.3.',
        '1.2.pre.1',
        '1.2.3-pre.1',
        '1.2.3-pre.1+hotfix.1',
        '  1.2.3',
        '1.2.3-hotfix.1',
      ];
      for (final String version in invalid_versions) {
        final File file = fileSystem.file('version');
        file.writeAsStringSync(version);

        expect(
          await verifyVersion(file),
          'The version logic generated an invalid version string: "$version".',
          reason: '$version is invalid but verifyVersionFile said it was fine',
        );
      }
    });
  });

  group('flutter/pacakges version', () {
    final MemoryFileSystem memoryFileSystem = MemoryFileSystem();
    final fs.File packagesVersionFile = memoryFileSystem.file(path.join('bin','internal','flutter_packages.version'));
    const String kSampleHash = '592b5b27431689336fa4c721a099eedf787aeb56';
    setUpAll(() {
      packagesVersionFile.createSync(recursive: true);
    });

    test('commit hash', () async {
      packagesVersionFile.writeAsStringSync(kSampleHash);
      final String actualHash = await getFlutterPackagesVersion(fileSystem: memoryFileSystem, packagesVersionFile: packagesVersionFile.path);
      expect(actualHash, kSampleHash);
    });

    test('commit hash with newlines', () async {
      packagesVersionFile.writeAsStringSync('\n$kSampleHash\n');
      final String actualHash = await getFlutterPackagesVersion(fileSystem: memoryFileSystem, packagesVersionFile: packagesVersionFile.path);
      expect(actualHash, kSampleHash);
    });
  });

  group('test.dart script', () {
    const ProcessManager processManager = LocalProcessManager();

<<<<<<< HEAD
    Future<ProcessResult> runScript([
        Map<String, String>? environment,
        List<String> otherArgs = const <String>[],
    ]) async {
      final String dart = path.absolute(
        path.join('..', '..', 'bin', 'cache', 'dart-sdk', 'bin', 'dart'),
      );
=======
    Future<ProcessResult> runScript(
        [Map<String, String> environment, List<String> otherArgs = const <String>[]]) async {
      final String dart = path.absolute(
          path.join('..', '..', 'bin', 'cache', 'dart-sdk', 'bin', 'dart'));
>>>>>>> 8962f6dc68ec8e2206ac2fa874da4a453856c7d3
      final ProcessResult scriptProcess = processManager.runSync(<String>[
        dart,
        'test.dart',
        ...otherArgs,
      ], environment: environment);
      return scriptProcess;
    }

    test('subshards tests correctly', () async {
<<<<<<< HEAD
      // When updating this test, try to pick shard numbers that ensure we're checking
      // that unequal test distributions don't miss tests.
      ProcessResult result = await runScript(
        <String, String>{'SHARD': kTestHarnessShardName, 'SUBSHARD': '1_3'},
      );
      expectExitCode(result, 0);
      expect(result.stdout, contains('Selecting subshard 1 of 3 (tests 1-3 of 8)'));

      result = await runScript(
        <String, String>{'SHARD': kTestHarnessShardName, 'SUBSHARD': '3_3'},
      );
      expectExitCode(result, 0);
      expect(result.stdout, contains('Selecting subshard 3 of 3 (tests 7-8 of 8)'));
=======
      ProcessResult result = await runScript(
        <String, String>{'SHARD': 'smoke_tests', 'SUBSHARD': '1_3'},
      );
      expect(result.exitCode, 0);
      // There are currently 6 smoke tests. This shard should contain test 1 and 2.
      expect(result.stdout, contains('Selecting subshard 1 of 3 (range 1-2 of 6)'));

      result = await runScript(
        <String, String>{'SHARD': 'smoke_tests', 'SUBSHARD': '5_6'},
      );
      expect(result.exitCode, 0);
      // This shard should contain only test 5.
      expect(result.stdout, contains('Selecting subshard 5 of 6 (range 5-5 of 6)'));
>>>>>>> 8962f6dc68ec8e2206ac2fa874da4a453856c7d3
    });

    test('exits with code 1 when SUBSHARD index greater than total', () async {
      final ProcessResult result = await runScript(
<<<<<<< HEAD
        <String, String>{'SHARD': kTestHarnessShardName, 'SUBSHARD': '100_99'},
      );
      expectExitCode(result, 1);
      expect(result.stdout, contains('Invalid subshard name'));
    });

    test('exits with code 255 when invalid SUBSHARD name', () async {
      final ProcessResult result = await runScript(
        <String, String>{'SHARD': kTestHarnessShardName, 'SUBSHARD': 'invalid_name'},
      );
      expectExitCode(result, 255);
=======
        <String, String>{'SHARD': 'smoke_tests', 'SUBSHARD': '100_99'},
      );
      expect(result.exitCode, 1);
>>>>>>> 8962f6dc68ec8e2206ac2fa874da4a453856c7d3
      expect(result.stdout, contains('Invalid subshard name'));
    });
  });
}
