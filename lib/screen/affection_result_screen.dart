import 'package:flutter/material.dart';
import 'package:loveloveraid/screen/end_screen.dart';
import 'package:provider/provider.dart';
import 'package:loveloveraid/providers/player_provider.dart';

class AffectionResultScreen extends StatelessWidget {
  const AffectionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context).player;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '이번 주 호감도 결과',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade400,
              ),
            ),
            const SizedBox(height: 20),
            ...player.affectionScore.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${entry.key}: ${entry.value}점',
                  style: TextStyle(fontSize: 18, color: Colors.pink.shade300),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 220,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pushAndRemoveUntil(
                      // 처음 화면으로 돌아가기
                      MaterialPageRoute(
                        builder: (context) => const EndScreen(),
                      ),
                      (route) => false,
                    ),
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shadowColor: Colors.pinkAccent.withOpacity(0.4),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.pink.shade200, width: 2),
                  ),
                ),
                child: const Text(
                  '처음으로 돌아가기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
