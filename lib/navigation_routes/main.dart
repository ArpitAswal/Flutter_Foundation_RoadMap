import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_router.dart';
import 'core/app_go_router.dart'; // NEW: GoRouter Config

/// ===========================================================================
/// NAVIGATION & ROUTING ROADMAP
/// ===========================================================================
/// 
/// This module teaches how to build scalable navigation systems in Flutter.
/// It covers both Navigator 1.0 (Imperative) and GoRouter (Declarative).
/// 
/// TO SWITCH DEMOS: 
/// Toggle between 'NavigationApp()' and 'GoNavigationApp()' in the main() function.

void main() => runApp(const GoNavigationApp()); // Currently using GoRouter

// -----------------------------------------------------------------------------
// 1. GOROUTER (DECLARATIVE - NAVIGATOR 2.0)
// -----------------------------------------------------------------------------
/// GoRouter is the recommended way for modern Flutter apps, especially for
/// web support, deep linking, and complex nested routing.
class GoNavigationApp extends StatelessWidget {
  const GoNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoRouter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      // Use routerConfig to hook into GoRouter
      routerConfig: AppGoRouter.router,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. NAVIGATOR 1.0 (IMPERATIVE - TRADITIONAL)
// -----------------------------------------------------------------------------
/// This is the traditional way of navigating in Flutter. 
/// Good for simple apps or where deep linking is not a priority.
class NavigationApp extends StatelessWidget {
  const NavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigator 1.0 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
