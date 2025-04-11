import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: dotenv.env['API_KEY'] ?? '');
  runApp(
    MaterialApp(
      home: MyApp()
    )
    );
}

