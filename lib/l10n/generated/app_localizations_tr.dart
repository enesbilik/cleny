// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CleanLoop';

  @override
  String get welcome => 'Hoş Geldin';

  @override
  String get welcomeSubtitle =>
      'Temiz bir ev için mikro temizlik alışkanlıkları';

  @override
  String get getStarted => 'Başlayalım';

  @override
  String get onboardingTitle1 => 'Günlük Görevler';

  @override
  String get onboardingSubtitle1 => 'Her gün küçük bir temizlik görevi al';

  @override
  String get onboardingTitle2 => 'Alışkanlık Oluştur';

  @override
  String get onboardingSubtitle2 =>
      'Zahmetsizce kalıcı temizlik rutinleri oluştur';

  @override
  String get onboardingTitle3 => 'İlerlemeyi Takip Et';

  @override
  String get onboardingSubtitle3 => 'Evinin zamanla nasıl dönüştüğünü izle';

  @override
  String get continueButton => 'Devam';

  @override
  String get skip => 'Atla';

  @override
  String get roomSetupTitle => 'Odalarını Seç';

  @override
  String get roomSetupSubtitle => 'Hangi odaları temiz tutmak istersin?';

  @override
  String get kitchen => 'Mutfak';

  @override
  String get bathroom => 'Banyo';

  @override
  String get bedroom => 'Yatak Odası';

  @override
  String get livingRoom => 'Salon';

  @override
  String get office => 'Ofis';

  @override
  String get laundryRoom => 'Çamaşır Odası';

  @override
  String get entrance => 'Giriş';

  @override
  String get balcony => 'Balkon';

  @override
  String get garage => 'Garaj';

  @override
  String get timeSetupTitle => 'Ne zaman müsaitsin?';

  @override
  String get timeSetupSubtitle =>
      'Bu saatler arasında hatırlatıcı göndereceğiz';

  @override
  String get startTime => 'Başlangıç';

  @override
  String get endTime => 'Bitiş';

  @override
  String get durationSetupTitle => 'Ne kadar süren var?';

  @override
  String get durationSetupSubtitle => 'Günlük kaç dakika ayırabilirsin?';

  @override
  String minutes(int count) {
    return '$count dakika';
  }

  @override
  String minutesShort(int count) {
    return '$count dk';
  }

  @override
  String get home => 'Ana Sayfa';

  @override
  String get progress => 'İlerleme';

  @override
  String get settings => 'Ayarlar';

  @override
  String get profile => 'Profil';

  @override
  String get dailyTask => 'Günlük Görev';

  @override
  String get todaysTask => 'Bugünün Görevi';

  @override
  String get noTaskToday => 'Bugün görev yok';

  @override
  String get getTask => 'Bugünün Görevini Al';

  @override
  String get startTask => 'Göreve Başla';

  @override
  String get taskCompleted => 'Görev Tamamlandı!';

  @override
  String get greatJob => 'Harika iş!';

  @override
  String get taskCompletedMessage => 'Bugünkü görev tamamlandı.';

  @override
  String get backToHome => 'Ana ekrana dön';

  @override
  String get timer => 'Zamanlayıcı';

  @override
  String get holdToComplete => 'Tamamlamak için basılı tut';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get running => 'Çalışıyor';

  @override
  String get ready => 'Hazır';

  @override
  String get start => 'Başlat';

  @override
  String get resume => 'Devam';

  @override
  String get pause => 'Durdur';

  @override
  String get earlyComplete => 'Erken tamamla';

  @override
  String get timeUp => 'Süre doldu! Hazırsan tamamla';

  @override
  String get recentActivity => 'Son Aktivite';

  @override
  String get recentCleans => 'Son Temizlikler';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get noRecentActivity => 'Son aktivite yok';

  @override
  String get allMicroHabitsLogged => 'Tüm mikro-alışkanlıklar kaydedildi.';

  @override
  String get notificationTime => 'Bildirim Saati';

  @override
  String get soundEffects => 'Ses Efektleri';

  @override
  String get motivationalMessages => 'Motivasyon Mesajları';

  @override
  String get manageRooms => 'Odaları Yönet';

  @override
  String get language => 'Dil';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get loginTitle => 'Tekrar Hoş Geldin';

  @override
  String get loginWelcome => 'Hoş Geldiniz!';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yap';

  @override
  String get createAccount => 'Hesap Oluşturun';

  @override
  String get startCleaningJourney => 'Temizlik yolculuğunuza başlayın';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get name => 'İsim';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get orContinueWith => 'veya';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String get errorOccurred => 'Bir hata oluştu';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get done => 'Tamam';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get ok => 'Tamam';

  @override
  String get add => 'Ekle';

  @override
  String get exit => 'Çık';

  @override
  String get complete => 'Tamamla';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get cleanHomePeacefulLife => 'Temiz ev,\nhuzurlu yaşam';

  @override
  String get onlyTenMinutesDaily =>
      'Günde sadece 15 dakika ile\nevinizi düzenli tutun';

  @override
  String get microTasksBigDifference => 'Mikro görevler, büyük fark';

  @override
  String get newSurpriseDaily => 'Her gün yeni bir sürpriz';

  @override
  String get streakMotivation => 'Her gün bir adım, evine yansır 🏠';

  @override
  String helloUser(String name) {
    return 'Merhaba, $name! 👋';
  }

  @override
  String get hello => 'Merhaba! 👋';

  @override
  String get cleaningTimeToday => 'Bugün temizlik zamanı!';

  @override
  String dayStreak(int count) {
    return '$count Gün';
  }

  @override
  String get cleaningTimeCame => 'Temizlik zamanı geldi!';

  @override
  String get needsSomeTidying => 'Biraz toparlama gerek';

  @override
  String get canTidyUpToday => 'Bugün biraz toparlayabiliriz';

  @override
  String get homeLooksGood => 'Ev güzel görünüyor!';

  @override
  String get perfectSparklingClean => 'Mükemmel! Pırıl pırıl ✨';

  @override
  String get letsStartHomesWaiting => 'Hadi başlayalım, ev seni bekliyor!';

  @override
  String get fewTasksWillFix => 'Birkaç küçük görev ile düzelir.';

  @override
  String get homeNotBadJustSmallTouches =>
      'Evin durumu fena değil, sadece küçük dokunuşlar yeterli.';

  @override
  String get doingGreatKeepItUp => 'Harika gidiyorsun, devam et!';

  @override
  String get congratsHomeLooksAmazing => 'Tebrikler! Evin muhteşem görünüyor.';

  @override
  String get todaysSurpriseReady => 'Bugünün sürprizi hazır';

  @override
  String onlyTakesMinutes(int count) {
    return 'Sadece $count dakikanı alacak';
  }

  @override
  String get openSurprise => 'Sürprizi Aç';

  @override
  String get todaysTaskCompleted => 'Bugünkü görev tamamlandı! 🎉';

  @override
  String get newSurpriseAwaitsTomorrow =>
      'Yarın yeni bir sürpriz seni bekliyor';

  @override
  String get last14Days => 'SON 14 GÜN';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get bestStreak => 'En İyi Seri';

  @override
  String get days => 'Gün';

  @override
  String get keepItUp => 'Böyle devam!';

  @override
  String goalDays(int count) {
    return 'Hedef: $count Gün';
  }

  @override
  String get cleaningLover => 'Temizlik Sever';

  @override
  String roomsCountDuration(int roomCount, int minutes) {
    return '$roomCount oda • $minutes dk/gün';
  }

  @override
  String get homeSettings => 'Ev Ayarları';

  @override
  String get myRooms => 'Odalarım';

  @override
  String roomsCount(int count) {
    return '$count oda';
  }

  @override
  String get dailyDuration => 'Günlük Süre';

  @override
  String minutesDuration(int count) {
    return '$count dakika';
  }

  @override
  String get notifications => 'Bildirimler';

  @override
  String get taskNotifications => 'Görev Bildirimleri';

  @override
  String get dailyTaskReminder => 'Günlük görev hatırlatması';

  @override
  String get dailyMotivationNotifications => 'Günlük motivasyon bildirimleri';

  @override
  String get application => 'Uygulama';

  @override
  String get sounds => 'Sesler';

  @override
  String get completionAndNotificationSounds => 'Tamamlama ve bildirim sesleri';

  @override
  String get languageSelector => 'Dil / Language';

  @override
  String get account => 'Hesap';

  @override
  String get signOutFromAccount => 'Hesabınızdan çıkış yapın';

  @override
  String get resetData => 'Verileri Sıfırla';

  @override
  String get deleteAllProgressAndSettings => 'Tüm ilerleme ve ayarları sil';

  @override
  String get confirmSignOut =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';

  @override
  String get confirmResetData =>
      'Tüm ilerlemeniz, streak\'leriniz ve ayarlarınız silinecek. Bu işlem geri alınamaz.';

  @override
  String get reset => 'Sıfırla';

  @override
  String get dailyDurationQuestion => 'Her gün ne kadar süre ayırmak istersin?';

  @override
  String get notificationTimeQuestion =>
      'Günlük görev bildirimini ne zaman almak istersin?';

  @override
  String get addNewRoom => 'Yeni oda ekle';

  @override
  String get confirmExitTitle => 'Çıkmak istediğinize emin misiniz?';

  @override
  String get progressWillNotBeSaved => 'İlerlemeniz kaydedilmeyecek.';

  @override
  String get confirmEarlyComplete =>
      'Görevi şimdi tamamlamak istediğinize emin misiniz?';

  @override
  String get whichRoomsInHome => 'Evinizde hangi odalar var?';

  @override
  String get tasksWillBeAssigned => 'Görevleriniz bu odalara göre atanacak';

  @override
  String selectedRooms(int count) {
    return 'Seçili Odalar ($count)';
  }

  @override
  String get quickAdd => 'Hızlı Ekle';

  @override
  String get addCustomRoom => 'Özel Oda Ekle';

  @override
  String get customRoomTitle => 'Özel Oda Ekle';

  @override
  String get enterRoomName => 'Oda adı girin';

  @override
  String get maxRoomsReached => 'En fazla 10 oda ekleyebilirsiniz';

  @override
  String get roomAlreadyExists => 'Bu oda zaten eklenmiş';

  @override
  String get atLeastOneRoom => 'En az 1 oda gerekli';

  @override
  String get selectAtLeastOneRoom => 'En az 1 oda seçin';

  @override
  String get yourRooms => 'Odalarınız';

  @override
  String get emailRequired => 'Email gerekli';

  @override
  String get enterValidEmail => 'Geçerli bir email girin';

  @override
  String get passwordRequired => 'Şifre gerekli';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakter olmalı';

  @override
  String get nameRequired => 'İsim gerekli';

  @override
  String get emailVerificationRequired => 'Email doğrulaması gerekiyor';

  @override
  String get registrationSuccessVerifyEmail =>
      'Kayıt başarılı! Email adresinize doğrulama linki gönderdik. Lütfen emailinizi kontrol edin.';

  @override
  String get startNow => 'Hemen Başla!';

  @override
  String get doItLater => 'Daha sonra yapacağım';

  @override
  String get availableTime => 'Serbest Zamanın';

  @override
  String get whenAreYouAvailable => 'Genellikle ne zaman evde olursun?';

  @override
  String get notificationsBetweenTime =>
      'Seni bu saatler arasında nazikçe hatırlatırız 🔔';

  @override
  String get notificationsRandomTime =>
      'Tam olarak ne zaman göndereceğimizi sürpriz bırakıyoruz — hazır hissettiğinde başla';

  @override
  String get endTimeMustBeAfterStart => 'Bitiş saati başlangıçtan sonra olmalı';

  @override
  String get dailyGoal => 'Günlük Hedef';

  @override
  String get howMuchTimeDaily => 'Günlük ne kadar zaman ayırabilirsiniz?';

  @override
  String get tasksAdjustedByDuration =>
      'Görevleriniz bu süreye göre ayarlanacak';

  @override
  String get yourSelections => 'Seçimleriniz';

  @override
  String get rooms => 'Odalar';

  @override
  String get timeRange => 'Zaman Aralığı';

  @override
  String get quickAndPracticalTasks => 'Hızlı ve pratik görevler';

  @override
  String get moreComprehensiveTasks => 'Daha kapsamlı görevler';

  @override
  String get startCleaning => 'Temizliğe Başla! 🧹';

  @override
  String get holdAndComplete => 'Basılı Tut ve Temizle 🧽';

  @override
  String get cleaning => 'Temizleniyor...';

  @override
  String get childRoom => 'Çocuk Odası';

  @override
  String get studyRoom => 'Çalışma Odası';

  @override
  String get hallway => 'Koridor';

  @override
  String get defaultTaskTitle => 'Temizlik Görevi';

  @override
  String get monthJan => 'Oca';

  @override
  String get monthFeb => 'Şub';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Nis';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Haz';

  @override
  String get monthJul => 'Tem';

  @override
  String get monthAug => 'Ağu';

  @override
  String get monthSep => 'Eyl';

  @override
  String get monthOct => 'Eki';

  @override
  String get monthNov => 'Kas';

  @override
  String get monthDec => 'Ara';

  @override
  String get dayMon => 'Pzt';

  @override
  String get dayTue => 'Sal';

  @override
  String get dayWed => 'Çar';

  @override
  String get dayThu => 'Per';

  @override
  String get dayFri => 'Cum';

  @override
  String get daySat => 'Cmt';

  @override
  String get daySun => 'Paz';

  @override
  String dateTimeFormat(Object day, Object month, Object time) {
    return '$day $month, $time';
  }

  @override
  String get notificationPermissionDeniedMessage =>
      'Günlük temizlik hatırlatıcısı için bildirimlere izin ver';

  @override
  String get notificationPermissionOpenSettings => 'Ayarlar';

  @override
  String get neverShowThisTask => 'Bu görevi bir daha gösterme';

  @override
  String get taskBlacklistedMessage =>
      'Anladık! Yarın sana farklı bir görev seçeceğiz 👍';
}
