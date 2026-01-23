import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Basılı tut ve tamamla butonu
class HoldToCompleteButton extends StatefulWidget {
  final VoidCallback onCompleted;

  const HoldToCompleteButton({
    super.key,
    required this.onCompleted,
  });

  @override
  State<HoldToCompleteButton> createState() => _HoldToCompleteButtonState();
}

class _HoldToCompleteButtonState extends State<HoldToCompleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;
  bool _isCompleted = false;
  double _soapPosition = 0;
  Timer? _soapTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: AppConstants.holdToCompleteDuration),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCompleted) {
        _isCompleted = true;
        HapticFeedback.heavyImpact();
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _soapTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    if (_isCompleted) return;

    setState(() => _isHolding = true);
    _controller.forward();
    HapticFeedback.lightImpact();

    // Sabun animasyonu
    _soapTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isHolding) {
        setState(() {
          _soapPosition = (_soapPosition + 0.1) % 1.0;
        });
      }
    });
  }

  void _endHold() {
    if (_isCompleted) return;

    setState(() => _isHolding = false);
    _soapTimer?.cancel();

    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _endHold(),
      onTapCancel: _endHold,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isCompleted ? AppColors.success : AppColors.primary,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                children: [
                  // İlerleme arka planı
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _controller.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sabun animasyonu
                  if (_isHolding && !_isCompleted)
                    Positioned(
                      left: _soapPosition * (MediaQuery.of(context).size.width - 100),
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _SoapBubbles(),
                      ),
                    ),

                  // İçerik
                  Center(
                    child: Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCompleted
                                  ? Icons.check_circle
                                  : _isHolding
                                      ? Icons.cleaning_services
                                      : Icons.touch_app,
                              color: _controller.value > 0.5
                                  ? Colors.white
                                  : AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isCompleted
                                  ? l10n.completed
                                  : _isHolding
                                      ? l10n.cleaning
                                      : l10n.holdAndComplete,
                              style: TextStyle(
                                color: _controller.value > 0.5
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Sabun kabarcıkları
class _SoapBubbles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: List.generate(5, (index) {
          final offset = index * 8.0;
          final size = 8.0 + (index % 3) * 4;
          return Positioned(
            left: offset,
            top: 20 + (index % 2) * 10,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.7),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

