// lib/presentation/views/navbar/CenterButton.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeowner/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart'; 
import '../../viewmodels/navbar_viewmodel.dart';

class CenterButton extends ConsumerWidget {
  const CenterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4 is the index for the 'Post' button
    final isSelected = ref.watch(navbarViewModelProvider) == 4;

    return GestureDetector(
      onTap: () => ref.read(navbarViewModelProvider.notifier).navigateTo(context, 4),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer white circle
              Container(
                width: 70,
                height: 70, 
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white54,
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.onPrimary,
                  size: AppDimensions.iconMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            'Post',
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primaryDark : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}