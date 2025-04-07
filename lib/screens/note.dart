import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' ;
import '../components/chat.dart';

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> with WidgetsBindingObserver {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false ; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(() {
      setState(() {
        _isTyping = _focusNode.hasFocus;
      });
    });
    // Wait for frame, then request focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); // more direct and reliable
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notes'),
        actions: [
          Visibility(
            visible: _isTyping,
          child: 
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _isTyping = false;
              });

            },
            child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
          ),
          )
          
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: 
          
          QuillEditor(
            configurations: QuillEditorConfigurations(controller: _controller, autoFocus: true, expands: true, padding: EdgeInsets.zero),
            focusNode: _focusNode,
            scrollController: _scrollController,
            
          ),
          
          
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.zero, // Tùy chỉnh khoảng cách của dialog
              contentPadding: EdgeInsets.zero, // Bỏ padding của content
              content: Container(
                width: double.infinity,
                height: 500, // Kích thước cửa sổ chat
                child: Chat(), // Đây là component Chat bạn đã có
          ))

          );
        },
        child: Icon(Icons.smart_toy),
      ),
    );
  }
}
