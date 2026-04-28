import 'package:flutter/material.dart';

class SeparatedListViewExample extends StatelessWidget {
  final List<String> entries = <String>['Message A', 'Message B', 'Message C', 'Message A', 'Message B', 'Message C', 'Message A', 'Message B', 'Message C', 'Message A', 'Message B', 'Message C', 'Message A', 'Message B', 'Message C'];

  SeparatedListViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ListView.separated")),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        // The main content
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            color: Colors.amber[100],
            child: Center(child: Text('Entry ${entries[index]}')),
          );
        },
        // Works just like itemBuilder, but it renders a widget between items. Note that it does not add a separator before the first item or after the last one.
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.black,
          thickness: 2,
        ),
      ),
    );
  }
}