import 'package:flutter/material.dart';

/// [DetailsScreen] demonstrates how to receive and display data passed from a parent.
class DetailsScreen extends StatelessWidget {
  // Data passed via constructor (Standard if using Navigator.push)
  final String name;

  const DetailsScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Received Data:"),
            Text(
              name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // pop() removes the current screen from the stack
                Navigator.pop(context);
              },
              child: const Text("Go Back (Pop)"),
            ),
          ],
        ),
      ),
    );
  }
}
