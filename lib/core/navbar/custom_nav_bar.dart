import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped; // callback for nav item taps
  final VoidCallback onPlusButtonPressed; // callback for FAB

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onPlusButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.work, 'Jobs', 1),
          const SizedBox(width: 40), // space for FAB
          _buildNavItem(Icons.message, 'Messages', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selectedIndex == index ? AppColors.primary : AppColors.onSurfaceVariant,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selectedIndex == index ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
