import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../screens/home_screen.dart';
import '../screens/details_screen.dart';
import '../screens/selection_screen.dart';

/// [AppRouter] is responsible for generating routes dynamically based on [RouteSettings].
/// This is the "Production Standard" for scaling Flutter navigation.
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // settings.name gives the route name being pushed.
    // settings.arguments contains any data passed during navigation.
    
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.details:
        // Safely extract arguments. In a real app, you'd check the type.
        final String name = settings.arguments as String? ?? "Guest";
        return MaterialPageRoute(
          builder: (_) => DetailsScreen(name: name),
        );

      case AppRoutes.selection:
        return MaterialPageRoute(
          builder: (_) => const SelectionScreen(),
        );

      default:
        // Fallback for unknown routes.
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
