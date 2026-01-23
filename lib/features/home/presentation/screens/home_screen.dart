import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../home/providers/home_provider.dart';
import '../widgets/house_illustration.dart';
import '../widgets/task_reveal_popup.dart';

/// Ana ekran
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    
    // Profile sekmesine geçildiğinde settings'i yenile
    if (index == 2) {
      ref.read(settingsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _HomeTab(),
            _ProgressTab(),
            const SettingsContent(), // Ayarlar artık tab içinde
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

/// Ana sayfa tab'ı
class _HomeTab extends ConsumerWidget {
  String _getUserName() {
    final user = SupabaseService.currentUser;
    if (user == null) return '';
    
    // user_metadata'dan isim al
    final metadata = user.userMetadata;
    if (metadata != null) {
      final name = metadata['name'] ?? metadata['full_name'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString().split(' ').first; // İlk ismi al
      }
    }
    
    // Email'den isim çıkar
    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final homeState = ref.watch(homeProvider);
    final userName = _getUserName();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım - Selamlama ve Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isNotEmpty ? l10n.helloUser(userName) : l10n.hello,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.cleaningTimeToday,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Streak Badge
              _StreakBadge(streak: homeState.currentStreak),
            ],
          ),

          const SizedBox(height: 24),

          // Ev Görseli
          const HouseIllustration(),

          const SizedBox(height: 24),

          // Durum Mesajı
          _StatusMessage(cleanlinessLevel: homeState.cleanlinessLevel),

          const SizedBox(height: 24),

          // Günlük Görev Kartı
          _DailyTaskSection(homeState: homeState, ref: ref),
        ],
      ),
    );
  }
}

/// Günlük görev bölümü
class _DailyTaskSection extends StatelessWidget {
  final HomeState homeState;
  final WidgetRef ref;

  const _DailyTaskSection({
    required this.homeState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    // Tamamlandıysa
    if (homeState.todayTask?.isCompleted == true) {
      return _CompletedCard();
    }

    // Açıldıysa - görev detayları
    if (homeState.isTaskRevealed && homeState.taskCatalog != null) {
      return _RevealedCard(
        taskTitle: homeState.taskCatalog!.title,
        taskDuration: homeState.taskCatalog!.estimatedMinutes,
        roomName: homeState.taskRoom?.name,
        onStart: () => context.push(AppRoutes.timer),
      );
    }

    // Kapalı - sürpriz kutusu
    return _SurpriseCard(
      taskDuration: homeState.taskCatalog?.estimatedMinutes ?? 10,
      onReveal: () => _showTaskRevealPopup(context),
    );
  }

  void _showTaskRevealPopup(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return TaskRevealPopup(
          taskTitle: homeState.taskCatalog?.title ?? l10n.defaultTaskTitle,
          taskDuration: homeState.taskCatalog?.estimatedMinutes ?? 10,
          roomName: homeState.taskRoom?.name,
          onStart: () {
            ref.read(homeProvider.notifier).revealTask();
            Navigator.of(context).pop();
            context.push(AppRoutes.timer);
          },
          onClose: () {
            ref.read(homeProvider.notifier).revealTask();
            Navigator.of(context).pop();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
}

/// Streak Badge
class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            l10n.dayStreak(streak),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Durum Mesajı
class _StatusMessage extends StatelessWidget {
  final int cleanlinessLevel;

  const _StatusMessage({required this.cleanlinessLevel});

  String _getTitle(AppLocalizations l10n) {
    switch (cleanlinessLevel) {
      case 0:
        return l10n.cleaningTimeCame;
      case 1:
        return l10n.needsSomeTidying;
      case 2:
        return l10n.canTidyUpToday;
      case 3:
        return l10n.homeLooksGood;
      case 4:
        return l10n.perfectSparklingClean;
      default:
        return l10n.canTidyUpToday;
    }
  }

  String _getSubtitle(AppLocalizations l10n) {
    switch (cleanlinessLevel) {
      case 0:
        return l10n.letsStartHomesWaiting;
      case 1:
        return l10n.fewTasksWillFix;
      case 2:
        return l10n.homeNotBadJustSmallTouches;
      case 3:
        return l10n.doingGreatKeepItUp;
      case 4:
        return l10n.congratsHomeLooksAmazing;
      default:
        return l10n.homeNotBadJustSmallTouches;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(
          _getTitle(l10n),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(l10n),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Sürpriz kartı
class _SurpriseCard extends StatelessWidget {
  final int taskDuration;
  final VoidCallback onReveal;

  const _SurpriseCard({
    required this.taskDuration,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: onReveal,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primaryLight.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.dailyTask.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.todaysSurpriseReady,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.onlyTakesMinutes(taskDuration),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.openSurprise,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.card_giftcard_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _GiftBox(),
          ],
        ),
      ),
    );
  }
}

/// Hediye kutusu
class _GiftBox extends StatefulWidget {
  @override
  State<_GiftBox> createState() => _GiftBoxState();
}

class _GiftBoxState extends State<_GiftBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
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
        return Transform.translate(
          offset: Offset(0, -5 * _controller.value),
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB74D).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('🎁', style: TextStyle(fontSize: 48)),
        ),
      ),
    );
  }
}

