import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/onesignal_service.dart';

/// Ayarlar içeriği - Tab içinde kullanılabilir
class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            l10n.profile,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Profil Kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserDisplayName(l10n),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.roomsCountDuration(settingsState.roomCount, settingsState.preferredMinutes),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ev Ayarları
          _SectionHeader(title: l10n.homeSettings),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.home_outlined,
                title: l10n.myRooms,
                subtitle: l10n.roomsCount(settingsState.roomCount),
                onTap: () => _showRoomsDialog(context, ref),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.timer_outlined,
                title: l10n.dailyDuration,
                subtitle: l10n.minutesDuration(settingsState.preferredMinutes),
                onTap: () => _showDurationDialog(context, ref),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.schedule_outlined,
                title: l10n.notificationTime,
                subtitle: '${settingsState.availableStart} - ${settingsState.availableEnd}',
                onTap: () => _showTimeDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bildirim Ayarları
          _SectionHeader(title: l10n.notifications),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsSwitch(
                icon: Icons.notifications_outlined,
                title: l10n.taskNotifications,
                subtitle: l10n.dailyTaskReminder,
                value: settingsState.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                },
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.lightbulb_outline,
                title: l10n.motivationalMessages,
                subtitle: l10n.dailyMotivationNotifications,
                value: settingsState.motivationEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setMotivationEnabled(value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Uygulama Ayarları
          _SectionHeader(title: l10n.application),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsSwitch(
                icon: Icons.volume_up_outlined,
                title: l10n.sounds,
                subtitle: l10n.completionAndNotificationSounds,
                value: settingsState.soundEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setSoundEnabled(value);
                },
              ),
              const Divider(height: 1),
              _LanguageTile(ref: ref),
            ],
          ),

          const SizedBox(height: 24),

          // Hesap
          _SectionHeader(title: l10n.account),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.logout,
                title: l10n.signOut,
                subtitle: l10n.signOutFromAccount,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l10n.resetData,
                subtitle: l10n.deleteAllProgressAndSettings,
                textColor: AppColors.error,
                onTap: () => _showResetDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Versiyon
          Center(
            child: Text(
              'CleanLoop v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showRoomsDialog(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final rooms = ref.read(settingsProvider).rooms;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoomsBottomSheet(
        rooms: rooms,
        onSave: (updatedRooms) {
          settingsNotifier.updateRooms(updatedRooms);
        },
      ),
    );
  }

  void _showDurationDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentDuration = ref.read(settingsProvider).preferredMinutes;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyDuration,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dailyDurationQuestion,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [10, 15].map((duration) {
                final isSelected = currentDuration == duration;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: duration == 10 ? 8 : 0,
                      left: duration == 15 ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        settingsNotifier.setPreferredMinutes(duration);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$duration',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.minutes(1).replaceAll('1 ', ''),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showTimeDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentStart = ref.read(settingsProvider).availableStart;
    final currentEnd = ref.read(settingsProvider).availableEnd;
    
    TimeOfDay startTime = _parseTimeOfDay(currentStart);
    TimeOfDay endTime = _parseTimeOfDay(currentEnd);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notificationTime,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.notificationTimeQuestion,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              
              // Başlangıç saati
              _TimePickerTile(
                label: l10n.startTime,
                time: startTime,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    setModalState(() => startTime = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // Bitiş saati
              _TimePickerTile(
                label: l10n.endTime,
                time: endTime,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setModalState(() => endTime = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                    final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
                    settingsNotifier.setAvailableTime(startStr, endStr);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 19,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  /// Kullanıcı adını al (Google/Apple login'den veya email'den)
  String _getUserDisplayName(AppLocalizations l10n) {
    final user = SupabaseService.currentUser;
    if (user == null) return l10n.cleaningLover;

    // Google/Apple login'den gelen isim
    final metadata = user.userMetadata;
    if (metadata != null) {
      // Google login
      final fullName = metadata['full_name'] as String?;
      if (fullName != null && fullName.isNotEmpty) return fullName;

      // Alternatif isim alanları
      final name = metadata['name'] as String?;
      if (name != null && name.isNotEmpty) return name;
    }

    // Email'den isim çıkar (@ öncesi)
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      final namePart = email.split('@').first;
      // İlk harfi büyük yap
      if (namePart.isNotEmpty) {
        return namePart[0].toUpperCase() + namePart.substring(1);
      }
    }

    return l10n.cleaningLover;
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await OneSignalService.removeExternalUserId();
              await authService.signOut();
              ref.read(appStateProvider.notifier).clearOnLogout();
              router.go(AppRoutes.login);
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetData),
        content: Text(l10n.confirmResetData),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(settingsProvider.notifier).resetAllData();
              await ref.read(appStateProvider.notifier).resetData();
              router.go(AppRoutes.welcome);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}

/// Ayarlar ekranı - Ayrı route için (geriye uyumluluk)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SettingsContent(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: textColor?.withOpacity(0.7) ?? AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor ?? AppColors.textHint,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _RoomsBottomSheet extends StatefulWidget {
  final List<String> rooms;
  final Function(List<String>) onSave;

  const _RoomsBottomSheet({
    required this.rooms,
    required this.onSave,
  });

  @override
  State<_RoomsBottomSheet> createState() => _RoomsBottomSheetState();
}

class _RoomsBottomSheetState extends State<_RoomsBottomSheet> {
  late List<String> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = List.from(widget.rooms);
  }

  void _addPreset(String name) {
    if (!_rooms.contains(name)) {
      setState(() {
        _rooms.add(name);
      });
    }
  }

  void _removeRoom(String room) {
    if (_rooms.length > 1) {
      setState(() {
        _rooms.remove(room);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Henüz eklenmemiş preset odalar
    final availablePresets = AppConstants.roomPresets
        .where((p) => !_rooms.contains(p))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myRooms,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Mevcut odalar (silinebilir chip'ler)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _rooms.map((room) {
                return Chip(
                  label: Text(room),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: _rooms.length > 1 ? () => _removeRoom(room) : null,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                  side: const BorderSide(color: AppColors.primary),
                );
              }).toList(),
            ),

            // Eklenebilir preset odalar
            if (availablePresets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.quickAdd,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availablePresets.map((preset) {
                  return ActionChip(
                    label: Text(preset),
                    avatar: const Icon(Icons.add, size: 16),
                    onPressed: () => _addPreset(preset),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_rooms);
                  Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dil seçim tile'ı
class _LanguageTile extends StatelessWidget {
  final WidgetRef ref;

  const _LanguageTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isTurkish = locale.languageCode == 'tr';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.language,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: const Text(
        'Dil / Language',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        isTurkish ? 'Türkçe' : 'English',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: locale.languageCode,
            isDense: true,
            items: const [
              DropdownMenuItem(
                value: 'tr',
                child: Text('🇹🇷 Türkçe'),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text('🇬🇧 English'),
              ),
            ],
            onChanged: (value) {
              if (value == 'tr') {
                ref.read(localeProvider.notifier).setTurkish();
              } else {
                ref.read(localeProvider.notifier).setEnglish();
              }
            },
          ),
        ),
      ),
    );
  }
}
