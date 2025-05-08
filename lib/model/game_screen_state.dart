import 'package:loveloveraid/model/dialogue_line.dart';

class GameScreenState {
  final List<DialogueLine> dialogueQueue;
  final bool isDialoguePlaying;
  final bool isWaitingForTap;
  final String visibleText;
  final DialogueLine? currentLine;
  final bool isLoading;
  final String? sessionId;
  final Set<String> appearedCharacters;
  final Set<String> animatedCharacters;
  final List<DialogueLine> dialogueHistory;
  final int currentHistoryIndex;
  final bool isInHistoryView;
  final bool isUIVisible;

  GameScreenState({
    this.dialogueQueue = const [],
    this.isDialoguePlaying = false,
    this.isWaitingForTap = false,
    this.visibleText = '',
    this.currentLine,
    this.isLoading = false,
    this.sessionId,
    this.appearedCharacters = const {},
    this.animatedCharacters = const {},
    this.dialogueHistory = const [],
    this.currentHistoryIndex = -1,
    this.isInHistoryView = false,
    this.isUIVisible = true,
  });

  GameScreenState copyWith({
    List<DialogueLine>? dialogueQueue,
    bool? isDialoguePlaying,
    bool? isWaitingForTap,
    String? visibleText,
    DialogueLine? currentLine,
    bool? isLoading,
    String? sessionId,
    Set<String>? appearedCharacters,
    Set<String>? animatedCharacters,
    List<DialogueLine>? dialogueHistory,
    int? currentHistoryIndex,
    bool? isInHistoryView,
    bool? isUIVisible,
  }) {
    return GameScreenState(
      dialogueQueue: dialogueQueue ?? this.dialogueQueue,
      isDialoguePlaying: isDialoguePlaying ?? this.isDialoguePlaying,
      isWaitingForTap: isWaitingForTap ?? this.isWaitingForTap,
      visibleText: visibleText ?? this.visibleText,
      currentLine: currentLine ?? this.currentLine,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      appearedCharacters: appearedCharacters ?? this.appearedCharacters,
      animatedCharacters: animatedCharacters ?? this.animatedCharacters,
      dialogueHistory: dialogueHistory ?? this.dialogueHistory,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      isInHistoryView: isInHistoryView ?? this.isInHistoryView,
      isUIVisible: isUIVisible ?? this.isUIVisible,
    );
  }
}
