// lib/presentation/views/navbar/NavBarItem.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeowner/core/theme/app_colors.dart';
import '../../viewmodels/navbar_viewmodel.dart';

class NavBarItem extends ConsumerWidget {
  final int index;
  final String label;

  const NavBarItem({
    super.key,
    required this.index,
    required this.label,
  });

  Widget _getIconWidget(int index, bool isSelected) {
    IconData iconData;
    switch (index) {
      case 0: iconData = isSelected ? Icons.home : Icons.home_outlined; break;
      case 1: iconData = isSelected ? Icons.work : Icons.work_outline; break;
      case 2: iconData = isSelected ? Icons.message : Icons.message_outlined; break;
      case 3: iconData = isSelected ? Icons.person : Icons.person_outline; break;
      default: iconData = Icons.error;
    }
    
    final color = isSelected ? AppColors.primaryDark : AppColors.onSecondary;

    // TODO: Replace this with your PNG loading logic:
    /*
    if (index == 0) {
      return Image.asset(isSelected ? 'assets/home_selected.png' : 'assets/home.png', width: 24, height: 24);
    }
    */

    return Icon(iconData, color: color, size: 24);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navbarViewModelProvider);
    final navbarViewModel = ref.read(navbarViewModelProvider.notifier);
    final isSelected = selectedIndex == index;
    final effectiveLabel = index == 3 ? 'Profile' : label;

    return Expanded(
      child: GestureDetector(
        onTap: () => navbarViewModel.navigateTo(context, index), 
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getIconWidget(index, isSelected),
              Text(
                effectiveLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF090C9B) : Colors.black54,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}