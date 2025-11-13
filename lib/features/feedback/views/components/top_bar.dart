import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHome;

  const TopBar({super.key, required this.onBack, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: onBack,
          ),
          IconButton(icon: const Icon(Icons.home, size: 20), onPressed: onHome),
        ],
      ),
    );
  }
}
