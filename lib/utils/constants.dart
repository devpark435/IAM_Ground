import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6B4EFF);
  static const Color secondary = Color(0xFFFF4E91);
  static const Color background = Color(0xFFF8F7FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A1A2E);
  static const Color textLight = Color(0xFF696974);
  static const Color accent1 = Color(0xFF4ECAFF);
  static const Color accent2 = Color(0xFFFFCA4E);
  static const Color divider = Color(0xFFE5E5E5);
  static const Color error = Color(0xFFFF4E4E);
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

class AppPadding {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

class AppShadows {
  static final List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppAssets {
  static const String logoPath = 'assets/images/logo.png';
  static const String bgPath = 'assets/backgrounds/';
  static const String placeholderProfilePath =
      'assets/images/profile_placeholder.png';
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
}

class AppStrings {
  static const String appName = '자기소개 카드';
  static const String startButton = '시작하기';
  static const String nextButton = '다음';
  static const String saveButton = '저장하기';
  static const String shareButton = '공유하기';
  static const String copyLinkButton = '링크 복사';
  static const String viewButton = '보기';

  // Info input screen
  static const String nameLabel = '이름';
  static const String ageLabel = '나이';
  static const String mbtiLabel = 'MBTI';
  static const String introLabel = '한줄 소개';
  static const String imageLabel = '사진 업로드';

  // Customization screen
  static const String backgroundLabel = '배경 스타일';
  static const String filterLabel = '필터 강도';
  static const String fontLabel = '폰트 스타일';
}
