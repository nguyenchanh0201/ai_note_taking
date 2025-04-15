import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();


  static Database? _database;

  // Chat Database
  static const String _dbName = 'chat_database.db';
  static const String _conversationTable = 'conversations';
  static const String _messageTable = 'messages';

  static const String _colConvId = 'conversation_id';
  static const String _colStartTime = 'start_time';
  static const String _colMsgSenderId = 'sender_id';
  static const String _colMsgText = 'message_text';
  static const String _colMsgTimestamp = 'timestamp';

  
  String get conversationTable => _conversationTable;
  String get messageTable => _messageTable;
  String get colConvId => _colConvId;
  String get colStartTime => _colStartTime;
  String get colMsgSenderId => _colMsgSenderId;
  String get colMsgText => _colMsgText;
  String get colMsgTimestamp => _colMsgTimestamp;
  String get dbName => _dbName;

  //Notes
  static const String tableName = 'notes';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  String get tableNameNote => tableName;
  String get columnIdNote => columnId;
  String get columnTitleNote => columnTitle;
  String get columnContentNote => columnContent;
  String get columnCreatedAtNote => columnCreatedAt;
  String get columnUpdatedAtNote => columnUpdatedAt;

  


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    return _database! ; 
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_conversationTable (
            $_colConvId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colStartTime INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_messageTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colConvId INTEGER NOT NULL,
            $_colMsgSenderId TEXT NOT NULL,
            $_colMsgText TEXT NOT NULL,
            $_colMsgTimestamp INTEGER NOT NULL,
            FOREIGN KEY ($_colConvId) REFERENCES $_conversationTable($_colConvId)
          )
        ''');

        await db.execute('''
          CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnContent TEXT NOT NULL,
            $columnCreatedAt TEXT NOT NULL,
            $columnUpdatedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }



}