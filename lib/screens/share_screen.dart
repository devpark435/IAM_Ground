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
  bool _isSaving = false;
  bool _isGeneratingLink = false;
  String? _generatedLink;

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

  Future<void> _saveCard() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final currentCard = ref.read(currentCardProvider);

      // Firebase 저장 로직 시뮬레이션 (실제 앱에서는 Firebase 관련 코드 구현)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 카드 목록에 추가
      ref.read(cardListProvider.notifier).addCard(currentCard);

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      // 저장 완료 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카드가 저장되었습니다!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _generateAndCopyLink(String cardId) async {
    if (_isGeneratingLink) return;

    setState(() {
      _isGeneratingLink = true;
    });

    try {
      // Firebase Dynamic Links 생성 로직 시뮬레이션 (실제 앱에서는 Firebase 관련 코드 구현)
      await Future.delayed(const Duration(milliseconds: 1200));

      final shareLink = "https://yourapp.page.link/${cardId.substring(0, 8)}";
      _generatedLink = shareLink;

      // 클립보드에 복사
      await Clipboard.setData(ClipboardData(text: shareLink));

      setState(() {
        _isGeneratingLink = false;
      });

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크가 생성되어 클립보드에 복사되었습니다!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      setState(() {
        _isGeneratingLink = false;
      });

      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('링크 생성 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
              child: Hero(
                tag: 'card_${currentCard.id}',
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
                // 저장 전 상태
                if (!_isSaved)
                  CustomButton(
                    text: AppStrings.saveButton,
                    onPressed: _saveCard,
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                  )
                else
                  Column(
                    children: [
                      // 성공 메시지
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

                      if (_generatedLink != null) ...[
                        const SizedBox(height: 16),

                        // 생성된 링크 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.medium,
                            vertical: AppPadding.small,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _generatedLink!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _generatedLink!),
                                  ).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('링크가 복사되었습니다!'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // 링크 생성 버튼
                      CustomButton(
                        text:
                            _generatedLink == null
                                ? '공유 링크 생성하기'
                                : AppStrings.copyLinkButton,
                        onPressed: () => _generateAndCopyLink(currentCard.id),
                        icon:
                            _generatedLink == null
                                ? Icons.link_rounded
                                : Icons.copy_rounded,
                        type: ButtonType.secondary,
                        isLoading: _isGeneratingLink,
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // 내 카드 목록으로 이동 버튼
                CustomButton(
                  text: '내 카드 목록으로 이동',
                  onPressed: () => context.go('/my-cards'),
                  type: _isSaved ? ButtonType.primary : ButtonType.outline,
                  icon: Icons.collections_bookmark_rounded,
                ),

                const SizedBox(height: 16),

                // 새 카드 만들기 버튼
                TextButton(
                  onPressed: () {
                    // 현재 카드 초기화 후 정보 입력 화면으로 이동
                    ref.read(currentCardProvider.notifier).state =
                        ProfileCard.empty();
                    context.go('/info');
                  },
                  child: const Text('새 카드 만들기'),
                ),

                if (_isSaved) ...[
                  const SizedBox(height: 8),
                  Text(
                    '링크를 통해 웹에서도 카드를 볼 수 있습니다',
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
