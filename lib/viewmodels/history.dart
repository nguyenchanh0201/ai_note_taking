import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/db/conversation.dart';
import 'package:note_ai_intergrate/db/dao/conversation.dart';

class HistoryViewModel extends ChangeNotifier {
  final ConversationDAO _conversationDAO;

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? errorMessage;


  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => errorMessage;

  HistoryViewModel({
    required ConversationDAO conversationDAO,
  }) : _conversationDAO = conversationDAO {
    loadConversations();
  }


  Future<void> loadConversations() async {
    _setLoading(true);
    try {
      _conversations = await _conversationDAO.getConversations();
      errorMessage = null;
    } catch (e) {
      print("Error loading conversations: $e");
      _setError("Không thể tải danh sách cuộc trò chuyện.");
      _conversations = []; // Xóa list cũ nếu có lỗi
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteConversation(int id) async {
    _setLoading(true);
    try {
      await _conversationDAO.deleteConversation(id);
      _conversations.removeWhere((conversation) => conversation.id == id);
      errorMessage = null;
    } catch (e) {
      print("Error deleting conversation: $e");
      _setError("Không thể xóa cuộc trò chuyện.");
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