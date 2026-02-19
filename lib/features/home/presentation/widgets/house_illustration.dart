import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/home_provider.dart';

class HouseIllustration extends ConsumerWidget {
  const HouseIllustration({super.key});

  static const _images = {
    'clean': 'assets/images/temiz.png',
    'medium': 'assets/images/orta-kirli.png',
    'dirty': 'assets/images/en-kirli.png',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final imageKey = homeState.houseImageState;
    final imagePath = _images[imageKey]!;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Image.asset(
            imagePath,
            key: ValueKey(imageKey),
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
