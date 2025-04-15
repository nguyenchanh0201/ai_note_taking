import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:note_ai_intergrate/db/dao/conversation.dart';
import 'package:note_ai_intergrate/db/dao/message.dart';
import 'package:note_ai_intergrate/db/dbmessage.dart';

class ChatViewModel extends ChangeNotifier {
  final ConversationDAO _conversationDAO ; 
  final MessageDAO _messageDAO ;
  final Gemini _gemini ;



  List<ChatMessage> _messages = [] ;
  int? _currConversationId ;
  bool _isLoading = false ;
  String? errorMessage ;

  List<ChatMessage> get messages => _messages ;
  int? get currConversationId => _currConversationId ;
  bool get isLoading => _isLoading ;
  String? get error => errorMessage ;


  ChatViewModel({
    required ConversationDAO conversationDAO,
    required MessageDAO messageDAO,
    required Gemini gemini,
    int? conversationId,
  })  : _conversationDAO = conversationDAO,
        _messageDAO = messageDAO,
        _gemini = gemini {
          if (conversationId != null) {
            loadConversation(conversationId);
          }
        }
  

  Future<void> loadConversation(int conversationId) async {
    _setLoading(true);
    _currConversationId = conversationId;


    try {
      List<DbMessage> dbMessages = await _messageDAO.getMessages(conversationId);

      final ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
      final ChatUser geminiUser = ChatUser(id: '1', firstName: 'Gemini');

      _messages = dbMessages
      .map((dbMsg) => _dbMessageToChatMessage(dbMsg, currentUser, geminiUser))
      .toList()
      .reversed
      .toList();
      errorMessage = null;

    } catch(e) {
      print("Error loading conversation $conversationId: $e");
      _setError("Không thể tải lịch sử trò chuyện.");
    } finally {
      _setLoading(false);
    }
  }



  Future<void> sendMessage(ChatMessage userMessage) async {
    _setLoading(true);
     _messages = [userMessage, ..._messages];

    notifyListeners();


    try {
      _currConversationId ??= await _conversationDAO.createConversation();
      final userDbMsg = _chatMessageToDbMessage(userMessage, _currConversationId!);
      await _messageDAO.createMessage(userDbMsg);


      final String question = userMessage.text;
      
      _gemini.prompt(parts: [Part.text(question)])
      .then((value) {
        String response = value?.output ?? "No response";
        final ChatUser geminiUser = ChatUser(id: '1', firstName: 'Gemini');
        final ChatMessage reply = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );
        _messages = [reply, ..._messages];
        notifyListeners();


        final botDbMsg = _chatMessageToDbMessage(reply, _currConversationId!);
        _messageDAO.createMessage(botDbMsg);
        
        errorMessage = null;
      });

    } catch(e) {
      print("Error sending message: $e");
      _setError("Không thể gửi tin nhắn.");
    } finally {
      _setLoading(false);
    }
  }




  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  void _setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

   void clearError() {
     _setError(null);
  }

  DbMessage _chatMessageToDbMessage(ChatMessage msg, int conversationId) {
    return DbMessage(
      conversationId: conversationId,
      senderId: msg.user.id,
      text: msg.text,
      timestamp: msg.createdAt.millisecondsSinceEpoch ~/ 1000,
    );
  }


  ChatMessage _dbMessageToChatMessage(DbMessage dbMsg, ChatUser currUser, ChatUser bot) {
    return ChatMessage(
      user: dbMsg.senderId == currUser.id ? currUser : bot,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dbMsg.timestamp * 1000),
      text: dbMsg.text,
    );
  }
}