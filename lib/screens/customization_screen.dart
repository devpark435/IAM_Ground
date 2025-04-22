import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_provider.dart';
import '../providers/customization_provider.dart';
import '../utils/constants.dart';
import '../widgets/card_preview.dart';
import '../widgets/custom_button.dart';

class CustomizationScreen extends ConsumerWidget {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCard = ref.watch(currentCardProvider);
    final backgrounds = ref.watch(backgroundsProvider);
    final fonts = ref.watch(fontsProvider);
    final customization = ref.watch(customizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 꾸미기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/info'),
        ),
      ),
      body: Column(
        children: [
          // Card Preview
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CardPreview(
              card: currentCard.copyWith(
                backgroundId: customization.backgroundId,
                filterIntensity: customization.filterIntensity,
                fontFamily: customization.fontFamily,
              ),
              scale: 0.7,
            ),
          ),

          // Customization options
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppPadding.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Background selection
                  const Text(
                    AppStrings.backgroundLabel,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: backgrounds.length,
                      itemBuilder: (context, index) {
                        final bg = backgrounds[index];
                        final isSelected =
                            bg['id'] == customization.backgroundId;

                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(customizationProvider.notifier)
                                .updateBackground(bg['id']);
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow:
                                  isSelected
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.small,
                              ),
                              child: Stack(
                                children: [
                                  // Image placeholder (in real app, load actual thumbnail)
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            bg['id'] == 'bg1'
                                                ? [
                                                  const Color(0xFFFFF3DC),
                                                  const Color(0xFFFFDDDD),
                                                ]
                                                : bg['id'] == 'bg2'
                                                ? [
                                                  const Color(0xFF6B4EFF),
                                                  const Color(0xFF9681FF),
                                                ]
                                                : bg['id'] == 'bg3'
                                                ? [
                                                  const Color(0xFFFF4E91),
                                                  const Color(0xFFFF9B82),
                                                ]
                                                : bg['id'] == 'bg4'
                                                ? [
                                                  const Color(0xFF4ECAFF),
                                                  const Color(0xFF6B4EFF),
                                                ]
                                                : [
                                                  const Color(0xFFFFCA4E),
                                                  const Color(0xFFFF8C4E),
                                                ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),

                                  // Selected indicator
                                  if (isSelected)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 12,
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

                  const SizedBox(height: 24),

                  // Filter intensity slider
                  const Text(
                    AppStrings.filterLabel,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.brightness_low_rounded,
                        color: AppColors.textLight,
                      ),
                      Expanded(
                        child: Slider(
                          value: customization.filterIntensity,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.2),
                          onChanged: (value) {
                            ref
                                .read(customizationProvider.notifier)
                                .updateFilterIntensity(value);
                          },
                        ),
                      ),
                      const Icon(
                        Icons.brightness_high_rounded,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Font selection
                  const Text(
                    AppStrings.fontLabel,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: customization.fontFamily,
                        items:
                            fonts.map((font) {
                              return DropdownMenuItem<String>(
                                value: font['id'],
                                child: Text(
                                  font['name'],
                                  style: TextStyle(fontFamily: font['id']),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(customizationProvider.notifier)
                                .updateFontFamily(value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Apply changes and navigate to share screen
                  CustomButton(
                    text: AppStrings.nextButton,
                    onPressed: () {
                      // Update current card with customization options
                      final updatedCard = currentCard.copyWith(
                        backgroundId: customization.backgroundId,
                        filterIntensity: customization.filterIntensity,
                        fontFamily: customization.fontFamily,
                      );
                      ref.read(currentCardProvider.notifier).state =
                          updatedCard;

                      // Navigate to share screen
                      context.go('/share');
                    },
                    icon: Icons.arrow_forward_rounded,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
