import 'package:flutter/material.dart';

/// [SelectionScreen] demonstrates returning data to the parent using Navigator.pop(result).
class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select an Option")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("This screen will return a value to the caller."),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Option A"),
              titleAlignment: ListTileTitleAlignment.center,
              onTap: () {
                // Pass data back in the second argument of pop()
                Navigator.pop(context, "Option A");
              },
            ),
            ListTile(
              title: const Text("Option B"),
              titleAlignment: ListTileTitleAlignment.center,
              onTap: () {
                Navigator.pop(context, "Option B");
              },
            ),
          ],
        ),
      ),
    );
  }
}
