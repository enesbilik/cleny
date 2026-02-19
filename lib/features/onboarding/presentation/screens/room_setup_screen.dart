import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/onboarding_provider.dart';

/// Oda kurulum ekranı
class RoomSetupScreen extends ConsumerStatefulWidget {
  const RoomSetupScreen({super.key});

  @override
  ConsumerState<RoomSetupScreen> createState() => _RoomSetupScreenState();
}

class _RoomSetupScreenState extends ConsumerState<RoomSetupScreen> {
  final List<RoomEntry> _rooms = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak bir oda ekle
    _rooms.add(RoomEntry(id: _uuid.v4(), name: 'Salon'));
  }

  void _addRoom(String name) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_rooms.length >= AppConstants.maxRoomCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.maxRoomsReached)),
      );
      return;
    }

    // Aynı isimde oda var mı kontrol et
    if (_rooms.any((r) => r.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomAlreadyExists)),
      );
      return;
    }

    setState(() {
      _rooms.add(RoomEntry(id: _uuid.v4(), name: name));
    });
  }

  void _removeRoom(String id) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_rooms.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.atLeastOneRoom)),
      );
      return;
    }

    setState(() {
      _rooms.removeWhere((r) => r.id == id);
    });
  }

  void _continue() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOneRoom)),
      );
      return;
    }

    // Odaları provider'a kaydet
    ref.read(onboardingProvider.notifier).setRooms(
      _rooms.map((r) => r.name).toList(),
    );

    context.go(AppRoutes.timeSetup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Seçilmemiş preset odalar
    final availablePresets = AppConstants.roomPresets
        .where((p) => !_rooms.any((r) => r.name == p))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yourRooms),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                l10n.whichRoomsInHome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tasksWillBeAssigned,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Seçili odalar
              if (_rooms.isNotEmpty) ...[
                Text(
                  l10n.selectedRooms(_rooms.length),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _rooms.map((room) {
                    return Chip(
                      label: Text(room.name),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeRoom(room.id),
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      side: const BorderSide(color: AppColors.primary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Hazır şablonlar
              if (availablePresets.isNotEmpty) ...[
                Text(
                  l10n.quickAdd,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availablePresets.map((preset) {
                    return ActionChip(
                      label: Text(preset),
                      avatar: const Icon(Icons.add, size: 18),
                      onPressed: () => _addRoom(preset),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              const Spacer(),

              // Devam butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _rooms.isNotEmpty ? _continue : null,
                  child: Text(l10n.continueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Oda girişi için yardımcı sınıf
class RoomEntry {
  final String id;
  final String name;

  RoomEntry({required this.id, required this.name});
}

