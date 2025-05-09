import 'package:flutter/material.dart';
import 'package:loveloveraid/screen/title_screen.dart';
import 'package:loveloveraid/services/resource_manager.dart';

class ResourceDownloadScreen extends StatefulWidget {
  const ResourceDownloadScreen({super.key});

  @override
  State<ResourceDownloadScreen> createState() => _ResourceDownloadScreenState();
}

class _ResourceDownloadScreenState extends State<ResourceDownloadScreen> {
  double _progress = 0.0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      await ResourceManager().update(
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          // 처음 화면으로 돌아가기
          MaterialPageRoute(builder: (context) => const TitleScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('다운로드 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('게임 리소스 다운로드 중...', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${(_progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
