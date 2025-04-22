import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_card.dart';

class CardNotifier extends StateNotifier<List<ProfileCard>> {
  CardNotifier() : super([]);

  void addCard(ProfileCard card) {
    state = [...state, card];
  }

  void updateCard(ProfileCard card) {
    state = [
      for (final existingCard in state)
        if (existingCard.id == card.id) card else existingCard,
    ];
  }

  void deleteCard(String id) {
    state = state.where((card) => card.id != id).toList();
  }

  ProfileCard? getCardById(String id) {
    try {
      return state.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
}

final cardListProvider = StateNotifierProvider<CardNotifier, List<ProfileCard>>(
  (ref) => CardNotifier(),
);

final currentCardProvider = StateProvider<ProfileCard>((ref) {
  return ProfileCard.empty();
});

// This provider gives the share link for a card
final cardShareLinkProvider = Provider.family<String, String>((ref, cardId) {
  // In a real app, you would generate a proper sharing URL
  return 'https://yourapp.com/card/$cardId';
});
