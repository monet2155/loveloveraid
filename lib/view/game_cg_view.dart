import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:loveloveraid/services/resource_manager.dart';
import 'package:loveloveraid/screen/game_menu_button_screen.dart';

class CgGameView extends StatefulWidget {
  const CgGameView({Key? key}) : super(key: key);
  @override
  State<CgGameView> createState() => _CgGameViewState();
}

class _CgGameViewState extends State<CgGameView> {
  final String cgImageFileName = 'CG001.png';
  Uint8List? _imageBytes;
  bool _loadingError = false;

  @override
  void initState() {
    super.initState();
    _loadCgImage();
  }

  Future<void> _loadCgImage() async {
    try {
      final bytes = await ResourceManager().readEncryptedBinary(cgImageFileName);
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print('CG 이미지 로딩 실패: $e');
      if (mounted) {
        setState(() {
          _loadingError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.memory(
        ResourceManager().imageCache['${cgImageFileName}']!,
        fit: BoxFit.cover,
      ),
    );
  }
}