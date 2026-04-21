import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// ROOT APP
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp build");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      themeAnimationDuration: Duration.zero, // Add this to disable animation
      home: LifecycleDemo(
        title: isDark ? "Dark Mode" : "Light Mode",
        onToggleTheme: () {
          setState(() {
            isDark = !isDark;
          });
        },
      ),
    );
  }
}

/// CHILD WIDGET
class LifecycleDemo extends StatefulWidget {
  final String title;
  final VoidCallback onToggleTheme;

  const LifecycleDemo({
    super.key,
    required this.title,
    required this.onToggleTheme,
  });

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    debugPrint("initState");
    textController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("didChangeDependencies → Theme changed or MediaQuery updated");
  }

  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.title != widget.title) {
      debugPrint(
        "didUpdateWidget → Title changed from '${oldWidget.title}' to '${widget.title}'",
      );
    }
  }

  @override
  void dispose() {
    debugPrint("dispose");
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");

    // Adding this line registers this State as a dependent of the Theme InheritedWidget.
    // Now, whenever the MaterialApp provides a new Theme, didChangeDependencies WILL be called.
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use the theme
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter something",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                debugPrint("Text: ${textController.text}");
              },
              child: const Text("Print Text"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onToggleTheme,
              child: const Text("Toggle Theme"),
            ),
          ],
        ),
      ),
    );
  }
}
