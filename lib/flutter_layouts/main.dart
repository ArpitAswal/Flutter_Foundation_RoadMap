import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LayoutDemo(),
  ));
}

class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("LayoutDemo build");

    return Scaffold(
      appBar: AppBar(title: const Text("Layout System Demo")),
      body: Column(
        children: [
          // Fixed height container
          Container(
            height: 100,
            color: Colors.blue,
            child: const Center(child: Text("Fixed Height")),
          ),

          // Expanded space
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.red,
                    child: const Center(child: Text("2x Space")),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.green,
                    child: const Center(child: Text("1x Space")),
                  ),
                ),
              ],
            ),
          ),

          // Bottom fixed
          Container(
            height: 80,
            color: Colors.black,
            child: const Center(
              child: Text(
                "Bottom",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}