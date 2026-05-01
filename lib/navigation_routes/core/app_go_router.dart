import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/go_home_screen.dart';
import '../screens/details_screen.dart';

/// [AppGoRouter] centralizes the GoRouter configuration.
/// 
/// ❗ DEEP LINKING (The "Why" of GoRouter):
/// GoRouter is built on Navigator 2.0, which is URL-driven. 
/// A URL like 'myapp://profile/123?tab=settings' becomes the SOURCE OF TRUTH.
/// This means Navigation = State. The app's UI is just a reflection of the current URL.
class AppGoRouter {
  // ❗ ROUTE NAMING STRATEGY
  static const String home = '/';
  static const String details = '/details';
  static const String profileBase = '/profile';
  
  // For dynamic paths, use a static method to ensure consistency
  static String profile(String id) => '/profile/$id';

  // Global Navigator Key for the root navigator
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // Shell Navigator Key for the nested navigator
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: home,
    navigatorKey: _rootNavigatorKey,
    
    routes: [
      /// ❗ SHELLROUTE (Persistent UI)
      /// ShellRoute is used to wrap a set of sub-routes with a common UI (like a BottomNavigationBar).
      /// The 'child' parameter is the widget tree of the current sub-route.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: home,
            builder: (context, state) => const GoHomeScreen(),
          ),
          // Profile Tab (with dynamic ID)
          GoRoute(
            path: '/profile/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final tab = state.uri.queryParameters['tab'] ?? 'info';
              return ProfileView(userId: userId, tab: tab);
            },
          ),
        ],
      ),
      
      // Standalone Route (Not part of the Shell/BottomNav)
      // This will cover the entire screen, including the BottomNav.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: details,
        builder: (context, state) {
          final name = state.extra as String? ?? "Guest";
          return DetailsScreen(name: name);
        },
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text("Route not found: ${state.error}")),
    ),
  );
}

/// A wrapper widget that provides the persistent BottomNavigationBar.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine current index based on location
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = location.startsWith('/profile') ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) context.go(AppGoRouter.home);
          if (index == 1) context.go(AppGoRouter.profile('current_user'));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  final String userId;
  final String tab;
  const ProfileView({super.key, required this.userId, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.orange),
            Text("User ID: $userId", style: const TextStyle(fontSize: 24)),
            Text("Tab: $tab", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push(AppGoRouter.details, extra: "From Profile"),
              child: const Text("View Details (Full Screen)"),
            ),
          ],
        ),
      ),
    );
  }
}
