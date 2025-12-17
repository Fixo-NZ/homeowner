// lib/presentation/views/navbar/CustomNavBar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart'; 
import '../../../../core/theme/app_dimensions.dart';
import '../../viewmodels/navbar_viewmodel.dart';
import 'nav_bar_item.dart';
import 'center_button.dart';

class CustomNavBar extends ConsumerWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navbarViewModelProvider);

    return SizedBox(
      height: 94,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom navigation bar container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 59, 
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant, 
                border: Border(
                  top: BorderSide(color: AppColors.grey300, width: AppDimensions.dividerThickness),
                ),
              ),
              child: const Row(
                children: [
                  // Index 0: Home
                  NavBarItem(index: 0, label: 'Home'),
                  // Index 1: Jobs
                  NavBarItem(index: 1, label: 'Jobs'),
                  
                  Spacer(), 
                  
                  // Index 2: Messages
                  NavBarItem(index: 2, label: 'Messages'),
                  // Index 3: Profile
                  NavBarItem(index: 3, label: 'Profile'),
                ],
              ),
            ),
          ),

          // Floating center button (Index 4)
          const Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: CenterButton(),
            ),
          ),

          // Blue line indicator
          if (selectedIndex != 4 && selectedIndex >= 0 && selectedIndex < 4)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: 58, 
              left: _getIndicatorLeftPosition(context, selectedIndex),
              child: Container(
                width: 70,
                height: 2,
                color: AppColors.primaryDark,
              ),
            ),
        ],
      ),
    );
  }

  double _getIndicatorLeftPosition(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemsCount = 4;
    const segmentWidth = 70.0;

    double position;
    if (index == 0) {
      position = screenWidth * 0.1 - segmentWidth / 2;
    } else if (index == 1) {
      position = screenWidth * 0.3 - segmentWidth / 2;
    } else if (index == 2) {
      position = screenWidth * 0.7 - segmentWidth / 2;
    } else { // index 3
      position = screenWidth * 0.9 - segmentWidth / 2;
    }
    
    return position.clamp(0.0, screenWidth - segmentWidth);
  }
}