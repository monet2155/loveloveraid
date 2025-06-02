import 'package:flutter/material.dart';

class HistoryPopupView extends StatelessWidget {
  final List<String> logs;

  const HistoryPopupView({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.7),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          // TextSpan(
                          //   text: '${log.speaker}\n',
                          //   style: const TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 18,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          // TextSpan(
                          //   text: log.text,
                          //   style: const TextStyle(
                          //     color: Colors.white70,
                          //     fontSize: 16,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }
}
