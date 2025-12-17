import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> clearMixedTokens() async {
  final storage = const FlutterSecureStorage();
  
  // Clear all possible conflicting keys
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'user_id');
  await storage.delete(key: 'homeowner_access_token');
  await storage.delete(key: 'homeowner_user_id');
  await storage.delete(key: 'tradie_access_token');
  await storage.delete(key: 'tradie_user_id');
  
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  // Clear old tokens (run once)
  await clearMixedTokens();
  
  runApp(const ProviderScope(child: HomeownerApp()));
}

class HomeownerApp extends ConsumerWidget {
  const HomeownerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Homeowner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
