import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/home_provider.dart';

/// Ev illustrasyonu - Custom Paint ile çizilmiş modern ev
class HouseIllustration extends ConsumerWidget {
  const HouseIllustration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final cleanlinessLevel = homeState.cleanlinessLevel;

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Ev çizimi
          Center(
            child: CustomPaint(
              size: const Size(280, 240),
              painter: _HousePainter(cleanlinessLevel: cleanlinessLevel),
            ),
          ),
          // Parıltı efekti (yüksek temizlik için)
          if (cleanlinessLevel >= 3)
            Positioned.fill(
              child: _SparkleEffect(intensity: cleanlinessLevel - 2),
            ),
        ],
      ),
    );
  }
}

/// Ev çizici
class _HousePainter extends CustomPainter {
  final int cleanlinessLevel;

  _HousePainter({required this.cleanlinessLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Renkler temizlik seviyesine göre
    final houseColor = _getHouseColor();
    final roofColor = _getRoofColor();
    final windowColor = const Color(0xFFE3F2FD);
    final plantColor = const Color(0xFF66BB6A);

    // Zemin / Çimen
    final groundPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(
      Rect.fromLTWH(0, height - 30, width, 30),
      groundPaint,
    );

    // Ev gövdesi
    final housePaint = Paint()..color = houseColor;
    final houseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.15, height * 0.35, width * 0.7, height * 0.5),
      const Radius.circular(8),
    );
    canvas.drawRRect(houseRect, housePaint);

    // Çatı
    final roofPaint = Paint()..color = roofColor;
    final roofPath = Path()
      ..moveTo(width * 0.1, height * 0.38)
      ..lineTo(width * 0.5, height * 0.08)
      ..lineTo(width * 0.9, height * 0.38)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Çatı detayı (alt çizgi)
    final roofLinePaint = Paint()
      ..color = roofColor.withValues(alpha: 0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(width * 0.08, height * 0.38),
      Offset(width * 0.92, height * 0.38),
      roofLinePaint,
    );

    // Üst kat pencereler (balkon)
    _drawWindow(canvas, width * 0.22, height * 0.42, 40, 50, windowColor);
    _drawWindow(canvas, width * 0.42, height * 0.42, 40, 50, windowColor);
    _drawWindow(canvas, width * 0.62, height * 0.42, 40, 50, windowColor);

