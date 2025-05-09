import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  late Directory _resourcesDir;
  bool _isInitialized = false;
  late encrypt.Key _encryptionKey;
  late encrypt.Encrypter _encrypter;

  bool get isInitialized => _isInitialized;

  int latestVersion = 0;
  int currentVersion = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final appDir = await getApplicationSupportDirectory();
    _resourcesDir = Directory(path.join(appDir.path, 'game_resources'));

    final keyString = dotenv.env['FILE_DOWNLOAD_SECRET'];
    if (keyString == null || keyString.length != 32) {
      throw Exception('FILE_DOWNLOAD_SECRET 환경 변수가 설정되지 않았거나 32바이트가 아님.');
    }
    _encryptionKey = encrypt.Key.fromUtf8(keyString);
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    _isInitialized = true;
  }

  Future<void> update({void Function(double)? onProgress}) async {
    if (!await checkForUpdates()) {
      return;
    }

    try {
      final appDir = await getApplicationSupportDirectory();
      _resourcesDir = Directory(path.join(appDir.path, 'game_resources'));
      print('게임 리소스 디렉토리 경로: ${_resourcesDir.path}');
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
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) continue;

      if (fileName.endsWith('.json')) {
        final iv = encrypt.IV.fromSecureRandom(16);
        final encrypted = _encrypter.encrypt(response.body, iv: iv);
        await localFile.writeAsString(
          jsonEncode({'iv': iv.base64, 'data': encrypted.base64}),
        );
      } else {
        final iv = encrypt.IV.fromSecureRandom(16);
        final encrypted = _encrypter.encryptBytes(response.bodyBytes, iv: iv);
        final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
        await localFile.writeAsBytes(combined);
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

  Future<String> readEncryptedJson(String fileName) async {
    final file = File(getResourcePath(fileName));
    final content = jsonDecode(await file.readAsString());
    final iv = encrypt.IV.fromBase64(content['iv']);
    final encrypted = encrypt.Encrypted.fromBase64(content['data']);
    return _encrypter.decrypt(encrypted, iv: iv);
  }

  Future<Uint8List> readEncryptedBinary(String fileName) async {
    try {
      print('readEncryptedBinary 호출: $fileName');
      final file = File(getResourcePath(fileName));
      final bytes = await file.readAsBytes();
      final iv = encrypt.IV(Uint8List.sublistView(bytes, 0, 16));
      final encryptedBytes = encrypt.Encrypted(
        Uint8List.sublistView(bytes, 16),
      );
      final decrypted = _encrypter.decryptBytes(encryptedBytes, iv: iv);
      print('readEncryptedBinary 완료: $fileName');
      return Uint8List.fromList(decrypted);
    } catch (e) {
      print('readEncryptedBinary 오류: $e');
      rethrow;
    }
  }
}
