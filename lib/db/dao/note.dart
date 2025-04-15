import 'package:note_ai_intergrate/db/dbhelper.dart';
import 'package:note_ai_intergrate/db/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class NoteDAO {

  
  final dbHelper = DatabaseHelper() ;

  Future<Database> get database async {
    return await dbHelper.database;
  }
  
  Future<int> createNote(Note note) async {
    final db = await database;
    int id = await db.insert(dbHelper.tableNameNote, note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      dbHelper.tableNameNote,
      orderBy: '${dbHelper.columnCreatedAtNote} DESC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }


  Future<Note?> getNote(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      dbHelper.tableNameNote,
      where: '${dbHelper.columnIdNote} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    }).first;
  }


  Future<int> updateNote(int id, Note note) async {
    final db = await database;
    int result = await db.update(
      dbHelper.tableNameNote,
      note.toMap(),
      where: '${dbHelper.columnIdNote} = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    int result = await db.delete(
      dbHelper.tableNameNote,
      where: '${dbHelper.columnIdNote} = ?',
      whereArgs: [id],
    );
    return result;
  }
  

}