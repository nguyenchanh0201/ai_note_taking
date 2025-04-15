import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/db/dao/note.dart';
import 'package:note_ai_intergrate/db/note.dart';

class NoteViewModel extends ChangeNotifier {

  final NoteDAO _noteDAO;
  List<Note> _notes = [];
  bool _isLoading = false;
  String? errorMessage;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => errorMessage;

  NoteViewModel({
    required NoteDAO noteDAO,
  }) : _noteDAO = noteDAO {
    getNotes();
  }

  Future<void> getNotes() async {
    _setLoading(true);
    try {
      _notes = await _noteDAO.getNotes();
      errorMessage = null;
    } catch (e) {
      print("Error loading notes: $e");
      _setError("Không thể tải danh sách ghi chú.");
      _notes = []; // Xóa list cũ nếu có lỗi
    } finally {
      _setLoading(false);
    }
  }


  Future<void> deleteNote(int id) async {
    _setLoading(true);
    try {
      await _noteDAO.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      errorMessage = null;
    } catch (e) {
      print("Error deleting note: $e");
      _setError("Không thể xóa ghi chú.");
    } finally {
      _setLoading(false);
    }
  }

  

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
  
}