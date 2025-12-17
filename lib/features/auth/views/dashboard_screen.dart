import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/navbar_viewmodel.dart';
import 'navbar/custom_nav_bar.dart';

class DashboardScreen extends ConsumerWidget {
  final Widget child; 
  const DashboardScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child, 
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}