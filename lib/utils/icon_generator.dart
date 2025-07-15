import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> generateIcons() async {
  // Icon boyutları
  const sizes = {
    'icon.png': Size(1024, 1024),
    'icon_foreground.png': Size(1024, 1024),
    'splash.png': Size(1242, 2688),
    'splash_dark.png': Size(1242, 2688),
    'splash_android12.png': Size(1080, 1080),
    'splash_android12_dark.png': Size(1080, 1080),
  };

  for (final entry in sizes.entries) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = entry.value;
    final rect = Offset.zero & size;

    // Arka plan
    final isDark = entry.key.contains('dark');
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    canvas.drawRect(rect, Paint()..color = bgColor);

    if (entry.key.startsWith('icon')) {
      // İkon çizimi
      _drawIcon(canvas, size);
    } else {
      // Splash screen çizimi
      _drawSplash(canvas, size, isDark);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (data != null) {
      final bytes = data.buffer.asUint8List();
      final dir = entry.key.startsWith('icon') ? 'icon' : 'splash';
      await Directory('assets/$dir').create(recursive: true);
      await File('assets/$dir/${entry.key}').writeAsBytes(bytes);
    }
  }
}

void _drawIcon(Canvas canvas, Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width * 0.4;
  
  // Dış daire
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.fill,
  );

  // İç daire
  canvas.drawCircle(
    center,
    radius * 0.8,
    Paint()
      ..color = Colors.indigoAccent
      ..style = PaintingStyle.fill,
  );

  // Merkez nokta
  canvas.drawCircle(
    center,
    radius * 0.2,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill,
  );
}

void _drawSplash(Canvas canvas, Size size, bool isDark) {
  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width * 0.3;
  
  // Logo
  _drawIcon(canvas, Size(radius * 2, radius * 2));
  
  // Uygulama adı
  final textPainter = TextPainter(
    text: TextSpan(
      text: 'Smart Panel',
      style: TextStyle(
        color: isDark ? Colors.white : Colors.indigo,
        fontSize: radius * 0.3,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      center.dx - textPainter.width / 2,
      center.dy + radius + 40,
    ),
  );
} 