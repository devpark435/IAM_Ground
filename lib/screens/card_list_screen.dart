import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
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
          child: Card3DItem(card: card),
        );
      },
    );
  }
}

class Card3DItem extends ConsumerStatefulWidget {
  final ProfileCard card;

  const Card3DItem({super.key, required this.card});

  @override
  ConsumerState<Card3DItem> createState() => _Card3DItemState();
}

class _Card3DItemState extends ConsumerState<Card3DItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // 가로 방향 회전 (세로 드래그로 조작)
      _rotationX += details.delta.dy / 100;
      // 세로 방향 회전 (가로 드래그로 조작)
      _rotationY -= details.delta.dx / 100;

      // 회전 각도 제한
      _rotationX = _rotationX.clamp(-0.3, 0.3);
      _rotationY = _rotationY.clamp(-0.3, 0.3);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // 손을 떼면 카드가 원래 위치로 돌아오는 애니메이션
    setState(() {
      _rotationX = 0;
      _rotationY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 카드 변환 행렬 계산
    final Matrix4 cardTransform =
        Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 원근감 추가
          ..rotateX(_rotationX)
          ..rotateY(_rotationY);

    // 카드 전체를 감싸는 컨테이너
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow:
            _isHovered
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ]
                : AppShadows.small,
      ),
      child: Column(
        children: [
          // 카드 정보 섹션 (이름, 나이, MBTI)
          Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: Row(
              children: [
                // 프로필 이미지
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    image:
                        widget.card.imagePath != null
                            ? DecorationImage(
                              image: AssetImage(widget.card.imagePath!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      widget.card.imagePath == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                ),

                const SizedBox(width: 12),

                // 카드 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.card.age}세, ${widget.card.mbti}',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // 생성 날짜
                Text(
                  _formatDate(widget.card.createdAt),
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),

          // 3D 미리보기 섹션
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTapDown: (_) => setState(() => _isHovered = true),
            onTapUp: (_) => setState(() => _isHovered = false),
            onTapCancel: () => setState(() => _isHovered = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.medium,
              ),
              child: SizedBox(
                height: 180, // 높이 증가
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform(
                      transform: cardTransform,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          child: Stack(
                            children: [
                              // 카드 미리보기
                              Positioned.fill(
                                child: CardPreview(
                                  card: widget.card,
                                  scale: 0.8,
                                ),
                              ),

                              // 인터랙티브 오버레이
                              Positioned.fill(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _isHovered ? 0.1 : 0.0,
                                  child: Container(color: Colors.white),
                                ),
                              ),

                              // 중앙 보기 아이콘
                              if (_isHovered)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.visibility,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 액션 버튼
          Padding(
            padding: const EdgeInsets.all(AppPadding.medium),
            child: Row(
              children: [
                // 보기 버튼
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go('/card/${widget.card.id}');
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

                // 링크 복사 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final shareLink = ref.read(
                        cardShareLinkProvider(widget.card.id),
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
