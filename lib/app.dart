import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/preferences_repository.dart';

class UcookApp extends ConsumerWidget {
  const UcookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesNotifierProvider);
    final router = createAppRouter(initialOnboardingDone: prefs.onboardingDone);

    return MaterialApp.router(
      title: 'U-Cook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
