import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Uji arsitektur.
///
/// Analyzer Dart tidak punya aturan larangan impor bawaan, jadi batas lapisan
/// dan larangan nilai gaya harfiah ditegakkan di sini — dan ikut dijalankan
/// pada gate `flutter test`.
void main() {
  final sources = _dartSources(Directory('lib'));

  test('ada berkas sumber yang dipindai', () {
    expect(sources, isNotEmpty);
  });

  group('batas lapisan', () {
    test(
      'domain tidak mengimpor Flutter, Drift, basis data, atau jaringan',
      () {
        final violations = _violations(
          sources,
          where: (path) => path.startsWith('lib/domain/'),
          forbidden: <String>[
            'package:flutter/',
            'package:drift/',
            'package:mealora/database/',
            'package:mealora/data/',
            'package:mealora/features/',
            'package:mealora/app/',
            'dart:io',
            'package:http/',
            'package:sqlite3/',
          ],
        );

        expect(violations, isEmpty, reason: violations.join('\n'));
      },
    );

    test(
      'NutritionCalculator (domain/nutrition) tidak mengimpor domain/program',
      () {
        final violations = _violations(
          sources,
          where: (path) => path.startsWith('lib/domain/nutrition/'),
          forbidden: <String>['package:mealora/domain/program/'],
        );

        expect(violations, isEmpty, reason: violations.join('\n'));
      },
    );

    test('lapisan fitur tidak menyentuh penyimpanan secara langsung', () {
      final violations = _violations(
        sources,
        where: (path) => path.startsWith('lib/features/'),
        forbidden: <String>[
          'package:drift/',
          'package:mealora/database/',
          'package:sqlite3/',
        ],
      );

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('lapisan penyimpanan tidak mengimpor antarmuka', () {
      final violations = _violations(
        sources,
        where: (path) =>
            path.startsWith('lib/database/') || path.startsWith('lib/data/'),
        forbidden: <String>[
          'package:flutter/material.dart',
          'package:flutter/widgets.dart',
          'package:flutter/cupertino.dart',
          'package:mealora/features/',
          'package:mealora/app/',
        ],
      );

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('tabel harness tidak dipakai lapisan fitur', () {
      final violations = <String>[];
      for (final file in sources) {
        final path = _relative(file);
        if (!path.startsWith('lib/features/')) {
          continue;
        }
        if (file.readAsStringSync().contains('harness')) {
          violations.add('$path memakai tabel harness');
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('nilai gaya hanya hidup di berkas token', () {
    test('tidak ada warna atau ukuran font harfiah di luar lib/app/theme/', () {
      final patterns = <RegExp>[
        RegExp(r'\bColor\(0x'),
        RegExp(r'\bColors\.'),
        RegExp(r'\bfontSize:\s*\d'),
        RegExp(r'BorderRadius\.circular\(\s*\d'),
      ];

      final violations = <String>[];
      for (final file in sources) {
        final path = _relative(file);
        if (path.startsWith('lib/app/theme/')) {
          continue;
        }
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (_isComment(line)) {
            continue;
          }
          for (final pattern in patterns) {
            if (pattern.hasMatch(line)) {
              violations.add('$path:${i + 1} — ${line.trim()}');
            }
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('waktu dan pengenal selalu lewat sumber yang dapat diganti', () {
    test('tidak ada pembacaan jam sistem di tempat pemakaian', () {
      const allowed = <String>{
        'lib/core/clock/system_clock.dart',
        'lib/core/clock/clock.dart',
      };

      final violations = _patternViolations(
        sources,
        pattern: RegExp(r'DateTime\.now\(\)'),
        allowedPaths: allowed,
      );

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('tidak ada pembangkitan pengenal acak di tempat pemakaian', () {
      const allowed = <String>{
        'lib/core/ids/uuid_id_generator.dart',
        'lib/core/ids/sequential_id_generator.dart',
      };

      final violations = _patternViolations(
        sources,
        pattern: RegExp(r'\bUuid\(|\bRandom\('),
        allowedPaths: allowed,
      );

      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('kemandirian dari jaringan', () {
    test('tidak ada klien jaringan di seluruh aplikasi, kecuali klien sumber '
        'data produk kemasan (change 009, Design D2/D3) dan klien proksi '
        'inferensi label gizi (change 010, Design D2): keduanya di balik '
        'antarmuka yang dapat diganti, dan klien proksi hanya mengirim bita '
        'gambar — tidak ada kredensial penyedia model di aplikasi', () {
      const allowedNetworkClientPaths = <String>{
        'lib/data/remote/openfoodfacts_product_client.dart',
        'lib/data/remote/vision_proxy_label_provider.dart',
      };

      final violations = _violations(
        sources,
        where: (path) => !allowedNetworkClientPaths.contains(path),
        forbidden: <String>[
          'package:http/',
          'package:dio/',
          'package:web_socket_channel/',
          'dart:html',
        ],
      );

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('tidak ada SDK analitik, iklan, atau pelacak', () {
      final forbidden = <String>[
        'firebase_analytics',
        'google_mobile_ads',
        'sentry',
        'amplitude',
        'mixpanel',
        'facebook_app_events',
      ];
      final pubspec = File('pubspec.yaml').readAsStringSync();

      for (final package in forbidden) {
        expect(
          pubspec.contains(package),
          isFalse,
          reason: 'pubspec.yaml memuat $package',
        );
      }
    });
  });
}

List<File> _dartSources(Directory root) {
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !_relative(file).startsWith('lib/l10n/generated/'))
      .toList();
}

String _relative(File file) => file.path.replaceAll(r'\', '/');

bool _isComment(String line) {
  final trimmed = line.trimLeft();
  return trimmed.startsWith('//') || trimmed.startsWith('///');
}

List<String> _violations(
  List<File> sources, {
  required bool Function(String path) where,
  required List<String> forbidden,
}) {
  final violations = <String>[];
  for (final file in sources) {
    final path = _relative(file);
    if (!where(path)) {
      continue;
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.trimLeft().startsWith('import ') &&
          !line.trimLeft().startsWith('export ')) {
        continue;
      }
      for (final needle in forbidden) {
        if (line.contains(needle)) {
          violations.add('$path:${i + 1} — ${line.trim()}');
        }
      }
    }
  }
  return violations;
}

List<String> _patternViolations(
  List<File> sources, {
  required RegExp pattern,
  required Set<String> allowedPaths,
}) {
  final violations = <String>[];
  for (final file in sources) {
    final path = _relative(file);
    if (allowedPaths.contains(path)) {
      continue;
    }
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_isComment(line)) {
        continue;
      }
      if (pattern.hasMatch(line)) {
        violations.add('$path:${i + 1} — ${line.trim()}');
      }
    }
  }
  return violations;
}
