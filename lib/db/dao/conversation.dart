import 'package:note_ai_intergrate/db/conversation.dart';

import '../dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class ConversationDAO {
  final dbHelper = DatabaseHelper();

  Future<Database> get database async {
    return await dbHelper.database;
  }

  Future<int> createConversation() async {
    final db = await database;

    int startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    int id = await db.insert(dbHelper.conversationTable, {
      dbHelper.colStartTime: startTime,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Conversation>> getConversations() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      dbHelper.conversationTable,
      orderBy: '${dbHelper.colStartTime} DESC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Conversation.fromMap(maps[i]);
    });
  }

  Future<Conversation?> getConversationById(int id) async {
    final db = await database ; 

    final List<Map<String, dynamic>> maps = await db.query(
      dbHelper.conversationTable,
      where: '${dbHelper.colConvId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Conversation.fromMap(maps.first);
  }

  Future<int> deleteConversation(int id) async {
    final db = await database;

    return await db.delete(
      dbHelper.conversationTable,
      where: '${dbHelper.colConvId} = ?',
      whereArgs: [id],
    );
  }
}
