/// Uygulama genelinde kullanılan sabitler
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CleanLoop';
  static const String appVersion = '1.0.0';

  // Onboarding
  static const int minRoomCount = 1;
  static const int maxRoomCount = 10;
  static const int defaultTaskDuration = 10; // dakika
  static const List<int> taskDurationOptions = [10, 15];

  // Timer
  static const int holdToCompleteDuration = 2000; // milisaniye (2 saniye)

  // Streak & Calendar
  static const int calendarDaysToShow = 14;
  static const int streakCalculationDays = 7;

  // Cleanliness Levels (0-4)
  static const int maxCleanlinessLevel = 4;

  // Default Times
  static const String defaultAvailableStart = '19:00';
  static const String defaultAvailableEnd = '22:00';

  // Timezone
  static const String defaultTimezone = 'Europe/Istanbul';

  // Room Presets
  static const List<String> roomPresets = [
    'Salon',
    'Yatak Odası',
    'Mutfak',
    'Banyo',
    'Çocuk Odası',
    'Çalışma Odası',
    'Koridor',
    'Balkon',
  ];

  // Task Types
  static const List<String> taskTypes = [
    'vacuum',
    'wipe',
    'tidy',
    'trash',
    'kitchen',
    'laundry',
    'bath',
    'dust',
  ];

  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userProfileKey = 'user_profile';
  static const String roomsKey = 'rooms';
  static const String soundEnabledKey = 'sound_enabled';
}

