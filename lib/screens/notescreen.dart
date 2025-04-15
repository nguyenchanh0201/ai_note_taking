import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_ai_intergrate/components/history.dart';
import 'package:note_ai_intergrate/db/dao/note.dart'; // Import DAO
import 'package:note_ai_intergrate/viewmodels/notedetail.dart';
import 'package:provider/provider.dart';


class Note extends StatelessWidget { // Chuyển thành StatelessWidget
  final int? noteId;

  const Note({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    // Cung cấp ViewModel ở đây
    return ChangeNotifierProvider<NoteDetailViewModel>(
      create: (context) => NoteDetailViewModel(
        noteDAO: context.read<NoteDAO>(), // Lấy DAO từ provider cấp cao hơn
      ),
      // Child là widget con chứa UI và logic chính
      child: _NoteEditor(noteId: noteId), // Truyền noteId xuống widget con
    );
  }
}

// --- Widget con: Chứa UI và logic chính, nằm dưới Provider ---
class _NoteEditor extends StatefulWidget {
  final int? noteId;

  const _NoteEditor({this.noteId}); // Nhận noteId

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> with WidgetsBindingObserver {
  // Các controller và state khác giữ nguyên
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isControllerInitialized = false; // Cờ kiểm tra controller Quill
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_handleFocusChange);

    // --- GỌI LOAD DỮ LIỆU TỪ INITSTATE CỦA WIDGET CON ---
    // Context ở đây đã nằm dưới ChangeNotifierProvider nên có thể read ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Kiểm tra widget còn tồn tại không
      if (!mounted) return;
      final viewModel = context.read<NoteDetailViewModel>();
      // Gọi load và sau đó khởi tạo controller
      viewModel.loadNote(widget.noteId).then((_) {
         if (mounted) { // Kiểm tra lại mounted sau khi await
            setState(() {
               _controller = QuillController(
                  document: viewModel.initDoc,
                  selection: const TextSelection.collapsed(offset: 0),
               );
               _titleController.text = viewModel.note?.title ?? '';
               _isControllerInitialized = true; // Đánh dấu sẵn sàng
               _focusNode.requestFocus();
            });
         }
         return ;
      });
    });
  }

   void _handleFocusChange() {
      if (mounted) {
          setState(() {
             _isTyping = _focusNode.hasFocus;
          });
      }
  }

  @override
  void dispose() {
     if (_isControllerInitialized) { // Chỉ dispose nếu đã khởi tạo
       _controller.dispose();
     }
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    _titleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Hàm _saveNoteAndPop giữ nguyên hoặc chỉnh sửa nếu cần
   Future<void> _saveNoteAndPop() async {

      
      if (!_isControllerInitialized) return;

      
        
      final viewModel = context.read<NoteDetailViewModel>();
      final title = _titleController.text.trim();
      final document = _controller.document;


      //Checking empty document
      if (document.toPlainText().trim().isEmpty) {
        Navigator.pop(context);
        return ;
      }
      
      FocusScope.of(context).unfocus();
      setState(() { _isTyping = false; });

      bool success = await viewModel.saveNote(title.isEmpty ? "Untitled Note" : title, document);
      if (!mounted) return;

      if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note saved!"), duration: Duration(seconds: 1),));
          Navigator.pop(context);
          
      } else  {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Save failed: ${viewModel.errorMessage ?? 'Unknown error'}"), backgroundColor: Colors.red,)
           );
      }
  }

  Future<void> _saveNote() async {
      if (!_isControllerInitialized) return;

      final viewModel = context.read<NoteDetailViewModel>();
      final title = _titleController.text.trim();
      final document = _controller.document;


      FocusScope.of(context).unfocus();
      setState(() { _isTyping = false; });

      bool success = await viewModel.saveNote(title.isEmpty ? "Untitled Note" : title, document);

      if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note saved!"), duration: Duration(seconds: 1),));
          
          
      } else if (!success && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Save failed: ${viewModel.errorMessage ?? 'Unknown error'}"), backgroundColor: Colors.red,)
           );
      }
  }


  


  @override
  Widget build(BuildContext context) {
    // --- Lấy ViewModel bằng Consumer hoặc watch/read ---
    // Dùng context.watch để lắng nghe thay đổi và rebuild UI
    final viewModel = context.watch<NoteDetailViewModel>();

    // --- UI ---
    // Hiển thị loading ban đầu (TRƯỚC KHI controller sẵn sàng)
    if (!_isControllerInitialized && viewModel.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Hiển thị lỗi load ban đầu
     if (!_isControllerInitialized && viewModel.errorMessage != null) {
         return Scaffold(body: Center(child: Text("Error loading note: ${viewModel.errorMessage}")));
     }
     // An toàn hơn là kiểm tra controller trước khi dùng
     if (!_isControllerInitialized) {
         return const Scaffold(body: Center(child: Text("Initializing editor...")));
     }

    // Khi Controller đã sẵn sàng
    return Scaffold(
      appBar: AppBar(
         leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios),
           onPressed: _saveNoteAndPop,
         ),
         title: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
               hintText: 'Note Title',
               border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
         ),
         actions: [
           Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: 
              Visibility(
                visible: _isTyping,
                child: InkWell(
                onTap: _saveNote,
                child: Center(
                  child: Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Theme.of(context).primaryColor), // Thêm màu cho rõ
                  ),
                ),
              ),)
              
           ),
           if (viewModel.isLoading) // Loading indicator khi đang lưu
             const Padding(
               padding: EdgeInsets.only(right: 10),
               child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
             ),
         ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            children: [
              
              Expanded(
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: _controller, // Sử dụng _controller đã khởi tạo
                    expands: true,
                    padding: EdgeInsets.zero,
                     sharedConfigurations: const QuillSharedConfigurations(
                       locale: Locale('en'),
                     ),
                  ),
                  focusNode: _focusNode,
                  scrollController: _scrollController,
                ),
              ),
              if (viewModel.errorMessage != null && !viewModel.isLoading) // Hiển thị lỗi lưu
                Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
       floatingActionButton: FloatingActionButton(
         onPressed: () { 
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
                              
                               child: HistoryScreen(), 
                             ),
                       ),
                 );
          },
         child: const Icon(Icons.smart_toy),
       ),
    );
  }
}