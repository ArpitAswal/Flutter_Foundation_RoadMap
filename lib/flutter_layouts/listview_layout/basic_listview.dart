import 'package:flutter/material.dart';

class BasicListViewExample extends StatelessWidget {
  const BasicListViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Basic ListView")),
      body: ListView(
        scrollDirection: Axis.vertical, // Defaults to Axis.vertical, but can be set to Axis.horizontal.
        reverse: false, // If true, the list scrolls from the bottom to the top (useful for chat apps).
        padding: EdgeInsets.all(16.0), // Adds space around the entire list of items.
        physics: BouncingScrollPhysics(), // Controls how the list "feels" when you reach the end (e.g., BouncingScrollPhysics for iOS style or ClampingScrollPhysics for Android style).
        children: <Widget>[ // A List<Widget> that contains everything you want to show.
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
            subtitle: Text('Open the navigation view'),
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Album'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
          ),
          // You can add any widget here
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
            subtitle: Text('Open the navigation view'),
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Album'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
          Container(
            height: 100,
            color: Colors.blueAccent,
            child: Center(child: Text("I'm a Container in a List!")),
          ),
        ],
      ),
    );
  }
}