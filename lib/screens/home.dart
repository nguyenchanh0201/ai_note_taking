import 'package:flutter/material.dart';
import 'note.dart';

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

    @override
    Widget build (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36.0 ),),
        ),
        body: SafeArea(
          child: Padding(
            padding : const EdgeInsets.all(16.0),
            child: Center(child: Text("You don't have any note yet."),)
          )

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Note(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    }
  }