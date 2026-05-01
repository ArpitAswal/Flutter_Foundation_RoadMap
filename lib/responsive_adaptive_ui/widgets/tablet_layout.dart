import 'package:flutter/material.dart';

/// [TabletLayout] - Optimized for medium screens.
/// Features a split-view sidebar and a 2-column grid.
class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tablet Layout")),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey.shade200,
            child: const Center(child: Text("Sidebar")),
          ),
          // Main Content
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 30,
              itemBuilder: (_, i) =>
                  Card(child: Center(child: Text("Item $i"))),
            ),
          ),
        ],
      ),
    );
  }
}
