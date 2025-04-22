import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_card.dart';
import '../providers/card_provider.dart';
import '../utils/constants.dart';
import '../widgets/card_preview.dart';
import '../widgets/custom_button.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _saveCard() {
    final currentCard = ref.read(currentCardProvider);

    // Add the card to the list
    ref.read(cardListProvider.notifier).addCard(currentCard);

    setState(() {
      _isSaved = true;
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('카드가 저장되었습니다!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _copyLink(String cardId) {
    final shareLink = ref.read(cardShareLinkProvider(cardId));

    Clipboard.setData(ClipboardData(text: shareLink)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크가 복사되었습니다!'),
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = ref.watch(currentCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 저장 및 공유'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/customize'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: CardPreview(card: currentCard, showAnimations: true),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(AppPadding.large),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.large),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save button
                if (!_isSaved)
                  CustomButton(
                    text: AppStrings.saveButton,
                    onPressed: _saveCard,
                    icon: Icons.save_rounded,
                  )
                else
                  Column(
                    children: [
                      // Success message
                      Container(
                        padding: const EdgeInsets.all(AppPadding.medium),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '카드가 성공적으로 저장되었습니다!',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Copy link button
                      CustomButton(
                        text: AppStrings.copyLinkButton,
                        onPressed: () => _copyLink(currentCard.id),
                        icon: Icons.copy_rounded,
                        type: ButtonType.outline,
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Go to card list button
                CustomButton(
                  text: '내 카드 목록으로 이동',
                  onPressed: () => context.go('/my-cards'),
                  type: _isSaved ? ButtonType.primary : ButtonType.outline,
                  icon: Icons.collections_bookmark_rounded,
                ),

                const SizedBox(height: 16),

                // Create new card button
                TextButton(
                  onPressed: () {
                    // Reset current card and go back to info screen
                    ref.read(currentCardProvider.notifier).state =
                        ProfileCard.empty();
                    context.go('/info');
                  },
                  child: const Text('새 카드 만들기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
