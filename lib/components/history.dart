import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/components/chat.dart';
import 'package:intl/intl.dart';
import 'package:note_ai_intergrate/db/dao/conversation.dart';
import 'package:note_ai_intergrate/viewmodels/history.dart';
import 'package:provider/provider.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

   // Hàm format timestamp (có thể đặt ở utils)
   String _formatTimestamp(int timestampSeconds) {
     final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000);
     return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
   }

  @override
  Widget build(BuildContext context) {
    // Cung cấp HistoryViewModel cho màn hình này
    return ChangeNotifierProvider<HistoryViewModel>(
      create: (context) => HistoryViewModel(
        // Lấy DAO từ Provider cấp cao hơn
        conversationDAO: context.read<ConversationDAO>(),
      ),
      child: Scaffold( // Scaffold có thể đặt ở đây
         appBar: AppBar(
           title: const Text('Chat History'),
            leading: IconButton(
             icon: const Icon(Icons.arrow_back_ios),
             onPressed: () => Navigator.pop(context),
           ),
          //  backgroundColor: Colors.blueAccent,
           actions: [ // Nút refresh để load lại
              Consumer<HistoryViewModel>( // Consumer chỉ rebuild nút này nếu cần
                 builder:(context, viewModel, child) => IconButton(
                   icon: const Icon(Icons.refresh),
                   onPressed: viewModel.loadConversations, // Gọi load lại
                 ),
              ),
              IconButton(
                onPressed: () => _showChat(context), 
                icon: const Icon(Icons.add_circle_outline),
              ),
           ],
         ),
         body: Consumer<HistoryViewModel>( // Consumer rebuild body khi state thay đổi
             builder: (context, viewModel, child) {
               // --- UI dựa trên state của viewModel ---
               if (viewModel.isLoading) {
                 return const Center(child: CircularProgressIndicator());
               } else if (viewModel.errorMessage != null) {
                 return Center(
                   child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text('Lỗi: ${viewModel.errorMessage!}'),
                         const SizedBox(height: 10),
                         ElevatedButton(
                            onPressed: viewModel.loadConversations, // Thử lại
                            child: const Text("Thử lại"),
                          )
                       ],
                     ),
                   ),
                 );
               } else if (viewModel.conversations.isEmpty) {
                 return const Center(child: Text('Không tìm thấy lịch sử trò chuyện.'));
               } else {
                 // Hiển thị ListView
                 return ListView.builder(
                   itemCount: viewModel.conversations.length,
                   itemBuilder: (context, index) {
                     final conversation = viewModel.conversations[index];
                     return Dismissible(key: ValueKey(conversation.id), 

                     direction: DismissDirection.endToStart,

                     background: Container(
                        color: Colors.red[700], // Màu nền đỏ
                        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding cho icon
                        alignment: Alignment.centerRight, // Căn icon sang trái
                        child: const Row( // Dùng Row để thêm Text nếu muốn
                           mainAxisSize: MainAxisSize.min,
                           children: [
                              Icon(Icons.delete_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Delete", style: TextStyle(color: Colors.white)),
                           ],
                        ),
                      ),


                      onDismissed: (direction) {
                        viewModel.deleteConversation(conversation.id); 

                        ScaffoldMessenger.of(context).removeCurrentSnackBar(); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã xóa cuộc trò chuyện '${conversation.id}'"),
                            
                          ),
                        );

                      },

                     child: Card(
                       margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                       child: ListTile(
                         title: Text('Conversation #${conversation.id}'),
                         subtitle: Text('Bắt đầu: ${_formatTimestamp(conversation.startTime)}'),
                         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                         onTap: () {
                           // Điều hướng tới màn hình Chat, truyền ID để load
                            _showChatScreen(context, conversation.id);
                         },
                       ),
                     ));
                   },
                 );
               }
             },
        ),
      ),
    );
  }
}


void _showChatScreen(BuildContext context, int conversationId) {
  


  showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (context) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.4,
                  maxChildSize: 1.0,
                  expand: false,
                  builder:
                      (context, scrollController) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: ChatScreen(loadConversationId: conversationId), 
                ),
          )
  );
}

void _showChat(BuildContext context) {
  showModalBottomSheet(
                   context: context,
                   isScrollControlled: true,
                   backgroundColor: Colors.transparent,
                   builder:
                       (context) => DraggableScrollableSheet(
                         initialChildSize: 0.8,
                         minChildSize: 0.4,
                         maxChildSize: 1.0,
                         expand: false,
                         builder:
                             (context, scrollController) => Container(
                               decoration: const BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.vertical(
                                   top: Radius.circular(24),
                                 ),
                               ),
                              
                               child: ChatScreen(), 
                             ),
                       ),
                 );
}