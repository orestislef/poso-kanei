// One-off icon generator. Draws the πόσο κάνει price-tag mark with dart:ui and
// writes PNG icons for web + a master for launcher icons.
//
// Run from the app/ dir:  flutter test test/gen_icons.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate brand icons', () async {
    await _gen(32, 'web/favicon.png');
    await _gen(192, 'web/icons/Icon-192.png');
    await _gen(512, 'web/icons/Icon-512.png');
    await _gen(192, 'web/icons/Icon-maskable-192.png', bg: const ui.Color(0xFFEEF5F0), inset: 0.20);
    await _gen(512, 'web/icons/Icon-maskable-512.png', bg: const ui.Color(0xFFEEF5F0), inset: 0.20);
    await _gen(1024, 'assets/icon_master.png', bg: const ui.Color(0xFFEEF5F0), inset: 0.14);
    await _gen(1024, 'assets/icon_foreground.png', inset: 0.26);
  });
}

Future<void> _gen(int size, String path, {ui.Color? bg, double inset = 0.06}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final s = size.toDouble();

  if (bg != null) {
    final rr = ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(0, 0, s, s),
      ui.Radius.circular(s * 0.18),
    );
    canvas.drawRRect(rr, ui.Paint()..color = bg);
  }

  final pad = s * inset;
  final scale = (s - pad * 2) / 64.0;
  canvas.save();
  canvas.translate(pad, pad);
  canvas.scale(scale);

  // rotate -12° about the 64-space center
  canvas.translate(32, 32);
  canvas.rotate(-12 * math.pi / 180);
  canvas.translate(-32, -32);

  // tag body
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(const ui.Rect.fromLTWH(11, 17, 42, 30), const ui.Radius.circular(9)),
    ui.Paint()..color = const ui.Color(0xFF1F6B4A),
  );
  // hole
  canvas.drawCircle(const ui.Offset(20, 26), 3.6, ui.Paint()..color = const ui.Color(0xFFF7F5EF));
  // € arc (open on the right)
  canvas.drawArc(
    ui.Rect.fromCircle(center: const ui.Offset(36.0, 34.0), radius: 5.9),
    0.62,
    5.04,
    false,
    ui.Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = ui.StrokeCap.round,
  );
  // € crossbars
  final bar = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = ui.StrokeCap.round;
  canvas.drawLine(const ui.Offset(27.5, 32.2), const ui.Offset(36.5, 32.2), bar);
  canvas.drawLine(const ui.Offset(27.5, 35.6), const ui.Offset(35.5, 35.6), bar);

  canvas.restore();

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List());
  // ignore: avoid_print
  print('wrote $path (${size}px)');
}
