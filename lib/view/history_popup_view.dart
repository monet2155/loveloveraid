import 'package:flutter/material.dart';
import 'package:loveloveraid/model/dialogue_line.dart';

class HistoryPopupView extends StatelessWidget {
  final List<DialogueLine> logs;
  final int currentDialogueIndex;
  final VoidCallback onClose;

  const HistoryPopupView({
    super.key,
    required this.logs,
    required this.currentDialogueIndex,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final visibleLogs = logs.take(currentDialogueIndex + 1).toList();

    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.7),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {}, // 내부 터치로 팝업 닫힘 방지
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: visibleLogs.length,
                  itemBuilder: (context, index) {
                    final log = visibleLogs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${log.character}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: log.text,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onClose, child: const Text('닫기')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// 작은 화면 버전
// class HistoryPopupView extends StatelessWidget {
//   final List<DialogueLine> logs;
//   final VoidCallback onClose;

//   const HistoryPopupView({
//     super.key,
//     required this.logs,
//     required this.onClose,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onClose,
//       child: Container(
//         color: Colors.black.withOpacity(0.7),
//         child: Center(
//           child: GestureDetector(
//             onTap: () {}, // 내부 터치 무시 (닫힘 방지)
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: MediaQuery.of(context).size.height * 0.6,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[900],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: logs.length,
//                       itemBuilder: (context, index) {
//                         final log = logs[index];
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: '${log.character}\n',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: log.text,
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   ElevatedButton(onPressed: onClose, child: const Text('닫기')),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
