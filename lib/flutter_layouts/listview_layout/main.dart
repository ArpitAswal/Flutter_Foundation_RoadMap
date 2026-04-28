import 'package:flutter/material.dart';
import 'package:flutter_foundation/flutter_layouts/listview_layout/basic_listview.dart';

import 'listview_builder.dart';
import 'listview_separated.dart';

void main() => runApp(MaterialApp(home: ListViewExamples(), debugShowCheckedModeBanner: false));

class ListViewExamples extends StatelessWidget {
  const ListViewExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ListView Examples"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> BasicListViewExample()));
            }, child: Text("Basic ListView")),
            SizedBox(height: 16),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> BuilderListViewExample()));
            }, child: Text("ListView Builder")),
            SizedBox(height: 16),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SeparatedListViewExample()));
            }, child: Text("ListView Separated")),
          ],
        ),
      )
    );
  }
}
