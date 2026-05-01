import 'package:flutter/material.dart';

/// [MobileLayout] - Optimized for small screens.
/// Features a vertical list in portrait and a horizontal list in landscape.
class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key, required this.orientation});

  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mobile Layout")),
      body: ListView.builder(
        itemCount: 20,
        scrollDirection: (orientation == Orientation.portrait)
            ? Axis.vertical
            : Axis.horizontal,
        itemBuilder: (_, i) => SizedBox(
          width: 200, // Fixed width for horizontal scrolling
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text("Item $i"),
          ),
        ),
      ),
    );
  }
}
