import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The app name
  ///
  /// In en, this message translates to:
  /// **'Cleny'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Micro cleaning habits for a tidy home'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Receive one small cleaning task each day'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Build Habits'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Create lasting cleaning routines effortlessly'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Watch your home transform over time'**
  String get onboardingSubtitle3;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @roomSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Your Rooms'**
  String get roomSetupTitle;

  /// No description provided for @roomSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which rooms would you like to keep clean?'**
  String get roomSetupSubtitle;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @bathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get bathroom;

  /// No description provided for @bedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get bedroom;

  /// No description provided for @livingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living Room'**
  String get livingRoom;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @laundryRoom.
  ///
  /// In en, this message translates to:
  /// **'Laundry Room'**
  String get laundryRoom;

  /// No description provided for @entrance.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get entrance;

  /// No description provided for @balcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony'**
  String get balcony;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @timeSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'When are you available?'**
  String get timeSetupTitle;

  /// No description provided for @timeSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send reminders during this time'**
  String get timeSetupSubtitle;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTime;

  /// No description provided for @durationSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time?'**
  String get durationSetupTitle;

  /// No description provided for @durationSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How many minutes can you spare daily?'**
  String get durationSetupSubtitle;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dailyTask.
  ///
  /// In en, this message translates to:
  /// **'Daily Task'**
  String get dailyTask;

  /// No description provided for @todaysTask.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Task'**
  String get todaysTask;

  /// No description provided for @noTaskToday.
  ///
  /// In en, this message translates to:
  /// **'No task today'**
  String get noTaskToday;

  /// No description provided for @getTask.
  ///
  /// In en, this message translates to:
  /// **'Get Today\'s Task'**
  String get getTask;

  /// No description provided for @startTask.
  ///
  /// In en, this message translates to:
  /// **'Start Task'**
  String get startTask;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task Completed!'**
  String get taskCompleted;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @taskCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s task is completed.'**
  String get taskCompletedMessage;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @holdToComplete.
  ///
  /// In en, this message translates to:
  /// **'Hold to Complete'**
  String get holdToComplete;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @earlyComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete early'**
  String get earlyComplete;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! Complete when ready'**
  String get timeUp;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @recentCleans.
  ///
  /// In en, this message translates to:
  /// **'Recent Cleans'**
  String get recentCleans;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @allMicroHabitsLogged.
  ///
  /// In en, this message translates to:
  /// **'All micro-habits logged.'**
  String get allMicroHabitsLogged;

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @motivationalMessages.
  ///
  /// In en, this message translates to:
  /// **'Motivational Messages'**
  String get motivationalMessages;

  /// No description provided for @manageRooms.
  ///
  /// In en, this message translates to:
  /// **'Manage Rooms'**
  String get manageRooms;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @startCleaningJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your cleaning journey'**
  String get startCleaningJourney;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @cleanHomePeacefulLife.
  ///
  /// In en, this message translates to:
  /// **'Clean home,\npeaceful life'**
  String get cleanHomePeacefulLife;

  /// No description provided for @onlyTenMinutesDaily.
  ///
  /// In en, this message translates to:
  /// **'Keep your home tidy\nwith just 15 minutes a day'**
  String get onlyTenMinutesDaily;

  /// No description provided for @microTasksBigDifference.
  ///
  /// In en, this message translates to:
  /// **'Micro tasks, big difference'**
  String get microTasksBigDifference;

  /// No description provided for @newSurpriseDaily.
  ///
  /// In en, this message translates to:
  /// **'A new surprise every day'**
  String get newSurpriseDaily;

  /// No description provided for @streakMotivation.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak, boost your motivation'**
  String get streakMotivation;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! 👋'**
  String helloUser(String name);

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get hello;

  /// No description provided for @cleaningTimeToday.
  ///
  /// In en, this message translates to:
  /// **'It\'s cleaning time today!'**
  String get cleaningTimeToday;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String dayStreak(int count);

  /// No description provided for @cleaningTimeCame.
  ///
  /// In en, this message translates to:
  /// **'Cleaning time has come!'**
  String get cleaningTimeCame;

  /// No description provided for @needsSomeTidying.
  ///
  /// In en, this message translates to:
  /// **'Needs some tidying'**
  String get needsSomeTidying;

  /// No description provided for @canTidyUpToday.
  ///
  /// In en, this message translates to:
  /// **'We can tidy up a bit today'**
  String get canTidyUpToday;

  /// No description provided for @homeLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Home looks good!'**
  String get homeLooksGood;

  /// No description provided for @perfectSparklingClean.
  ///
  /// In en, this message translates to:
  /// **'Perfect! Sparkling clean ✨'**
  String get perfectSparklingClean;

  /// No description provided for @letsStartHomesWaiting.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start, home is waiting!'**
  String get letsStartHomesWaiting;

  /// No description provided for @fewTasksWillFix.
  ///
  /// In en, this message translates to:
  /// **'A few small tasks will fix it.'**
  String get fewTasksWillFix;

  /// No description provided for @homeNotBadJustSmallTouches.
  ///
  /// In en, this message translates to:
  /// **'Home\'s not bad, just small touches needed.'**
  String get homeNotBadJustSmallTouches;

  /// No description provided for @doingGreatKeepItUp.
  ///
  /// In en, this message translates to:
  /// **'Doing great, keep it up!'**
  String get doingGreatKeepItUp;

  /// No description provided for @congratsHomeLooksAmazing.
  ///
  /// In en, this message translates to:
  /// **'Congrats! Your home looks amazing.'**
  String get congratsHomeLooksAmazing;

  /// No description provided for @todaysSurpriseReady.
  ///
  /// In en, this message translates to:
  /// **'Today\'s surprise is ready'**
  String get todaysSurpriseReady;

  /// No description provided for @onlyTakesMinutes.
  ///
  /// In en, this message translates to:
  /// **'Takes only {count} minutes'**
  String onlyTakesMinutes(int count);

  /// No description provided for @openSurprise.
  ///
  /// In en, this message translates to:
  /// **'Open Surprise'**
  String get openSurprise;

  /// No description provided for @todaysTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s task completed! 🎉'**
  String get todaysTaskCompleted;

  /// No description provided for @newSurpriseAwaitsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'A new surprise awaits tomorrow'**
  String get newSurpriseAwaitsTomorrow;

  /// No description provided for @last14Days.
  ///
  /// In en, this message translates to:
  /// **'LAST 14 DAYS'**
  String get last14Days;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @goalDays.
  ///
  /// In en, this message translates to:
  /// **'Goal: {count} Days'**
  String goalDays(int count);

  /// No description provided for @cleaningLover.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Lover'**
  String get cleaningLover;

  /// No description provided for @roomsCountDuration.
  ///
  /// In en, this message translates to:
  /// **'{roomCount} rooms • {minutes} min/day'**
  String roomsCountDuration(int roomCount, int minutes);

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Home Settings'**
  String get homeSettings;

  /// No description provided for @myRooms.
  ///
  /// In en, this message translates to:
  /// **'My Rooms'**
  String get myRooms;

  /// No description provided for @roomsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rooms'**
  String roomsCount(int count);

  /// No description provided for @dailyDuration.
  ///
  /// In en, this message translates to:
  /// **'Daily Duration'**
  String get dailyDuration;

  /// No description provided for @minutesDuration.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesDuration(int count);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @taskNotifications.
  ///
  /// In en, this message translates to:
  /// **'Task Notifications'**
  String get taskNotifications;

  /// No description provided for @dailyTaskReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily task reminder'**
  String get dailyTaskReminder;

  /// No description provided for @dailyMotivationNotifications.
  ///
  /// In en, this message translates to:
  /// **'Daily motivation notifications'**
  String get dailyMotivationNotifications;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// No description provided for @completionAndNotificationSounds.
  ///
  /// In en, this message translates to:
  /// **'Completion and notification sounds'**
  String get completionAndNotificationSounds;

  /// No description provided for @languageSelector.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelector;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOutFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get signOutFromAccount;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @deleteAllProgressAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Delete all progress and settings'**
  String get deleteAllProgressAndSettings;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOut;

  /// No description provided for @confirmResetData.
  ///
  /// In en, this message translates to:
  /// **'All your progress, streaks, and settings will be deleted. This action cannot be undone.'**
  String get confirmResetData;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dailyDurationQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much time do you want to spend each day?'**
  String get dailyDurationQuestion;

  /// No description provided for @notificationTimeQuestion.
  ///
  /// In en, this message translates to:
  /// **'When would you like to receive daily task notifications?'**
  String get notificationTimeQuestion;

  /// No description provided for @addNewRoom.
  ///
  /// In en, this message translates to:
  /// **'Add new room'**
  String get addNewRoom;

  /// No description provided for @confirmExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get confirmExitTitle;

  /// No description provided for @progressWillNotBeSaved.
  ///
  /// In en, this message translates to:
  /// **'Your progress will not be saved.'**
  String get progressWillNotBeSaved;

  /// No description provided for @confirmEarlyComplete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to complete the task now?'**
  String get confirmEarlyComplete;

  /// No description provided for @whichRoomsInHome.
  ///
  /// In en, this message translates to:
  /// **'Which rooms are in your home?'**
  String get whichRoomsInHome;

  /// No description provided for @tasksWillBeAssigned.
  ///
  /// In en, this message translates to:
  /// **'Tasks will be assigned based on these rooms'**
  String get tasksWillBeAssigned;

  /// No description provided for @selectedRooms.
  ///
  /// In en, this message translates to:
  /// **'Selected Rooms ({count})'**
  String selectedRooms(int count);

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @addCustomRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Room'**
  String get addCustomRoom;

  /// No description provided for @customRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Room'**
  String get customRoomTitle;

  /// No description provided for @enterRoomName.
  ///
  /// In en, this message translates to:
  /// **'Enter room name'**
  String get enterRoomName;

  /// No description provided for @maxRoomsReached.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 10 rooms'**
  String get maxRoomsReached;

  /// No description provided for @roomAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This room already exists'**
  String get roomAlreadyExists;

  /// No description provided for @atLeastOneRoom.
  ///
  /// In en, this message translates to:
  /// **'At least 1 room is required'**
  String get atLeastOneRoom;

  /// No description provided for @selectAtLeastOneRoom.
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 room'**
  String get selectAtLeastOneRoom;

  /// No description provided for @yourRooms.
  ///
  /// In en, this message translates to:
  /// **'Your Rooms'**
  String get yourRooms;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email verification required'**
  String get emailVerificationRequired;

  /// No description provided for @registrationSuccessVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! We\'ve sent a verification link to your email. Please check your inbox.'**
  String get registrationSuccessVerifyEmail;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now!'**
  String get startNow;

  /// No description provided for @doItLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it later'**
  String get doItLater;

  /// No description provided for @availableTime.
  ///
  /// In en, this message translates to:
  /// **'Your Free Time'**
  String get availableTime;

  /// No description provided for @whenAreYouAvailable.
  ///
  /// In en, this message translates to:
  /// **'When are you usually home?'**
  String get whenAreYouAvailable;

  /// No description provided for @notificationsBetweenTime.
  ///
  /// In en, this message translates to:
  /// **'We\'ll gently remind you somewhere in these hours 🔔'**
  String get notificationsBetweenTime;

  /// No description provided for @notificationsRandomTime.
  ///
  /// In en, this message translates to:
  /// **'We keep the exact time a surprise — start whenever you feel ready'**
  String get notificationsRandomTime;

  /// No description provided for @endTimeMustBeAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeMustBeAfterStart;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @howMuchTimeDaily.
  ///
  /// In en, this message translates to:
  /// **'How much time can you spare daily?'**
  String get howMuchTimeDaily;

  /// No description provided for @tasksAdjustedByDuration.
  ///
  /// In en, this message translates to:
  /// **'Tasks will be adjusted based on this duration'**
  String get tasksAdjustedByDuration;

  /// No description provided for @yourSelections.
  ///
  /// In en, this message translates to:
  /// **'Your Selections'**
  String get yourSelections;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get timeRange;

  /// No description provided for @quickAndPracticalTasks.
  ///
  /// In en, this message translates to:
  /// **'Quick and practical tasks'**
  String get quickAndPracticalTasks;

  /// No description provided for @moreComprehensiveTasks.
  ///
  /// In en, this message translates to:
  /// **'More comprehensive tasks'**
  String get moreComprehensiveTasks;

  /// No description provided for @startCleaning.
  ///
  /// In en, this message translates to:
  /// **'Start Cleaning! 🧹'**
  String get startCleaning;

  /// No description provided for @holdAndComplete.
  ///
  /// In en, this message translates to:
  /// **'Hold to Clean 🧽'**
  String get holdAndComplete;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning...'**
  String get cleaning;

  /// No description provided for @childRoom.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Room'**
  String get childRoom;

  /// No description provided for @studyRoom.
  ///
  /// In en, this message translates to:
  /// **'Study Room'**
  String get studyRoom;

  /// No description provided for @hallway.
  ///
  /// In en, this message translates to:
  /// **'Hallway'**
  String get hallway;

  /// No description provided for @defaultTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Task'**
  String get defaultTaskTitle;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dateTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'{month} {day}, {time}'**
  String dateTimeFormat(Object day, Object month, Object time);

  /// No description provided for @notificationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to get your daily cleaning reminder'**
  String get notificationPermissionDeniedMessage;

  /// No description provided for @notificationPermissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get notificationPermissionOpenSettings;

  /// No description provided for @neverShowThisTask.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this task again'**
  String get neverShowThisTask;

  /// No description provided for @taskBlacklistedMessage.
  ///
  /// In en, this message translates to:
  /// **'Got it! We\'ll pick a different task for you tomorrow 👍'**
  String get taskBlacklistedMessage;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaysSummary;

  /// No description provided for @totalCleans.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalCleans;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @cleanDays.
  ///
  /// In en, this message translates to:
  /// **'{count} clean days'**
  String cleanDays(int count);

  /// No description provided for @dailyTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get dailyTipTitle;

  /// No description provided for @dailyTip1.
  ///
  /// In en, this message translates to:
  /// **'Wiping the counter before bed makes your morning better'**
  String get dailyTip1;

  /// No description provided for @dailyTip2.
  ///
  /// In en, this message translates to:
  /// **'Assign a place for everything, tidying gets easier'**
  String get dailyTip2;

  /// No description provided for @dailyTip3.
  ///
  /// In en, this message translates to:
  /// **'Taking shoes off at the door keeps your home clean'**
  String get dailyTip3;

  /// No description provided for @dailyTip4.
  ///
  /// In en, this message translates to:
  /// **'Replace the trash bag right away, don\'t postpone'**
  String get dailyTip4;

  /// No description provided for @dailyTip5.
  ///
  /// In en, this message translates to:
  /// **'Wash the dishes immediately, prevent piling up'**
  String get dailyTip5;

  /// No description provided for @wellDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Great work today!'**
  String get wellDoneToday;

  /// No description provided for @yourHomeIsGettingBetter.
  ///
  /// In en, this message translates to:
  /// **'Your home is getting better every day'**
  String get yourHomeIsGettingBetter;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
