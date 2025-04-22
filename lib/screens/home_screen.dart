import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background design elements
              Positioned(
                top: -50,
                right: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.1),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.large),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo or illustration
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppRadius.extraLarge,
                          ),
                          boxShadow: AppShadows.medium,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // App title
                      Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),

                      const SizedBox(height: 16),

                      // App description
                      Text(
                        '나만의 자기소개 카드를 만들고 공유해보세요!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Start button
                      CustomButton(
                        text: AppStrings.startButton,
                        onPressed: () => context.go('/info'),
                        icon: Icons.arrow_forward_rounded,
                      ),

                      const SizedBox(height: 20),

                      // My cards button
                      CustomButton(
                        text: '내 카드 목록',
                        onPressed: () => context.go('/my-cards'),
                        type: ButtonType.outline,
                        icon: Icons.collections_bookmark_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
