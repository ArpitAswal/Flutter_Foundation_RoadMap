import 'package:flutter/material.dart';
import '../core/app_routes.dart';

/// [HomeScreen] demonstrates various Navigator 1.0 techniques.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation Demo"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Navigator Stack Model:\n[Home] -> push -> [Home, Details]",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // 1. Basic Push (Pass Data)
              ElevatedButton(
                onPressed: () {
                  // Standard Imperative Push with data
                  Navigator.pushNamed(
                    context,
                    AppRoutes.details,
                    arguments: "UserName", // Passing data as arguments
                  );
                },
                child: const Text("Go to Details (Pass 'UserName')"),
              ),
              
              const SizedBox(height: 15),
              
              // 2. Receiving Data from Child
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                onPressed: () async {
                  // Await the result from the pushed screen
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.selection,
                  );

                  // Show result in a Snackbar
                  if (context.mounted && result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Received: $result")),
                    );
                  }
                },
                child: const Text("Go to Selection (Wait for Data)"),
              ),
              
              const SizedBox(height: 30),
              const Divider(),
              const Text(
                "Navigator 1.0 (Imperative) is the production standard for most apps.\nNavigator 2.0 (Declarative) is for complex web/deep linking.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
