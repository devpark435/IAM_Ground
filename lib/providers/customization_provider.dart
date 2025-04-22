import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardCustomization {
  final String backgroundId;
  final double filterIntensity;
  final String fontFamily;

  CardCustomization({
    required this.backgroundId,
    required this.filterIntensity,
    required this.fontFamily,
  });

  CardCustomization copyWith({
    String? backgroundId,
    double? filterIntensity,
    String? fontFamily,
  }) {
    return CardCustomization(
      backgroundId: backgroundId ?? this.backgroundId,
      filterIntensity: filterIntensity ?? this.filterIntensity,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class CustomizationNotifier extends StateNotifier<CardCustomization> {
  CustomizationNotifier()
    : super(
        CardCustomization(
          backgroundId: 'bg1',
          filterIntensity: 0.5,
          fontFamily: 'Pretendard',
        ),
      );

  void updateBackground(String backgroundId) {
    state = state.copyWith(backgroundId: backgroundId);
  }

  void updateFilterIntensity(double intensity) {
    state = state.copyWith(filterIntensity: intensity);
  }

  void updateFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void reset() {
    state = CardCustomization(
      backgroundId: 'bg1',
      filterIntensity: 0.5,
      fontFamily: 'Pretendard',
    );
  }
}

final customizationProvider =
    StateNotifierProvider<CustomizationNotifier, CardCustomization>(
      (ref) => CustomizationNotifier(),
    );

// Background options
final backgroundsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'bg1',
      'name': '크림 그라데이션',
      'thumbnail': 'assets/backgrounds/thumbnails/bg1.png',
    },
    {
      'id': 'bg2',
      'name': '마블 패턴',
      'thumbnail': 'assets/backgrounds/thumbnails/bg2.png',
    },
    {
      'id': 'bg3',
      'name': '파스텔 웨이브',
      'thumbnail': 'assets/backgrounds/thumbnails/bg3.png',
    },
    {
      'id': 'bg4',
      'name': '모던 블루',
      'thumbnail': 'assets/backgrounds/thumbnails/bg4.png',
    },
    {
      'id': 'bg5',
      'name': '로즈 골드',
      'thumbnail': 'assets/backgrounds/thumbnails/bg5.png',
    },
  ];
});

// Font options
final fontsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'id': 'Pretendard', 'name': '프리텐다드'},
    {'id': 'GmarketSans', 'name': '지마켓 산스'},
    {'id': 'IBMPlexSansKR', 'name': 'IBM Plex Sans KR'},
    {'id': 'NanumSquare', 'name': '나눔스퀘어'},
    {'id': 'SpoqaHanSansNeo', 'name': '스포카 한 산스'},
  ];
});
