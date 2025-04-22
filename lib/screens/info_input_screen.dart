import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_card.dart';
import '../providers/card_provider.dart';
import '../utils/constants.dart';
import '../widgets/card_preview.dart';
import '../widgets/custom_button.dart';

class InfoInputScreen extends ConsumerStatefulWidget {
  const InfoInputScreen({super.key});

  @override
  ConsumerState<InfoInputScreen> createState() => _InfoInputScreenState();
}

class _InfoInputScreenState extends ConsumerState<InfoInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '20');
  final _mbtiController = TextEditingController(text: 'INFP');
  final _introController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get current card data from provider
    final currentCard = ref.read(currentCardProvider);

    // Initialize controllers with current data if available
    _nameController.text = currentCard.name;
    _ageController.text = currentCard.age.toString();
    _mbtiController.text = currentCard.mbti;
    _introController.text = currentCard.introduction;

    // Listen to text changes to update the card preview
    _nameController.addListener(_updateCardPreview);
    _ageController.addListener(_updateCardPreview);
    _mbtiController.addListener(_updateCardPreview);
    _introController.addListener(_updateCardPreview);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mbtiController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _updateCardPreview() {
    final currentCard = ref.read(currentCardProvider);

    final updatedCard = currentCard.copyWith(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? 20,
      mbti: _mbtiController.text,
      introduction: _introController.text,
    );

    ref.read(currentCardProvider.notifier).state = updatedCard;
  }

  @override
  Widget build(BuildContext context) {
    // Get current card from provider for preview
    final currentCard = ref.watch(currentCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보 입력'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Card preview (smaller size)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CardPreview(card: currentCard, scale: 0.7),
            ),

            // Form inputs in a scrollable area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppPadding.medium),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name input
                      const Text(
                        AppStrings.nameLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '이름을 입력하세요',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Age input
                      const Text(
                        AppStrings.ageLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '나이를 입력하세요',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '나이를 입력해주세요';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age <= 0) {
                            return '올바른 나이를 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // MBTI input
                      const Text(
                        AppStrings.mbtiLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mbtiController,
                        decoration: const InputDecoration(
                          hintText: 'MBTI를 입력하세요 (예: INFP)',
                          prefixIcon: Icon(Icons.psychology_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'MBTI를 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Introduction input
                      const Text(
                        AppStrings.introLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _introController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: '자기소개를 입력하세요',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '자기소개를 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Image upload (UI only in this example)
                      const Text(
                        AppStrings.imageLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          // Image picker would be implemented here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('이미지 선택 기능은 구현 예정입니다.'),
                            ),
                          );
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            border: Border.all(
                              color: AppColors.divider,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 40,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '프로필 사진 추가',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Next button
                      CustomButton(
                        text: AppStrings.nextButton,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.go('/customize');
                          }
                        },
                        icon: Icons.arrow_forward_rounded,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
