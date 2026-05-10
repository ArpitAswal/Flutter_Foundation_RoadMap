import 'package:flutter/material.dart';
import 'presentation/views/networking_home_screen.dart';
export 'presentation/views/networking_home_screen.dart';

// =============================================================================
// 🚀 API Networking Module — Entry Point
// =============================================================================
//
// USAGE (standalone — change main.dart target):
  void main() => runApp(const ApiNetworkingApp());
// =============================================================================

class ApiNetworkingApp extends StatelessWidget {
  const ApiNetworkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Networking — Flutter Foundation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const NetworkingHomeScreen(),
    );
  }
}
