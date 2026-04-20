import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Root App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp build");
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterScreen(),
    );
  }
}

/// Main Screen
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    debugPrint("CounterScreen build");

    return Scaffold(
      appBar: AppBar(title: const Text("Architecture Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CounterText(counter: counter),
            const StaticLabel(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB Pressed");
          setState(() {
            counter++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Dynamic Widget (depends on state)
class CounterText extends StatelessWidget {
  final int counter;

  const CounterText({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    debugPrint("CounterText build");
    return Text(
      "Counter: $counter",
      style: const TextStyle(fontSize: 24),
    );
  }
}

/// Static Widget (should ideally not rebuild often)
class StaticLabel extends StatelessWidget {
  const StaticLabel({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("StaticLabel build");
    return const Text("I am static");
  }
}