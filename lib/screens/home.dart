import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/components/notelist.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return NoteList();
  }
}
