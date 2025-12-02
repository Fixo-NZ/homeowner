import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homeowner/features/job_posting/models/job_posting_models.dart';

class JobTypeToggle extends StatelessWidget {
  final JobType currentType;
  final Function(JobType) onChanged;

  const JobTypeToggle({
    super.key,
    required this.currentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            label: 'Standard Job',
            iconPath: 'assets/icons/standard_job.svg',
            isSelected: currentType == JobType.standard,
            onTap: () => onChanged(JobType.standard),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            label: 'Recurring Job',
            iconPath: 'assets/icons/recurring_job.svg',
            isSelected: currentType == JobType.recurrent,
            onTap: () => onChanged(JobType.recurrent),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor =
        isSelected ? const Color(0xFF007BFF) : const Color(0xFFE6E6E6);
    final backgroundColor = isSelected ? const Color(0xFFE8F1FF) : Colors.white;
    final iconColor = isSelected ? const Color(0xFF007BFF) : Colors.black;
    final textColor = iconColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
