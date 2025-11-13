import 'package:flutter/material.dart';

class TabList extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const TabList({super.key, required this.activeTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabChange('reviews'),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: activeTab == 'reviews'
                    ? const Color(0xFF090C9B)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'REVIEWS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: activeTab == 'reviews'
                      ? Colors.white
                      : const Color(0xFF374151),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabChange('rate'),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: activeTab == 'rate'
                    ? const Color(0xFF090C9B)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'RATE SERVICE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: activeTab == 'rate'
                      ? Colors.white
                      : const Color(0xFF374151),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