    // Balkon korkuluğu
    final railingPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(width * 0.18, height * 0.58),
      Offset(width * 0.82, height * 0.58),
      railingPaint,
    );
    // Dikey çubuklar
    for (var i = 0; i < 8; i++) {
      final x = width * 0.18 + (width * 0.64 / 7) * i;
      canvas.drawLine(
        Offset(x, height * 0.55),
        Offset(x, height * 0.58),
        railingPaint,
      );
    }

    // Alt kat - Cam kapı (ortada)
    _drawGlassDoor(canvas, width * 0.35, height * 0.62, 80, 90, windowColor);

    // Sol pencere
    _drawWindow(canvas, width * 0.2, height * 0.65, 35, 45, windowColor);

    // Sağ pencere
    _drawWindow(canvas, width * 0.7, height * 0.65, 35, 45, windowColor);

    // Bitkiler
    _drawPlant(canvas, width * 0.08, height * 0.72, plantColor);
    _drawPlant(canvas, width * 0.85, height * 0.72, plantColor);
    _drawSmallPlant(canvas, width * 0.75, height * 0.82, plantColor);

    // Saksı bitki (kapı yanı)
    _drawPotPlant(canvas, width * 0.58, height * 0.78, plantColor);
  }

  Color _getHouseColor() {
    // Temizlik seviyesine göre ev rengi
    switch (cleanlinessLevel) {
      case 0:
        return const Color(0xFFCFD8DC); // Gri
      case 1:
        return const Color(0xFFE0E7EA);
      case 2:
        return const Color(0xFFE8F5F2); // Açık mint
      case 3:
        return const Color(0xFFE0F2F1);
      case 4:
        return const Color(0xFFE0F7FA); // Parlak
      default:
        return const Color(0xFFE8F5F2);
    }
  }

  Color _getRoofColor() {
    switch (cleanlinessLevel) {
      case 0:
        return const Color(0xFF90A4AE);
      case 1:
        return const Color(0xFF80CBC4);
      case 2:
        return const Color(0xFF80CBC4);
      case 3:
        return const Color(0xFF4DB6AC);
      case 4:
        return const Color(0xFF26A69A);
      default:
        return const Color(0xFF80CBC4);
    }
  }

  void _drawWindow(Canvas canvas, double x, double y, double w, double h, Color color) {
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);

    // Pencere çerçevesi
    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x + w / 2, y), Offset(x + w / 2, y + h), framePaint);
    canvas.drawLine(Offset(x, y + h / 2), Offset(x + w, y + h / 2), framePaint);
  }

  void _drawGlassDoor(Canvas canvas, double x, double y, double w, double h, Color color) {
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);

    // Orta çizgi
    final framePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x + w / 2, y + 5), Offset(x + w / 2, y + h - 5), framePaint);
  }

  void _drawPlant(Canvas canvas, double x, double y, Color color) {
    final paint = Paint()..color = color;

    // Yapraklar
    for (var i = 0; i < 5; i++) {
      final leafPath = Path();
      final offsetX = (i - 2) * 8.0;
      final offsetY = (i % 2) * 10.0;
      
      leafPath.moveTo(x + offsetX, y + 40 - offsetY);
      leafPath.quadraticBezierTo(
        x + offsetX - 10, y + 10 - offsetY,
        x + offsetX, y - offsetY,
      );
      leafPath.quadraticBezierTo(
        x + offsetX + 10, y + 10 - offsetY,
        x + offsetX, y + 40 - offsetY,
      );
      canvas.drawPath(leafPath, paint);
    }
  }

  void _drawSmallPlant(Canvas canvas, double x, double y, Color color) {
    final paint = Paint()..color = color;
    
    // Saksı
    final potPaint = Paint()..color = const Color(0xFFBCAAA4);
    canvas.drawRect(Rect.fromLTWH(x - 8, y + 15, 16, 20), potPaint);

    // Yapraklar
    for (var i = 0; i < 3; i++) {
      final leafPath = Path();
      final offsetX = (i - 1) * 6.0;
      
      leafPath.moveTo(x + offsetX, y + 15);
      leafPath.quadraticBezierTo(x + offsetX - 5, y + 5, x + offsetX, y);
      leafPath.quadraticBezierTo(x + offsetX + 5, y + 5, x + offsetX, y + 15);
      canvas.drawPath(leafPath, paint);
    }
  }

  void _drawPotPlant(Canvas canvas, double x, double y, Color color) {
    // Saksı
    final potPaint = Paint()..color = const Color(0xFF5D4037);
    final potPath = Path()
      ..moveTo(x - 12, y + 10)
      ..lineTo(x - 8, y + 30)
      ..lineTo(x + 8, y + 30)
      ..lineTo(x + 12, y + 10)
      ..close();
    canvas.drawPath(potPath, potPaint);

    // Bitki
    for (var i = 0; i < 4; i++) {
      final leafPath = Path();
      
      leafPath.moveTo(x, y + 10);
      leafPath.quadraticBezierTo(
        x + 20 * (i.isEven ? 1 : -1) * (i ~/ 2 + 1) * 0.3,
        y - 10,
        x + 15 * (i.isEven ? 1 : -1) * (i ~/ 2 + 1) * 0.4,
        y - 20,
      );
      canvas.drawPath(leafPath, Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) {
    return oldDelegate.cleanlinessLevel != cleanlinessLevel;
  }
}

/// Parıltı efekti
class _SparkleEffect extends StatefulWidget {
  final int intensity;

  const _SparkleEffect({required this.intensity});

  @override
  State<_SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<_SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SparklePainter(
            progress: _controller.value,
            intensity: widget.intensity,
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final int intensity;

  _SparklePainter({required this.progress, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final count = intensity * 4;
    for (int i = 0; i < count; i++) {
      final x = (size.width * 0.2 + (i * 37) % (size.width * 0.6));
      final y = (size.height * 0.2 + (i * 53 + progress * 200) % (size.height * 0.6));
      final radius = 1.5 + (i % 3);
      final opacity = ((progress + i * 0.1) % 1.0);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withValues(alpha: opacity * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

