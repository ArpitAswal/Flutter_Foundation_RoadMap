import 'package:flutter/material.dart';

class BuilderListViewExample extends StatelessWidget {
  // Imagine this is fetched from an API
  final List<String> items = List<String>.generate(100, (i) => "Item $i");

  BuilderListViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ListView.builder")),
      body: ListView.builder(
        shrinkWrap: false, // true, Forces full height calculation
        itemExtent: 80, //(Optional) If you know your items will all have the same height (e.g., 50.0 pixels), providing this makes the scroll calculation even faster because the engine doesn't have to "guess" the scrollbar position.
        itemCount: items.length, // Tells Flutter how many items are in your list. If you omit this, the list will be infinite.
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8), // Adds space around the entire list of items.
        physics: BouncingScrollPhysics(), // Controls how the list "feels" when you reach the end (e.g., BouncingScrollPhysics for iOS style or ClampingScrollPhysics for Android style).
        itemBuilder: (BuildContext context, int index) { // This is a callback function that takes the context and the current index. It is called only when an item is about to become visible. This is where you return the widget for a specific row.
          return Container(
            decoration: BoxDecoration(
                color: _generateColor(index),
              borderRadius: BorderRadiusGeometry.circular(18)
            ),
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text("${index + 1}")),
              title: Text(items[index], style: TextStyle(color: Colors.white)),
              subtitle: Text("This was built lazily!", style: TextStyle(color: Colors.white)),
              onTap: () => debugPrint("Tapped on ${items[index]}"),
            ),
          );
        },
      ),
    );
  }

  static Color _generateColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF43F5E), // Rose
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[index % colors.length];
  }
}