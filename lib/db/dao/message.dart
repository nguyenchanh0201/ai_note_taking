import 'package:note_ai_intergrate/db/dbmessage.dart';

import '../dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';




class MessageDAO {

  final dbHelper = DatabaseHelper() ;

  Future<Database> get database async {
    return await dbHelper.database;
  }


  Future<int> createMessage(DbMessage message) async {
    final db = await database;

    int id = await db.insert(dbHelper.messageTable, message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }


  Future<List<DbMessage>> getMessages(int conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      dbHelper.messageTable,
      where: '${dbHelper.colConvId} = ?',
      whereArgs: [conversationId],
      orderBy: '${dbHelper.colMsgTimestamp} ASC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return DbMessage.fromMap(maps[i]);
    });

  } 

}