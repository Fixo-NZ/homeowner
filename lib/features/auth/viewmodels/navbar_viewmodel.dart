import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class NavbarViewModel extends StateNotifier<int> {
  NavbarViewModel(Ref ref) : super(0);

  final List<String> navigationPaths = [
    '/dashboard/home',
    '/dashboard/jobs',
    '/dashboard/messages',
    '/dashboard/profile',
    '/dashboard/post',
  ];

  Future<void> navigateTo(BuildContext context, int index) async {
    if (state == index) return;
    state = index;
    if (context.mounted) {
      context.go(navigationPaths[index]);
    }
  }

}

final navbarViewModelProvider = StateNotifierProvider<NavbarViewModel, int>((ref) {
  return NavbarViewModel(ref);
});