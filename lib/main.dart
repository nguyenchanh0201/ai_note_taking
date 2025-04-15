import 'package:flutter/material.dart';
import 'package:note_ai_intergrate/db/dao/conversation.dart';
import 'package:note_ai_intergrate/db/dao/message.dart';
import 'package:note_ai_intergrate/db/dao/note.dart';
import 'package:note_ai_intergrate/screens/notescreen.dart';
import 'screens/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: dotenv.env['API_KEY'] ?? '');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ConversationDAO>(create: (_) => ConversationDAO()),

        Provider<MessageDAO>(create: (_) => MessageDAO()),

        Provider<Gemini>(create: (_) => Gemini.instance),

        Provider<NoteDAO>(create: (_) => NoteDAO()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const Home(),
          '/note': (context) => const Note(),
        },
        title: 'Note AI',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Home(),
      ),
    );
  }
}
