import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/card_provider.dart';
import '../utils/constants.dart';
import '../widgets/card_preview.dart';

class WebViewerScreen extends ConsumerStatefulWidget {
  final String cardId;

  const WebViewerScreen({super.key, required this.cardId});

  @override
  ConsumerState<WebViewerScreen> createState() => _WebViewerScreenState();
}

class _WebViewerScreenState extends ConsumerState<WebViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  double _dragRotationY = 0;
  double _dragRotationX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.03, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCirc),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
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
      _isDragging = true;
      _dragRotationX += details.delta.dy / 150;
      _dragRotationY -= details.delta.dx / 150;

      // 회전 각도 제한
      _dragRotationX = _dragRotationX.clamp(-0.3, 0.3);
      _dragRotationY = _dragRotationY.clamp(-0.3, 0.3);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      // 부드럽게 원래 위치로 복귀하는 애니메이션 효과를 위해 바로 값을 0으로 설정하지 않음
      _dragRotationX = _dragRotationX * 0.5;
      _dragRotationY = _dragRotationY * 0.5;

      // 약간의 지연 후 완전히 원위치
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isDragging) {
          setState(() {
            _dragRotationX = 0;
            _dragRotationY = 0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = ref
        .watch(cardListProvider.notifier)
        .getCardById(widget.cardId);

    if (card == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                '카드를 찾을 수 없습니다',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '요청하신 ID의 카드가 존재하지 않습니다',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    // 카드의 2.5D 변형 행렬 계산
    final Matrix4 cardTransform =
        Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 원근감 추가
          ..rotateX(_dragRotationX)
          ..rotateY(_dragRotationY);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              final shareLink = ref.read(cardShareLinkProvider(card.id));
              Clipboard.setData(ClipboardData(text: shareLink)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('링크가 복사되었습니다!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 배경 파티클
          ...List.generate(40, (index) {
            final size = math.Random().nextDouble() * 8 + 2;
            final x =
                math.Random().nextDouble() * MediaQuery.of(context).size.width;
            final y =
                math.Random().nextDouble() * MediaQuery.of(context).size.height;
            final opacity = math.Random().nextDouble() * 0.5 + 0.1;
            final animDuration = math.Random().nextInt(5000) + 3000;

            return AnimatedPositioned(
              duration: Duration(milliseconds: animDuration),
              curve: Curves.easeInOut,
              left: x,
              top: y,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: animDuration ~/ 2),
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),

          // 인터랙티브 배경 효과 (그라데이션)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      _dragRotationY * 0.5,
                      _dragRotationX * 0.5,
                    ),
                    radius: 1.2,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      Colors.black.withOpacity(0.92),
                    ],
                  ),
                ),
              );
            },
          ),

          // 인터랙티브 카드 (드래그로 회전)
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform(
                    transform: cardTransform,
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Hero(
                          tag: 'card_${card.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: CardPreview(
                              card: card,
                              showAnimations: true,
                              isInteractive: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 하단 정보 패널 (페이드인)
          AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppPadding.medium),
                    margin: const EdgeInsets.all(AppPadding.medium),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${card.name}의 자기소개 카드',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.introduction,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoChip(card.age.toString() + '세'),
                            const SizedBox(width: 8),
                            _buildInfoChip(card.mbti),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 카드 정보 UI 표시
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoBadge(Icons.person, card.name),
                            const SizedBox(width: 16),
                            _buildInfoBadge(
                              Icons.calendar_today,
                              _formatDate(card.createdAt),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 안내 문구
                        Text(
                          '카드를 드래그하여 회전시켜보세요!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}
