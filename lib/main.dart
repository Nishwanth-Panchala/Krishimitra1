import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'app/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KrishiMitraApp(),
    ),
  );
}

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KrishiMitra',
      theme: AppTheme.lightTheme(),
      routerConfig: appRouter,
    );
  }
}
