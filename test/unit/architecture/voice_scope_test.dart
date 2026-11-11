import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Change 012, task 6.3/6.4: masukan suara hanya ada di jalur pencatatan
/// makanan. Tidak ada layar berat badan, program, profil, pengaturan, atau
/// navigasi yang memakai pengenal ucapan maupun menampilkan kendali
/// mikrofon.
void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll(r'\', '/').contains('/generated/'))
      .toList(growable: false);

  String rel(File f) => f.path.replaceAll(r'\', '/');

  List<String> offenders(Pattern needle, Set<String> allowed) => <String>[
    for (final file in sources)
      if (!allowed.contains(rel(file)) &&
          file.readAsStringSync().contains(needle))
        rel(file),
  ];

  test('pengenal ucapan hanya dipakai layar rekam suara (task 6.4)', () {
    final violations = <String>[
      ...offenders('speechRecognizerProvider', <String>{
        'lib/core/providers.dart',
        'lib/app/providers.dart',
        'lib/features/diary/voice_record_screen.dart',
      }),
      ...offenders('package:speech_to_text/', <String>{
        'lib/data/speech/device_speech_recognizer.dart',
      }),
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('kendali mikrofon hanya ada di jalur pencatatan makanan (task 6.3)', () {
    final violations = offenders(RegExp(r'Icons\.mic(?!_off)'), <String>{
      // Kartu "Catat dengan suara" di lembar 02 — pintu masuk jalur makanan.
      'lib/features/diary/add_food_sheet.dart',
      'lib/features/diary/voice_record_screen.dart',
    });
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
