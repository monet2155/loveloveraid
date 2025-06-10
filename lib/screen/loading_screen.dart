import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loveloveraid/model/npc.dart';
import 'package:loveloveraid/services/resource_manager.dart';
import 'package:loveloveraid/screen/game_screen.dart';
import 'package:path/path.dart' as path;

class LoadingScreen extends StatefulWidget {
  final List<Npc> npcs;

  const LoadingScreen({super.key, required this.npcs});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _currentFile = '';

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    // 1초 딜레이 추가
    await Future.delayed(const Duration(seconds: 1));
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    try {
      final resourceManager = ResourceManager();
      final resourcesDir = Directory(resourceManager.getResourcePath(''));

      if (!await resourcesDir.exists()) {
        throw Exception('게임 리소스 디렉토리를 찾을 수 없습니다.');
      }

      final imageFiles =
          await resourcesDir
              .list()
              .where(
                (entity) =>
                    entity is File &&
                    (path.extension(entity.path) == '.png' ||
                        path.extension(entity.path) == '.jpg'),
              )
              .toList();

      for (var file in imageFiles) {
        _currentFile = path.basename(file.path);
        await resourceManager.readEncryptedBinary(_currentFile);
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GameScreen(npcs: widget.npcs),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 로딩 중 오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(child: Container(color: Colors.black)),
          // 로딩 인디케이터
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
