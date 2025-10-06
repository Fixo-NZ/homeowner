import 'package:flutter/material.dart';
import 'package:tradie/core/theme/app_dimensions.dart';
import '../../models/job_category_model.dart';
class JobCategoryTile extends StatelessWidget {
  final JobCategory category;
  final VoidCallback onTap;

  const JobCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 24)), // emoji/icon
              const SizedBox(height: 8),
              Text(
                category.categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.categorySubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
