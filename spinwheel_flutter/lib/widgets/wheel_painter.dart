// ============================================================
// widgets/wheel_painter.dart
// Custom painter untuk roda spin — logika sama dengan drawWheel()
// di spin.js web project
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class WheelPainter extends CustomPainter {
  final List<String> options;
  final double angle; // sudut saat ini (radian)
  final int? highlightIndex;

  WheelPainter({
    required this.options,
    required this.angle,
    this.highlightIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = cx - 10;

    if (options.isEmpty) {
      _drawEmpty(canvas, cx, cy, radius);
      return;
    }

    final arc = (math.pi * 2) / options.length;

    for (int i = 0; i < options.length; i++) {
      final startAngle = arc * i + angle;
      final endAngle = startAngle + arc;
      final color = AppTheme.wheelColors[i % AppTheme.wheelColors.length];
      final isHighlighted = i == highlightIndex;
      final segRadius = isHighlighted ? radius + 5 : radius;

      // ── Segmen ───────────────────────────────────────────────
      final paint = Paint()
        ..color = isHighlighted ? _lighten(color, 0.3) : color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: segRadius),
          startAngle,
          arc,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Garis pembatas
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF0F0F1A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // ── Teks segmen ──────────────────────────────────────────
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(startAngle + arc / 2);

      final label = options[i].length > 14
          ? '${options[i].substring(0, 12)}…'
          : options[i];

      final fontSize = options.length > 8 ? 10.0 : 13.0;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            shadows: const [
              Shadow(blurRadius: 3, color: Colors.black54),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius - 30);

      // Posisi teks di segmen (dari tengah ke tepi kanan)
      tp.paint(
        canvas,
        Offset(radius - tp.width - 15, -tp.height / 2),
      );

      canvas.restore();
    }

    // ── Lingkaran tengah ─────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      22,
      Paint()..color = const Color(0xFF0F0F1A),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      22,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // ── Ikon tengah ───────────────────────────────────────────
    final emojiPainter = TextPainter(
      text: const TextSpan(
        text: '🎯',
        style: TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    emojiPainter.paint(
      canvas,
      Offset(cx - emojiPainter.width / 2, cy - emojiPainter.height / 2),
    );
  }

  void _drawEmpty(Canvas canvas, double cx, double cy, double radius) {
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()..color = const Color(0xFF1E1E2E),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = const Color(0xFF333355)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Tambahkan pilihan\nuntuk memulai!',
        style: TextStyle(
          color: Color(0xFF888888),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 1.5);

    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, cy - tp.height / 2),
    );
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.angle != angle ||
      old.options != options ||
      old.highlightIndex != highlightIndex;
}

// ── Penunjuk (pointer) di kanan roda ─────────────────────────
class WheelPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2 - 10)
      ..lineTo(size.width, size.height / 2 + 10)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF4D96FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
