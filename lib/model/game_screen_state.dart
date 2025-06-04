import 'package:loveloveraid/model/dialogue_line.dart';

class GameScreenState {
  final String? sessionId;
  final List<DialogueLine> dialogueQueue;
  final DialogueLine? currentLine;
  final String visibleText;
  final bool isDialoguePlaying;
  final bool isWaitingForTap;
  final bool isLoading;
  final Set<String> appearedCharacters;
  final Set<String> animatedCharacters;
  final List<DialogueLine> dialogueHistory;
  final int currentHistoryIndex;
  final bool isInHistoryView;
  final bool isUIVisible;
<<<<<<< HEAD
  final bool isHistoryPopupView;
=======
  final Map<String, String> characterFaces;
>>>>>>> d1009472817351aae0d9adf8423a54818c3d279d

  GameScreenState({
    this.sessionId,
    this.dialogueQueue = const [],
    this.currentLine,
    this.visibleText = '',
    this.isDialoguePlaying = false,
    this.isWaitingForTap = false,
    this.isLoading = false,
    this.appearedCharacters = const {},
    this.animatedCharacters = const {},
    this.dialogueHistory = const [],
    this.currentHistoryIndex = -1,
    this.isInHistoryView = false,
    this.isUIVisible = true,
    this.isHistoryPopupView = false,
    this.characterFaces = const {},
  });

  GameScreenState copyWith({
    String? sessionId,
    List<DialogueLine>? dialogueQueue,
    DialogueLine? currentLine,
    String? visibleText,
    bool? isDialoguePlaying,
    bool? isWaitingForTap,
    bool? isLoading,
    Set<String>? appearedCharacters,
    Set<String>? animatedCharacters,
    List<DialogueLine>? dialogueHistory,
    int? currentHistoryIndex,
    bool? isInHistoryView,
    bool? isUIVisible,
    bool? isHistoryPopupView,
    Map<String, String>? characterFaces,
  }) {
    return GameScreenState(
      sessionId: sessionId ?? this.sessionId,
      dialogueQueue: dialogueQueue ?? this.dialogueQueue,
      currentLine: currentLine ?? this.currentLine,
      visibleText: visibleText ?? this.visibleText,
      isDialoguePlaying: isDialoguePlaying ?? this.isDialoguePlaying,
      isWaitingForTap: isWaitingForTap ?? this.isWaitingForTap,
      isLoading: isLoading ?? this.isLoading,
      appearedCharacters: appearedCharacters ?? this.appearedCharacters,
      animatedCharacters: animatedCharacters ?? this.animatedCharacters,
      dialogueHistory: dialogueHistory ?? this.dialogueHistory,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      isInHistoryView: isInHistoryView ?? this.isInHistoryView,
      isUIVisible: isUIVisible ?? this.isUIVisible,
      isHistoryPopupView: isHistoryPopupView ?? this.isHistoryPopupView,
      characterFaces: characterFaces ?? this.characterFaces,
    );
  }
}
