import 'package:flutter/material.dart';
import 'presentation/views/async_home_screen.dart';
export 'presentation/views/async_home_screen.dart';

// =============================================================================
// 🚀 Async Programming Module — Entry Point
// =============================================================================
//
// This file provides two things:
//
//   1. `AsyncProgrammingApp`  — A standalone MaterialApp that can be run
//      independently (useful for isolated testing of just this module).
//
//   2. `AsyncHomeScreen`      — The root widget for integration into the
//      main app via Navigator or GoRouter.
//
// USAGE (standalone — change main.dart target):
  void main() => runApp(const AsyncProgrammingApp());
//
// USAGE (integrated into existing navigation):
//   Navigator.of(context).push(
//     MaterialPageRoute(builder: (_) => const AsyncHomeScreen()),
//   );
// =============================================================================

/// Standalone MaterialApp wrapper for the Async Programming module.
///
/// Wraps [AsyncHomeScreen] with a MaterialApp so the module can be run
/// independently without depending on the root app's MaterialApp.
class AsyncProgrammingApp extends StatelessWidget {
  const AsyncProgrammingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Async Programming — Flutter Foundation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AsyncHomeScreen(),
    );
  }
}
