import 'package:flutter/material.dart';

/// [MediaQueryDemoScreen] demonstrates handling system UI overlaps.
class MediaQueryDemoScreen extends StatelessWidget {
  const MediaQueryDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("MediaQuery Demo")),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: mq.viewInsets.bottom, 
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              TextField(
                decoration: InputDecoration(hintText: "Click here to see keyboard"),
              ),
              SizedBox(height: 12),
              Text("Content adjusts when keyboard appears"),
            ],
          ),
        ),
      ),
    );
  }
}
