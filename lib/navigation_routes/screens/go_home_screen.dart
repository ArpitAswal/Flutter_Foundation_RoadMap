import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_go_router.dart';

/// [GoHomeScreen] demonstrates GoRouter-specific navigation methods.
class GoHomeScreen extends StatelessWidget {
  const GoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GoRouter Shell Home"),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "❗ NAVIGATION = STATE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
              ),
              const Text(
                "The URL is the Source of Truth.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              // 1. context.push() - Adds to stack
              ElevatedButton(
                onPressed: () {
                  // Using naming strategy static method
                  context.push(AppGoRouter.details, extra: "Doe (GoRouter)");
                },
                child: const Text("Push Details (Full Screen)"),
              ),
              
              const SizedBox(height: 10),
              
              // 2. Navigation with naming strategy
              ElevatedButton(
                onPressed: () {
                  // Using static method for dynamic path
                  context.go(AppGoRouter.profile('123'));
                  //context.go() - Replace the current location in the stack
                },
                child: const Text("Go to Profile 123 (Shell Tab)"),
              ),

              const SizedBox(height: 20),
              const Divider(),

              // 3. Path Parameters
              ElevatedButton(
                onPressed: () {
                  // Passing dynamic ID in path
                  context.push(AppGoRouter.profile('123'));
                },
                child: const Text("User Profile (Path Param: 123)"),
              ),

              const SizedBox(height: 10),

              // 4. Query Parameters
              ElevatedButton(
                onPressed: () {
                  // Passing data in URL query (e.g. /profile/123?tab=settings)
                  context.push(AppGoRouter.profile('456?tab=settings'));
                },
                child: const Text("User Profile (Query Param: tab=settings)"),
              ),


              const SizedBox(height: 20),
              const Divider(),
              
              const Text(
                "Note how the BottomBar stays visible when switching between Home and Profile. That's ShellRoute!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
