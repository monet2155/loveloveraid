import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  late Directory _resourcesDir;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  int latestVersion = 0;
  int currentVersion = 0;

  Future<void> initialize({void Function(double)? onProgress}) async {
    if (_isInitialized) return;
    if (!await checkForUpdates()) {
      _isInitialized = true;
      return;
    }

    try {
      final appDir = await getApplicationSupportDirectory();
      _resourcesDir = Directory(path.join(appDir.path, 'game_resources'));

      if (!await _resourcesDir.exists()) {
        print('게임 리소스 디렉토리 생성 중...');
        await _resourcesDir.create(recursive: true);
      }
      print('게임 리소스 업데이트 중...');
      await downloadResources(onProgress: onProgress);

      final pref = await SharedPreferences.getInstance();
      pref.setInt('resource_version', latestVersion);
      _isInitialized = true;
      print('게임 리소스 초기화 완료');
    } catch (e) {
      print('게임 리소스 초기화 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<void> fetchLatestVersion() async {
    print('최신 버전 가져오기 중...');
    final firestore = FirebaseFirestore.instance;
    final versionRef = firestore.collection('config').doc('resource_version');
    final versionDoc = await versionRef.get();
    final versionData = versionDoc.data();
    print('최신 버전: ${versionData?['resource_version']}');
    latestVersion = versionData?['resource_version'] ?? 0;
  }

  Future<bool> checkForUpdates() async {
    await fetchLatestVersion();
    final pref = await SharedPreferences.getInstance();
    final currentVersion = pref.getInt('resource_version');
    print('최신 버전: $latestVersion / 현재 버전: $currentVersion');

    return latestVersion != currentVersion;
  }

  Future<void> downloadResources({void Function(double)? onProgress}) async {
    final storage = FirebaseStorage.instance;
    final resourcesRef = storage.ref().child('resources');
    final result = await resourcesRef.listAll();

    int completedItems = 0;
    final totalItems = result.items.length;

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

      completedItems++;
      if (onProgress != null) {
        onProgress(completedItems / totalItems);
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
