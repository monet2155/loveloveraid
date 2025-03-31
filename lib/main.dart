import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loveloveraid/screen/game_screen.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    return const MaterialApp(
      title: '러브러브 레이드',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
