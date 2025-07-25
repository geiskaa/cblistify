// lib/widgets/timer_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimerPainter extends CustomPainter {
  final double progress; // 0.0 (habis) -> 1.0 (penuh)
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  TimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 15.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    // 1. Gambar busur latar belakang abu-abu penuh sebagai dasar
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. Gambar busur progress berwarna di atasnya
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // --- DIUBAH: Logika sudut untuk efek berkurang searah jarum jam ---
    // sweepAngle sekarang menghitung sisa waktu, bukan waktu yang telah berlalu.
    // Progress 1.0 (penuh) -> sweepAngle 2*PI
    // Progress 0.0 (habis) -> sweepAngle 0
    double sweepAngle = 2 * math.pi * progress; 
    
    // startAngle tetap di atas
    double startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
           progressColor != oldDelegate.progressColor;
  }
}