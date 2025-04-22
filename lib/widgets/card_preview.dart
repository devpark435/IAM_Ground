import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_card.dart';
import '../utils/constants.dart';
import 'dart:math' as math;

class CardPreview extends ConsumerWidget {
  final ProfileCard card;
  final double scale;
  final bool isInteractive;
  final bool showAnimations;

  const CardPreview({
    super.key,
    required this.card,
    this.scale = 1.0,
    this.isInteractive = false,
    this.showAnimations = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85 * scale;
    final cardHeight = cardWidth * 1.5;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Stack(
          children: [
            // Background
            _buildBackground(cardWidth, cardHeight),

            // Filter overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(card.filterIntensity * 0.3),
              ),
            ),

            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    _buildProfileImage(),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      card.name,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontFamily: card.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // Age & MBTI
                    Text(
                      '${card.age}세, ${card.mbti}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: card.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Introduction
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          card.introduction,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontFamily: card.fontFamily,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Interactive overlay
            if (isInteractive)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Handle tap
                    },
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                ),
              ),

            // Animated elements
            if (showAnimations) ...[
              _buildAnimatedElement(cardWidth, cardHeight, 0.2, 0.3, 0),
              _buildAnimatedElement(cardWidth, cardHeight, 0.8, 0.7, 2000),
              _buildAnimatedElement(cardWidth, cardHeight, 0.3, 0.9, 4000),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(double width, double height) {
    // In a real app, you would use images from your assets based on backgroundId
    List<Color> gradientColors;

    switch (card.backgroundId) {
      case 'bg2':
        gradientColors = [const Color(0xFF6B4EFF), const Color(0xFF9681FF)];
        break;
      case 'bg3':
        gradientColors = [const Color(0xFFFF4E91), const Color(0xFFFF9B82)];
        break;
      case 'bg4':
        gradientColors = [const Color(0xFF4ECAFF), const Color(0xFF6B4EFF)];
        break;
      case 'bg5':
        gradientColors = [const Color(0xFFFFCA4E), const Color(0xFFFF8C4E)];
        break;
      default: // bg1
        gradientColors = [const Color(0xFFFFF3DC), const Color(0xFFFFDDDD)];
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final imageRadius = 50.0 * scale;

    return Container(
      width: imageRadius * 2,
      height: imageRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image:
              card.imagePath != null
                  ? AssetImage(card.imagePath!) as ImageProvider
                  : const AssetImage(AppAssets.placeholderProfilePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnimatedElement(
    double width,
    double height,
    double dx,
    double dy,
    int delayMs,
  ) {
    final size = math.Random().nextInt(10) + 10.0;

    return Positioned(
      left: dx * width,
      top: dy * height,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(value * math.pi * 2) * 10,
              math.cos(value * math.pi * 2) * 10,
            ),
            child: Opacity(
              opacity: 0.6 * value,
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
        },
      ),
    );
  }
}
