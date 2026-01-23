import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Görev tamamlama ekranı
class CompletionScreen extends StatefulWidget {
  const CompletionScreen({super.key});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _particleController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  @override
  void initState() {
    super.initState();

    // Check animasyonu
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.elasticOut,
      ),
    );

    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Parçacık animasyonu
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Animasyonları başlat
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkController.forward();
    });

    // Kutlama sesini çal
    soundService.playCelebration();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Parçacıklar
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // Ana içerik
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  
                  return Column(
                    children: [
                      const Spacer(flex: 2),

                      // Check ikonu
                      AnimatedBuilder(
                        animation: _checkController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _checkScale.value,
                            child: Opacity(
                              opacity: _checkOpacity.value,
                              child: child,
                            ),
                          );
                        },
                        child: _CheckIcon(),
                      ),

                      const SizedBox(height: 40),

                      // Başlık
                      Text(
                        l10n.greatJob,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Alt yazı
                      Text(
                        l10n.taskCompletedMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Ana ekrana dön butonu
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.backToHome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Check ikonu widget'ı
class _CheckIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış halka (soft)
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: 0.15),
          ),
        ),
        // Orta halka
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: 0.25),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
        // İç daire (check)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
      ],
    );
  }
}

/// Parçacık çizici
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Random _random = Random(42); // Sabit seed

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final particles = _generateParticles(size);

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * (1 - progress * 0.3))
        ..style = PaintingStyle.fill;

      final animatedY = particle.y + (progress * particle.speed * 100) % size.height;
      final y = animatedY > size.height ? animatedY - size.height : animatedY;

      switch (particle.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(Offset(particle.x, y), particle.size, paint);
          break;
        case ParticleShape.square:
          canvas.save();
          canvas.translate(particle.x, y);
          canvas.rotate(progress * particle.rotation);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size * 2, height: particle.size * 2),
            paint,
          );
          canvas.restore();
          break;
        case ParticleShape.triangle:
          canvas.save();
          canvas.translate(particle.x, y);
          canvas.rotate(progress * particle.rotation);
          final path = Path()
            ..moveTo(0, -particle.size)
            ..lineTo(particle.size, particle.size)
            ..lineTo(-particle.size, particle.size)
            ..close();
          canvas.drawPath(path, paint);
          canvas.restore();
          break;
        case ParticleShape.star:
          _drawStar(canvas, Offset(particle.x, y), particle.size, paint, progress * particle.rotation);
          break;
        case ParticleShape.line:
          canvas.save();
          canvas.translate(particle.x, y);
          canvas.rotate(particle.rotation + progress);
          paint.strokeWidth = 2;
          paint.style = PaintingStyle.stroke;
          canvas.drawLine(Offset(-particle.size, 0), Offset(particle.size, 0), paint);
          canvas.restore();
          break;
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2);
      final x = cos(angle) * size;
      final y = sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  List<_Particle> _generateParticles(Size size) {
    final particles = <_Particle>[];
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.secondary,
      AppColors.accent,
      const Color(0xFF90A4AE),
    ];

    for (int i = 0; i < 30; i++) {
      particles.add(_Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        size: 3 + _random.nextDouble() * 8,
        color: colors[_random.nextInt(colors.length)],
        opacity: 0.3 + _random.nextDouble() * 0.5,
        speed: 0.5 + _random.nextDouble() * 1.5,
        rotation: _random.nextDouble() * pi * 2,
        shape: ParticleShape.values[_random.nextInt(ParticleShape.values.length)],
      ));
    }

    return particles;
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

enum ParticleShape { circle, square, triangle, star, line }

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double opacity;
  final double speed;
  final double rotation;
  final ParticleShape shape;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.opacity,
    required this.speed,
    required this.rotation,
    required this.shape,
  });
}

