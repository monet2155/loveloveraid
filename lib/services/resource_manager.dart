import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:loveloveraid/model/character_resource_dto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  late Directory _resourcesDir;
  bool _isInitialized = false;
  late encrypt.Key _encryptionKey;
  late encrypt.Encrypter _encrypter;

  // 이미지 캐시 추가
  final Map<String, Uint8List> _imageCache = {};

  // 이미지 URL 캐시 추가
  final Map<String, String> _imageUrlCache = {};

  // 이미지 캐시 getter 추가
  Map<String, Uint8List> get imageCache => _imageCache;

  // 이미지 URL 캐시 getter 추가
  Map<String, String> get imageUrlCache => _imageUrlCache;

  bool get isInitialized => _isInitialized;

  int latestVersion = 0;
  int currentVersion = 0;

  List<String> resourceNames = [];
  List<CharacterResourceDto> characterResources = [];

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 웹 환경에서는 Firebase Storage에서 직접 다운로드
    if (kIsWeb) {
      print('웹 환경에서 Firebase Storage에서 이미지를 다운로드합니다.');
      await fetchCharacterResources();
      _isInitialized = true;
      return;
    }

    final appDir = await getApplicationSupportDirectory();
    _resourcesDir = Directory(path.join(appDir.path, 'game_resources'));

    final keyString = dotenv.env['FILE_DOWNLOAD_SECRET'];
    if (keyString == null || keyString.length != 32) {
      throw Exception('FILE_DOWNLOAD_SECRET 환경 변수가 설정되지 않았거나 32바이트가 아님.');
    }
    _encryptionKey = encrypt.Key.fromUtf8(keyString);
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    await fetchCharacterResources();
    _isInitialized = true;
  }

  Future<void> fetchCharacterResources() async {
    final firestore = FirebaseFirestore.instance;
    final characterResourcesRef = firestore.collection('character');
    final characterResourcesDoc = await characterResourcesRef.get();
    final characterResourcesData =
        characterResourcesDoc.docs
            .map(
              (doc) => CharacterResourceDto.fromJson({
                'id': doc.id,
                'name': doc.data()['name'],
              }),
            )
            .toList();
    characterResources = characterResourcesData;
  }

  Future<void> update({void Function(double)? onProgress}) async {
    // 웹 환경에서는 업데이트 건너뛰기
    if (kIsWeb) {
      print('웹 환경에서는 리소스 업데이트를 건너뜁니다.');
      return;
    }

    if (!await checkForUpdates()) {
      return;
    }

    try {
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
    print(versionData?['resources']);
    resourceNames =
        (versionData?['resources'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
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

    int completedItems = 0;
    final totalItems = resourceNames.length;

    print('resourceNames: ${resourceNames.length}');

    for (var name in resourceNames) {
      final item = resourcesRef.child(name);
      final downloadUrl = await item.getDownloadURL();
      final fileName = item.name;
      final localFile = File(path.join(_resourcesDir.path, fileName));
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

    // 웹 환경에서는 로컬 파일 경로 사용 불가
    if (kIsWeb) {
      throw Exception('웹 환경에서는 로컬 파일 시스템에 접근할 수 없습니다.');
    }

    return path.join(_resourcesDir.path, fileName);
  }

  Future<String> readEncryptedJson(String fileName) async {
    // 웹 환경에서는 로컬 파일 읽기 불가
    if (kIsWeb) {
      throw Exception('웹 환경에서는 로컬 파일을 읽을 수 없습니다.');
    }

    final file = File(getResourcePath(fileName));
    final content = jsonDecode(await file.readAsString());
    final iv = encrypt.IV.fromBase64(content['iv']);
    final encrypted = encrypt.Encrypted.fromBase64(content['data']);
    return _encrypter.decrypt(encrypted, iv: iv);
  }

  Future<Uint8List> readEncryptedBinary(String fileName) async {
    try {
      print('readEncryptedBinary 호출: $fileName');

      // 캐시된 이미지가 있으면 반환
      if (_imageCache.containsKey(fileName)) {
        print('캐시된 이미지 반환: $fileName');
        return _imageCache[fileName]!;
      }

      // 웹 환경에서는 캐시된 이미지만 사용
      if (kIsWeb) {
        throw Exception('웹 환경에서 이미지가 캐시에 없습니다: $fileName');
      }

      final file = File(getResourcePath(fileName));
      final bytes = await file.readAsBytes();
      final iv = encrypt.IV(Uint8List.sublistView(bytes, 0, 16));
      final encryptedBytes = encrypt.Encrypted(
        Uint8List.sublistView(bytes, 16),
      );
      final decrypted = _encrypter.decryptBytes(encryptedBytes, iv: iv);

      // 이미지 파일인 경우에만 캐시에 저장
      if (fileName.endsWith('.png') || fileName.endsWith('.jpg')) {
        print('캐시에 저장: $fileName');
        _imageCache[fileName] = Uint8List.fromList(decrypted);
      }

      print('readEncryptedBinary 완료: $fileName');
      return Uint8List.fromList(decrypted);
    } catch (e) {
      print('readEncryptedBinary 오류: $e');
      rethrow;
    }
  }

  // 웹 환경용 이미지 URL 가져오기 메서드 추가
  Future<void> downloadImagesForWeb() async {
    try {
      await fetchLatestVersion();
      final storage = FirebaseStorage.instance;
      final resourcesRef = storage.ref().child('resources');

      print('웹 환경에서 ${resourceNames.length}개의 이미지 URL을 가져옵니다.');

      for (var fileName in resourceNames) {
        try {
          final item = resourcesRef.child(fileName);
          final downloadUrl = await item.getDownloadURL();

          _imageUrlCache[fileName] = downloadUrl;
          print('이미지 URL 가져오기 완료: $fileName');
        } catch (e) {
          print('이미지 URL 가져오기 중 오류 발생: $fileName - $e');
        }
      }
    } catch (e) {
      print('웹 이미지 URL 가져오기 중 오류 발생: $e');
      rethrow;
    }
  }

  // 캐시 초기화 메서드 추가
  void clearImageCache() {
    _imageCache.clear();
    _imageUrlCache.clear();
  }
}
