import 'package:flutter/material.dart';

/// [DesktopLayout] - Optimized for large screens.
/// Features a top banner and a fluid responsive grid.
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Desktop Layout")),
      body: Column(
        children: [
          // Top Navigation / Banner
          Container(
            width: double.infinity,
            height: 150,
            color: Colors.blue.shade50,
            child: const Center(child: Text("Desktop Banner Navigation")),
          ),
          // Responsive Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: 50,
              itemBuilder: (_, i) =>
                  Card(child: Center(child: Text("Item $i"))),
            ),
          ),
        ],
      ),
    );
  }
}
