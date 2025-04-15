import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_ai_intergrate/db/dao/note.dart';
import 'package:note_ai_intergrate/db/note.dart';

class NoteDetailViewModel extends ChangeNotifier {


  final NoteDAO _noteDAO;

  Note? _note;

  bool _isLoading = false;
  String? errorMessage;


  Document _initDoc = Document();

  Note? get note => _note;
  bool get isLoading => _isLoading;
  String? get error => errorMessage;
  Document get initDoc => _initDoc;

  NoteDetailViewModel({
    required NoteDAO noteDAO,
  }) : _noteDAO = noteDAO;


   Future<void> loadNote(int? noteId) async {
    if (noteId == null) {
      // Trường hợp tạo note mới, không cần load gì cả
      _note = null;
      _initDoc = Document(); // Bắt đầu với document trống
      errorMessage = null;
      _isLoading = false;
      notifyListeners(); // Thông báo trạng thái ban đầu
      return;
    }

    _setLoading(true);


    try {
      _note = await _noteDAO.getNote(noteId);

      if (_note != null) {

        if (_note!.content!.isNotEmpty) {
          try {
            // Giả sử content lưu dạng JSON string của Delta
            final decodedContent = jsonDecode(_note!.content!);
             if (decodedContent is List) { // Quill Delta is List<dynamic>
               _initDoc = Document.fromJson(decodedContent);
             } else {
               print("Decoded content is not a List, starting fresh.");
               _initDoc = Document()..insert(0, _note!.content); // Hoặc insert dạng plain text nếu không phải JSON
             }
          } catch (e) {
            print("Error decoding note content JSON: $e. Treating as plain text.");
            // Nếu không parse được JSON, coi như là plain text
            _initDoc = Document()..insert(0, _note!.content);
          }
          
      }
      else {
        _initDoc = Document(); 
      }

        errorMessage = null;
      } else {
        _setError("Không tìm thấy ghi chú");
        _initDoc = Document();
      }

    }
     catch(e) {
      print("Error loading note $noteId: $e");
      _setError("Không thể tải ghi chú.");
       _initDoc = Document();
      _note = null;
    } finally {
      _setLoading(false);
    }




   }


   Future<bool> saveNote(String title, Document document) async {
    _setLoading(true);
    bool success = false;
    try {
      // --- Quan trọng: Chuyển Document thành JSON string ---
      final deltaJson = document.toDelta().toJson();
      final contentJsonString = jsonEncode(deltaJson);

      if (_note?.id != null) {
        // --- Cập nhật note cũ ---
        final updatedNote = Note(
          id: _note!.id, // Giữ nguyên ID
          title: title,
          content: contentJsonString,
          createdAt: _note!.createdAt, // Giữ lại timestamp cũ hoặc cập nhật nếu muốn
          // Giữ lại timestamp cũ hoặc cập nhật nếu muốn
          updatedAt: DateTime.now()
        );
        await _noteDAO.updateNote(_note!.id!, updatedNote);
        _note = updatedNote; // Cập nhật state nội bộ
        print("Note updated: ${_note!.id}");
        success = true;
      } else {
        // --- Tạo note mới ---
        final newNote = Note(
          id: null, // ID sẽ tự tăng trong DB
          title: title,
          content: contentJsonString,
          createdAt: DateTime.now() ,
          updatedAt: DateTime.now()
        );
        final newId = await _noteDAO.createNote(newNote);
         // Cập nhật state nội bộ với note mới được tạo (có ID)
         _note = Note(id: newId, title: title, content: contentJsonString, updatedAt: newNote.updatedAt, createdAt: newNote.createdAt);
         print("Note created with ID: $newId");
        success = true;
      }
      errorMessage = null;
    } catch (e) {
      print("Error saving note: $e");
      _setError("Không thể lưu ghi chú.");
      success = false;
    } finally {
      _setLoading(false); 
    }
    return success; 
  }

   // --- Helper Methods ---
  void _setLoading(bool value) {
    if (_isLoading == value) return; 
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;

  }

   void clearError() {
     _setError(null);
     notifyListeners();
  }
}

