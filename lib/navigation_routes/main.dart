import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_router.dart';

/// Navigation System (Routes, Data Flow, Architecture)
/// 
/// This module teaches how to build a scalable navigation system using:
/// 1. Navigator 1.0 (Imperative Model)
/// 2. Named Routes for Scalability
/// 3. onGenerateRoute for dynamic routing and data passing
/// 4. Decoupled Route Manager and Generator classes
void main() => runApp(const NavigationApp());

class NavigationApp extends StatelessWidget {
  const NavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      // PRODUCTION BEST PRACTICE:
      // Instead of the 'routes' map, we use 'onGenerateRoute'.
      // This allows for better error handling and passing complex objects.
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
      
      /* 
      Named Routes Comparison (Quick Reference):
      
      1. Basic (Not Scalable): 
         Navigator.push(context, MaterialPageRoute(...));
         
      2. Named Map (Okay for small apps):
         routes: { '/': (context) => HomeScreen() }
         
      3. onGenerateRoute (Scalable / Production Standard):
         Handling everything in a separate Router class.
      */
    );
  }
}
