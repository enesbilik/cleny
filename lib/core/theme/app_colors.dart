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
}

