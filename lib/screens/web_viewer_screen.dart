import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    with TickerProviderStateMixin {
  // 일반 애니메이션용 컨트롤러 (진입)
  late AnimationController _entranceAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  // 드래그 상태 변수
  double _dragRotationX = 0;
  double _dragRotationY = 0;
  double _dragRotationZ = 0;
  bool _isDragging = false;

  // 플립 상태
  bool _isFlipped = false;

  // 플립 애니메이션 컨트롤러
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    // 진입 애니메이션 컨트롤러
    _entranceAnimationController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.03, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCirc),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // 플립 애니메이션 컨트롤러
    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _flipAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipped = !_isFlipped;
        });
        _flipAnimationController.reset();
      }
    });

    // 진입 애니메이션 시작
    _entranceAnimationController.forward();
  }

  @override
  void dispose() {
    _entranceAnimationController.dispose();
    _flipAnimationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      // 회전 제한 없이 자유롭게 회전 가능하도록 수정
      _dragRotationX += details.delta.dy / 100;
      _dragRotationY -= details.delta.dx / 100;

      // Z축 회전 (시계 방향/반시계 방향)도 추가
      if (details.delta.dx.abs() > details.delta.dy.abs()) {
        _dragRotationZ += details.delta.dx / 200;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _flipCard() {
    HapticFeedback.mediumImpact();
    _flipAnimationController.forward();
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
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                card.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _entranceAnimationController,
              _flipAnimationController,
            ]),
            builder: (context, child) {
              // 플립 애니메이션 중인지 확인
              bool isFlipping = _flipAnimationController.isAnimating;

              // 기본 변형 행렬 설정
              final Matrix4 cardTransform =
                  Matrix4.identity()..setEntry(3, 2, 0.001); // 원근감 추가

              // 플립 애니메이션 중이면 Y축으로 회전
              if (isFlipping) {
                cardTransform.rotateY(_flipAnimation.value);
              } else {
                // 일반 상태에서는 자유롭게 회전 가능
                cardTransform
                  ..rotateX(_dragRotationX)
                  ..rotateY(_dragRotationY)
                  ..rotateZ(_dragRotationZ);

                // 카드가 뒤집혀 있는 상태라면 Y축 180도 회전
                if (_isFlipped) {
                  cardTransform.rotateY(math.pi);
                }
              }

              return Transform(
                transform: cardTransform,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child:
                        _isFlipped && !isFlipping
                            // 카드 뒷면 (단색 배경)
                            ? Container(
                              width: 300,
                              height: 480,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.flip_to_front,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            )
                            // 카드 앞면
                            : Hero(
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
    );
  }
}
