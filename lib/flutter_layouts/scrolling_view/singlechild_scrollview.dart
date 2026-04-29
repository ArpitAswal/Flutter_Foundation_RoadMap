import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: SingleChildScrollExample(), debugShowCheckedModeBanner: false));

class SingleChildScrollExample extends StatelessWidget {
  const SingleChildScrollExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SingleChildScrollView")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20), // Adds space around the entire scrolling.
        primary: true, // When true, it uses the primary ScrollController of the app (often used for "scroll to top" functionality in iOS)
        reverse: false, // If true, the view starts at the bottom and scrolls up.
        physics: BouncingScrollPhysics(), // ust like ListView, you can set this to BouncingScrollPhysics() or NeverScrollableScrollPhysics() if you want to disable scrolling temporarily.
        child: //Unlike ListView, this takes only one child (usually a Column or a ConstrainedBox).
        Column(
          children: [
            // A mix of different widgets
            Container(height: 300, color: Colors.red, child: Center(child: Text("Header"))),
            SizedBox(height: 20),
            Text(
              "This is a long piece of text that might overflow on a small screen. "
                  "By wrapping this Column in a SingleChildScrollView, we ensure the "
                  "user can scroll down to see everything without getting 'Pixel Overflow' errors.",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(decoration: InputDecoration(labelText: "Enter Name")),
            TextField(decoration: InputDecoration(labelText: "Enter Email")),
            SizedBox(height: 20),
            Container(height: 400, color: Colors.green, child: Center(child: Text("Footer"))),
          ],
        ),
      ),
    );
  }
}