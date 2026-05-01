import 'package:flutter/material.dart';
import 'media_query_demo_screen.dart';
import 'responsive_demo_screen.dart';

/// [HomeScreen] is the main menu of the Responsive Adaptive UI demo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Orientation orientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize orientation from MediaQuery
    orientation = MediaQuery.of(context).orientation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Responsive Adaptive UI"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                orientation = orientation == Orientation.portrait
                    ? Orientation.landscape
                    : Orientation.portrait;
              });
            },
            icon: const Icon(Icons.change_circle),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MediaQueryDemoScreen()),
              ),
              child: const Text("Keyboard + SafeArea Example"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResponsiveDemoScreen(orientation: orientation),
                ),
              ),
              child: const Text("LayoutBuilder Example"),
            ),
          ],
        ),
      ),
    );
  }
}
