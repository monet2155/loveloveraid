import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  late Directory _resourcesDir;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _resourcesDir = Directory('${appDir.path}/game_resources');

      if (!await _resourcesDir.exists()) {
        print('게임 리소스 디렉토리 생성 중...');
        await _resourcesDir.create(recursive: true);
      }
      await downloadResources();

      _isInitialized = true;
      print('게임 리소스 초기화 완료');
    } catch (e) {
      print('게임 리소스 초기화 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<void> downloadResources() async {
    final storage = FirebaseStorage.instance;
    final resourcesRef = storage.ref().child('resources');
    final result = await resourcesRef.listAll();

    for (var item in result.items) {
      final downloadUrl = await item.getDownloadURL();
      final fileName = item.name;
      final localFile = File('${_resourcesDir.path}/$fileName');

      if (fileName.endsWith('.json')) {
        final response = await http.get(Uri.parse(downloadUrl));
        if (response.statusCode == 200) {
          await localFile.writeAsString(response.body);
        }
      } else {
        final response = await http.get(Uri.parse(downloadUrl));
        if (response.statusCode == 200) {
          await localFile.writeAsBytes(response.bodyBytes);
        }
      }
    }
  }

  String getResourcePath(String fileName) {
    if (!_isInitialized) {
      throw Exception('ResourceManager가 초기화되지 않았습니다.');
    }
    return '${_resourcesDir.path}/$fileName';
  }
}
