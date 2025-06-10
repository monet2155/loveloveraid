import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loveloveraid/model/npc.dart';
import 'package:loveloveraid/view/player_name_input_screen.dart';
import 'package:loveloveraid/view/title_screen_view.dart';
import 'package:loveloveraid/screen/resource_download_screen.dart';
import 'package:loveloveraid/services/resource_manager.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:loveloveraid/screen/loading_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  List<Npc> npcs = [];
  bool _isCheckingResources = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: const Text('인터넷 연결 오류'),
                  content: const Text('인터넷 연결이 필요합니다'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const TitleScreen(),
                          ),
                        );
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
          );
        }
        return;
      }
      _checkResources();
    } catch (e) {
      print('인터넷 연결 확인 중 오류 발생: $e');
    }
  }

  Future<void> _checkResources() async {
    try {
      final needsUpdate = await ResourceManager().checkForUpdates();
      if (needsUpdate) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: const Text('리소스 업데이트'),
                  content: const Text('게임 리소스 다운로드가 필요합니다.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const ResourceDownloadScreen(),
                          ),
                        );
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
          );
        }
      } else {
        initGame();
      }
    } catch (e) {
      print('리소스 체크 중 오류 발생: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingResources = false;
        });
      }
    }
  }

  void initGame() async {
    await getNpcList();
  }

  Future<void> getNpcList() async {
    final apiUrl = dotenv.env['API_URL'];
    final universeId = dotenv.env['UNIVERSE_ID'];

    final res = await http.get(
      Uri.parse('$apiUrl/universe/$universeId/npcs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final decodedBody = json.decode(utf8.decode(res.bodyBytes));
      final Map<String, dynamic> data = decodedBody;
      setState(() {
        for (var npc in data['npcs']) {
          npcs.add(Npc.fromJson(npc));
        }
      });
    } else {
      print('세션 시작 실패: ${res.statusCode}');
      print('응답 본문: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingResources) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return TitleScreenView(
      onStartNewGame: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => PlayerNameInputScreen(
                  onSubmit: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen(npcs: npcs),
                      ),
                    );
                  },
                ),
          ),
        );
      },
      onContinue: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('이어하기'),
                content: const Text('이어하기 기능은 아직 구현되지 않았습니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      },
      onOpenSettings: () {
        // TODO: 설정 화면으로 이동
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('설정'),
                content: const Text('설정 화면은 준비 중입니다'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      },
      onExitGame: () {
        if (Platform.isAndroid || Platform.isIOS) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('종료 확인'),
                  content: const Text('게임을 종료하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => exit(0),
                      child: const Text('종료'),
                    ),
                  ],
                ),
          );
        } else {
          exit(0);
        }
      },
    );
  }
}
