import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loveloveraid/screen/title_screen.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    await dotenv.load(fileName: ".env.local");
  } else {
    await dotenv.load(); // ✅ .env 로드
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    const size = Size(1280, 720);
    setWindowTitle('러브러브 레이드');
    setWindowMinSize(size);
    setWindowMaxSize(size); // 최소, 최대를 같게 설정 → 리사이징 불가
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
