import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

class TrackBitApp extends ConsumerWidget {
  const TrackBitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = appRouter(ref);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'TrackBit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
