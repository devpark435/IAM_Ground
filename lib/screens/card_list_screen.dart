import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_card.dart';
import '../providers/card_provider.dart';
import '../utils/constants.dart';
import '../widgets/card_preview.dart';
import '../widgets/custom_button.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 카드 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body:
          cards.isEmpty
              ? _buildEmptyState(context)
              : _buildCardList(context, ref, cards),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(currentCardProvider.notifier).state = ProfileCard.empty();
          context.go('/info');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.collections_bookmark_outlined,
                size: 60,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '아직 저장된 카드가 없어요',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '첫 번째 자기소개 카드를 만들어보세요!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: '카드 만들기',
              icon: Icons.add_rounded,
              onPressed: () {
                context.go('/info');
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(
    BuildContext context,
    WidgetRef ref,
    List<ProfileCard> cards,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppPadding.medium),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CardItem(card: card),
        );
      },
    );
  }
}

class CardItem extends ConsumerWidget {
  final ProfileCard card;

  const CardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          // Card info section
          Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: Row(
              children: [
                // Mini profile image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    image:
                        card.imagePath != null
                            ? DecorationImage(
                              image: AssetImage(card.imagePath!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      card.imagePath == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                ),

                const SizedBox(width: 12),

                // Card info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${card.age}세, ${card.mbti}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Created date
                Text(
                  _formatDate(card.createdAt),
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),

          // Preview section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium),
            child: SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: Stack(
                  children: [
                    // Mini card preview (scaled down)
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: 400, // These dimensions preserve aspect ratio
                          height: 600,
                          child: CardPreview(card: card, scale: 0.5),
                        ),
                      ),
                    ),

                    // Gradient overlay for better visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0),
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Introduction text on top
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        card.introduction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: Row(
              children: [
                // View button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go('/card/${card.id}');
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text(AppStrings.viewButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Copy link button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final shareLink = ref.read(
                        cardShareLinkProvider(card.id),
                      );
                      Clipboard.setData(ClipboardData(text: shareLink)).then((
                        _,
                      ) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('링크가 복사되었습니다!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text(AppStrings.copyLinkButton),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
