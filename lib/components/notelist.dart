import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/db/dao/note.dart';
import 'package:note_ai_intergrate/screens/notescreen.dart';
import 'package:note_ai_intergrate/viewmodels/note.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class NoteList extends StatelessWidget {
  

  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NoteViewModel>(
      create: (context) => NoteViewModel(noteDAO: context.read<NoteDAO>()),

      child: Builder(
        builder : (context) {
          return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36.0),
          ),
          automaticallyImplyLeading: false
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<NoteViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (viewModel.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(viewModel.errorMessage!),
                    ),
                  );
                } else if (viewModel.notes.isEmpty) {
                  return const Center(
                    child: Text("You don't have any note yet."),
                  );
                } else {
                  return ListView.builder(
                    itemCount: viewModel.notes.length,
                    itemBuilder: (context, index) {
                      final note = viewModel.notes[index];
                      return Dismissible(
                      // --- 1. Key duy nhất ---
                      key: ValueKey(note.id), // Rất quan trọng!

                      // --- 2. Hướng vuốt (từ trái sang phải) ---
                      direction: DismissDirection.endToStart,

                      // --- 3. Widget nền (hiện ra khi vuốt) ---
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
                        // Hàm này được gọi sau khi animation kết thúc
                        print("Đã dismiss note ID: ${note.id}");

                        
                        
                         // Lấy viewModel
                        viewModel.deleteNote(note.id!); // Gọi hàm xóa (bạn cần tạo hàm này trong ViewModel)

                        
                        ScaffoldMessenger.of(context).removeCurrentSnackBar(); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã xóa ghi chú '${note.title ?? 'không có tiêu đề'}'"),
                            
                          ),
                        );
                      },

                     
                      child: Card( 
                         margin: const EdgeInsets.symmetric(vertical: 4.0),
                         child: ListTile(
                          title: Text(note.title.toString()),
                          subtitle: Text(
                            quillDeltaToPlainText(note.content.toString()), // Hiển thị preview
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Note(noteId: note.id),
                              ),
                            ).then((_) {
                              if (!context.mounted) return;
                              context.read<NoteViewModel>().getNotes(); // Refresh list
                            });
                          },
                         ),
                      ),
                    );
                    },
                  );
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/note'),
                builder: (context) => const Note(),
              ),
            ).then((_) {
              context.read<NoteViewModel>().getNotes();
            });
          },
          child: const Icon(Icons.add),
        ),
      )  ;
        }
      )
    );
  }
}


String quillDeltaToPlainText(String deltaJsonString, {int maxLength = 26}) { 
  
  if (deltaJsonString.trim().isEmpty) {
    return '';
  }
  try {
    List<dynamic> decodedJson = jsonDecode(deltaJsonString);
    Document document = Document.fromJson(decodedJson);

    String fullPlainText = document.toPlainText().trim();

    if (fullPlainText.isEmpty) {
      return 'No content available.';
    } else if (fullPlainText.length > maxLength) {
      return '${fullPlainText.substring(0, maxLength)}...';
    }
    else {
      return fullPlainText;
    }

  } catch (e) {

    print("Lỗi chuyển đổi Quill Delta sang plain text: $e");

    return '${deltaJsonString.substring(0, maxLength)}...';
  }
}