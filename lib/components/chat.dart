import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatUser currentUser = ChatUser(id: '0', firstName: ' user');
  final ChatUser geminiUser = ChatUser(id: '1', firstName: ' Gemini');
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(
        
      ),
      
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
  setState(() {
    messages = [chatMessage, ...messages];
  });

  String question = chatMessage.text;

  gemini
      .prompt(parts: [Part.text(question)])
      .then((value) {
        String response = value?.output ?? "No response";
        ChatMessage reply = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );
        setState(() {
          messages = [reply, ...messages];
        });
      })
      .catchError((e) {
        print('Error: $e');
        ChatMessage errorMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: "Oops! Something went wrong. Please try again.",
        );
        setState(() {
          messages = [errorMessage, ...messages];
        });
      });
}

}
