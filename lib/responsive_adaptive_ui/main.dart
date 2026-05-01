import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// The entry point of the application.
/// 
/// This codebase is structured following a scalable Flutter architecture:
/// - [core/]: Centralized enums, constants, and global utilities.
/// - [widgets/]: Reusable UI components and responsive layout builders.
/// - [screens/]: Full-page widgets representing different routes.
void main() => runApp(
      const MaterialApp(
        title: 'Responsive Adaptive UI',
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
