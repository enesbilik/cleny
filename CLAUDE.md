# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CleanLoop is a micro-cleaning app for Flutter (iOS/Android) that helps users maintain clean homes through daily 10-15 minute tasks. Backend is Supabase (PostgreSQL + Auth + Edge Functions). Push notifications via OneSignal.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Generate localization files (required after changing .arb files)
flutter gen-l10n

# Generate code (Freezed, Riverpod, JSON serialization, Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on iOS Simulator
flutter run -d <simulator_id>

# Run on Android Emulator
flutter run -d <emulator_id>

# Analyze code
flutter analyze

# Run tests
flutter test

# Release builds
flutter build apk --release
flutter build ios --release
```

## Architecture

### Flutter App Structure (lib/)

```
lib/
├── core/              # App-wide infrastructure
│   ├── constants/     # App constants
│   ├── providers/     # Global providers (locale)
│   ├── router/        # go_router configuration
│   ├── services/      # Core services (auth, supabase, cache, notifications, sound)
│   └── theme/         # Theme and colors
├── features/          # Feature modules (auth, calendar, home, onboarding, settings, timer)
│   └── <feature>/
│       ├── data/      # Data layer (services)
│       ├── presentation/  # UI (screens, widgets)
│       └── providers/ # Feature-specific state
├── l10n/              # Localization (.arb files, generated/)
└── shared/            # Shared code
    ├── models/        # Data models (DailyTask, Room, TaskCatalog, UserProfile)
    └── widgets/       # Reusable widgets
```

### State Management

- **Riverpod** with `StateNotifier` pattern
- Key providers: `homeProvider`, `authProvider`, `timerProvider`, `calendarProvider`, `settingsProvider`, `onboardingProvider`
- Auth state tracked via `AuthService.instance` singleton

### Backend (Supabase)

**Tables:** `users_profile`, `rooms`, `tasks_catalog`, `daily_tasks`
- All tables have RLS policies - users can only access their own data
- `tasks_catalog` is read-only seed data (25+ cleaning tasks)

**Edge Functions (supabase/functions/):**
- `send-notifications/` - Push notification dispatch via OneSignal (triggered by cron)
- `profile/`, `rooms/`, `tasks/` - Optional REST endpoints (app uses direct Supabase client)

**Cron Jobs:** Configured via pg_cron for automated reminder notifications

### Key Services

| Service | Purpose |
|---------|---------|
| `auth_service.dart` | Email, Google, Apple authentication via Supabase Auth |
| `supabase_service.dart` | Database operations with Supabase client |
| `cache_service.dart` | Offline caching with Hive |
| `notification_service.dart` | Local notifications via flutter_local_notifications |
| `onesignal_service.dart` | Push notifications with user tags for segmentation |
| `task_selection_service.dart` | Smart task selection algorithm |

### Task Selection Algorithm

Located in `lib/features/home/data/task_selection_service.dart`:
1. Avoids repeating same room from last 1 day
2. Avoids repeating same task type from last 1 day
3. Rules relax if constraints can't be satisfied
4. User blacklist support for permanently skipped tasks

### Routing

go_router with routes defined in `lib/core/router/app_router.dart`:
- `/` - Splash (handles auth redirect)
- `/login` - Auth screen
- `/welcome`, `/onboarding/**` - Onboarding flow
- `/home` - Main screen
- `/timer`, `/completion` - Task execution
- `/settings`, `/calendar` - Secondary screens

### Localization

- Languages: English (en), Turkish (tr)
- ARB files in `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`
- Generated code in `lib/l10n/generated/`
- Access via `AppLocalizations.of(context)!`

## Environment Setup

Required `.env` file in project root:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Supabase Edge Functions require `ONESIGNAL_REST_API_KEY` in secrets.

## Database Migrations

SQL files in `supabase/`:
- `schema.sql` - Initial schema with RLS policies
- `seed.sql` - Task catalog data
- `migration_*.sql` - Schema migrations
- `cron_jobs_simple.sql` - Notification cron setup

## Platform Configuration

**iOS:** OAuth configured in `ios/Runner/Info.plist` with URL schemes for Google/Apple Sign-In
**Android:** OAuth configured in `android/app/build.gradle` and `google-services.json`

Google OAuth Client IDs are in `lib/core/services/auth_service.dart` (lines 36-42).
