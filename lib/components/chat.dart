import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/db/dao/conversation.dart';
import 'package:note_ai_intergrate/db/dao/message.dart';
import 'package:note_ai_intergrate/viewmodels/chat.dart';
import 'package:provider/provider.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter/services.dart';


class ChatScreen extends StatelessWidget {
  // Có thể là StatelessWidget
  final int? loadConversationId;

  const ChatScreen({super.key, this.loadConversationId});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để tạo và cung cấp ViewModel
    // Chỉ cần tạo một lần cho màn hình này
    return ChangeNotifierProvider<ChatViewModel>(
      create:
          (context) => ChatViewModel(
            // Lấy dependencies từ Provider đã cung cấp ở trên
            conversationDAO: context.read<ConversationDAO>(),
            messageDAO: context.read<MessageDAO>(),
            gemini: context.read<Gemini>(),
            conversationId: loadConversationId, // Truyền ID nếu cần load
          ),
      child: Consumer<ChatViewModel>(
        // Dùng Consumer để rebuild khi ViewModel thay đổi
        builder: (context, viewModel, child) {
          // --- UI của bạn dựa trên state từ viewModel ---
          return Scaffold(
            appBar: AppBar(
              title: Text(
                viewModel.currConversationId != null
                    ? 'Chat AI - Conv ${viewModel.currConversationId}'
                    : 'Chat AI',
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => //Navigator.popUntil(context, (ModalRoute.withName('/note'))),
                    Navigator.pop(context),
              ),
              
              // backgroundColor: Colors.blueAccent,
            ),
            body: Column(
              // Thêm Column để hiển thị lỗi nếu có
              children: [
                // Hiển thị lỗi nếu có
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.red[100],
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red[700],
                            ),
                            onPressed:
                                () => viewModel.clearError(), // Nút xóa lỗi
                          ),
                        ],
                      ),
                    ),
                  ),
                // DashChat UI
                Expanded(
                  child: DashChat(
                    currentUser: ChatUser(
                      id: '0',
                      firstName: 'User',
                    ), // Cần lấy user từ đâu đó
                    onSend: viewModel.sendMessage, // Gọi method của ViewModel
                    messages: viewModel.messages, // Lấy messages từ ViewModel
                    messageOptions:  MessageOptions(
                      onLongPressMessage: (ChatMessage message) {
                        _showChatOptions(context, message);
                      },
                  ),
                ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showChatOptions(BuildContext context, ChatMessage chatMessage) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea( // Đảm bảo không bị che bởi notch/bottom bar
          child: Wrap( // Dùng Wrap để các lựa chọn tự xuống dòng nếu cần
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy to Clipboard'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: chatMessage.text))
                      .then((_) {
                    Navigator.pop(context); // Đóng bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  });
                },
              )
            ]
          )
        );
        }
      );

}
