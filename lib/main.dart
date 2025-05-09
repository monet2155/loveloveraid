import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loveloveraid/screen/title_screen.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loveloveraid/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    await dotenv.load(fileName: ".env.local");
  } else {
    await dotenv.load(); // ✅ .env 로드
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    const minSize = Size(1280, 720);
    const maxSize = Size(1920, 1080);
    setWindowTitle('러브러브 레이드');
    setWindowMinSize(minSize);
    setWindowMaxSize(maxSize);
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '러브러브 레이드',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'NanumGothic', brightness: Brightness.dark),
      home: const TitleScreen(),
    );
  }
}
