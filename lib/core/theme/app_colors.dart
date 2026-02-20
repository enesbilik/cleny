import 'package:flutter/material.dart';

/// Uygulama renk paleti - Temizlik temalı, ferah renkler
class AppColors {
  AppColors._();

  // Primary - Turkuaz/Mint tonu (temizlik hissi)
  static const Color primary = Color(0xFF00BFA6);
  static const Color primaryLight = Color(0xFF5DF2D6);
  static const Color primaryDark = Color(0xFF008E76);

  // Secondary - Soft mavi
  static const Color secondary = Color(0xFF64B5F6);
  static const Color secondaryLight = Color(0xFF9BE7FF);
  static const Color secondaryDark = Color(0xFF2286C3);

  // Accent - Sıcak turuncu (motivasyon)
  static const Color accent = Color(0xFFFFB74D);
  static const Color accentLight = Color(0xFFFFE97D);
  static const Color accentDark = Color(0xFFC88719);

  // Background
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F9F7);

  // Text
  static const Color textPrimary = Color(0xFF1A2E35);
  static const Color textSecondary = Color(0xFF5F7A84);
  static const Color textHint = Color(0xFF9CAAAE);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF29B6F6);

  // Cleanliness Levels
  static const Color cleanlinessLevel0 = Color(0xFFBDBDBD); // Çok kirli
  static const Color cleanlinessLevel1 = Color(0xFFFFCDD2); // Kirli
  static const Color cleanlinessLevel2 = Color(0xFFFFE0B2); // Orta
  static const Color cleanlinessLevel3 = Color(0xFFC8E6C9); // Temiz
  static const Color cleanlinessLevel4 = Color(0xFF80CBC4); // Pırıl pırıl

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [background, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static const Color shadowColor = Color(0x1A000000);

  // ── Precomputed alpha variants (avoids runtime withOpacity() allocation) ──

  // black overlays
  static const Color black03 = Color(0x08000000); // 3%
  static const Color black05 = Color(0x0D000000); // 5%
  static const Color black08 = Color(0x14000000); // 8%
  static const Color black20 = Color(0x33000000); // 20%
  static const Color black70 = Color(0xB3000000); // 70%

  // primary (0xFF00BFA6)
  static const Color primaryAlpha06 = Color(0x0F00BFA6); // 6%
  // (primaryAlpha80 = 0xCC00BFA6 for high-opacity overlays)
  static const Color primaryAlpha80 = Color(0xCC00BFA6); // 80%
  static const Color primaryAlpha08 = Color(0x1400BFA6); // 8%
  static const Color primaryAlpha10 = Color(0x1A00BFA6); // 10%
  static const Color primaryAlpha15 = Color(0x2600BFA6); // 15%
  static const Color primaryAlpha20 = Color(0x3300BFA6); // 20%
  static const Color primaryAlpha30 = Color(0x4D00BFA6); // 30%

  // primaryLight (0xFF5DF2D6)
  static const Color primaryLightAlpha05 = Color(0x0D5DF2D6); // 5%
  static const Color primaryLightAlpha10 = Color(0x1A5DF2D6); // 10%
  static const Color primaryLightAlpha06 = Color(0x0F5DF2D6); // 6%
  static const Color primaryLightAlpha20 = Color(0x335DF2D6); // 20%
  static const Color primaryLightAlpha25 = Color(0x405DF2D6); // 25%

  // surfaceVariant (0xFFF0F9F7)
  static const Color surfaceVariantAlpha50 = Color(0x80F0F9F7); // 50%

  // accent (0xFFFFB74D)
  static const Color accentAlpha10 = Color(0x1AFFB74D); // 10%

  // textHint (0xFF9CAAAE)
  static const Color textHintAlpha40 = Color(0x669CAAAE); // 40%
  static const Color textHintAlpha60 = Color(0x999CAAAE); // 60%

  // status colors
  static const Color successAlpha10 = Color(0x1A4CAF50); // success 10%
  static const Color successAlpha30 = Color(0x4D4CAF50); // success 30%
  static const Color errorAlpha10 = Color(0x1AE57373);   // error 10%
  static const Color errorAlpha30 = Color(0x4DE57373);   // error 30%
}