/// Açılmış görev kartı
class _RevealedCard extends StatelessWidget {
  final String taskTitle;
  final int taskDuration;
  final String? roomName;
  final VoidCallback onStart;

  const _RevealedCard({
    required this.taskTitle,
    required this.taskDuration,
    this.roomName,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🧹', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (roomName != null)
                      Text(
                        roomName!.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      taskTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      l10n.minutesShort(taskDuration),
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.start),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tamamlanmış kart
class _CompletedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaysTaskCompleted,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.newSurpriseAwaitsTomorrow,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress Tab'ı (İstatistikler + Geçmiş birleşik)
class _ProgressTab extends ConsumerWidget {
  List<String> _getMonthNames(AppLocalizations l10n) {
    return [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];
  }
  
  String _formatShortDate(DateTime date, AppLocalizations l10n) {
    final months = _getMonthNames(l10n);
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final homeState = ref.watch(homeProvider);
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 13));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            l10n.progress,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Son 14 gün başlığı
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.last14Days,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_formatShortDate(startDate, l10n)} - ${_formatShortDate(today, l10n)}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Takvim Grid
                _CalendarGrid(completedDates: homeState.completedDates),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Streak Kartları
          Row(
            children: [
              Expanded(
                child: _StreakCard(
                  icon: '🔥',
                  title: l10n.currentStreak,
                  value: '${homeState.currentStreak}',
                  subtitle: l10n.days,
                  description: l10n.keepItUp,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakCard(
                  icon: '🏆',
                  title: l10n.bestStreak,
                  value: '${homeState.bestStreak}',
                  subtitle: l10n.days,
                  description: l10n.goalDays(14),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Son Temizlikler
          Text(
            l10n.recentCleans,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          if (homeState.recentCleans.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.allMicroHabitsLogged,
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            )
          else
            ...homeState.recentCleans.map((task) => _RecentCleanItem(task: task)),
        ],
      ),
    );
  }
}

/// Takvim Grid
class _CalendarGrid extends StatelessWidget {
  final Set<DateTime> completedDates;

  const _CalendarGrid({required this.completedDates});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final days = List.generate(14, (index) {
      return DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 13 - index));
    });

    // Haftanın günleri - locale'e göre
    final weekDays = [
      l10n.dayMon[0], l10n.dayTue[0], l10n.dayWed[0], l10n.dayThu[0],
      l10n.dayFri[0], l10n.daySat[0], l10n.daySun[0]
    ];

    return Column(
      children: [
        // Gün başlıkları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays
              .map((d) => SizedBox(
                    width: 36,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // İlk hafta
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.sublist(0, 7).map((day) {
            return _CalendarDay(
              day: day,
              isCompleted: _isCompleted(day),
              isToday: _isToday(day, today),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // İkinci hafta
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.sublist(7, 14).map((day) {
            return _CalendarDay(
              day: day,
              isCompleted: _isCompleted(day),
              isToday: _isToday(day, today),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isCompleted(DateTime day) {
    return completedDates.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
  }

  bool _isToday(DateTime day, DateTime today) {
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final bool isCompleted;
  final bool isToday;

  const _CalendarDay({
    required this.day,
    required this.isCompleted,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary : AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isCompleted ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Streak kartı
class _StreakCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String subtitle;
  final String description;
  final Color color;

  const _StreakCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Son temizlik item'ı
class _RecentCleanItem extends StatelessWidget {
  final CompletedTask task;

  const _RecentCleanItem({required this.task});

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(taskDay).inDays;
    
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $amPm';
    
    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];

    if (diff == 0) {
      return '${l10n.today}, $timeStr';
    } else if (diff == 1) {
      return '${l10n.yesterday}, $timeStr';
    } else {
      return '${months[date.month - 1]} ${date.day}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(task.completedAt, l10n),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Navigation Bar
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.home,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.calendar_today_rounded,
                label: l10n.progress,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
