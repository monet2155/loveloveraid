import 'package:loveloveraid/model/dialogue_line.dart';

class GameScreenState {
  final String? sessionId;
  final List<DialogueLine> dialogues; // dialogue통ㅇ합 작업
  final int currentDialogueIndex; // 현재 보여주고 있는 대화 인덱스
  final int currentHistoryIndex;
  final DialogueLine? currentLine;
  final String visibleText;
  final bool isDialoguePlaying;
  final bool isWaitingForTap;
  final bool isLoading;
  final Set<String> appearedCharacters;
  final Set<String> animatedCharacters;
  final bool isInHistoryView;
  final bool isCgViewVisible;
  final bool isUIVisible;
  final bool isHistoryPopupView;
  final Map<String, String> characterFaces;

  GameScreenState({
    this.sessionId,
    this.dialogues = const [],
    this.currentDialogueIndex = -1,
    this.currentHistoryIndex = 0,
    this.currentLine,
    this.visibleText = '',
    this.isDialoguePlaying = false,
    this.isWaitingForTap = false,
    this.isLoading = false,
    this.appearedCharacters = const {},
    this.animatedCharacters = const {},
    this.isInHistoryView = false,
    this.isCgViewVisible = false,
    this.isUIVisible = true,
    this.isHistoryPopupView = false,
    this.characterFaces = const {},
  });

  GameScreenState copyWith({
    String? sessionId,
    List<DialogueLine>? dialogues,
    int? currentDialogueIndex,
    int? currentHistoryIndex,
    DialogueLine? currentLine,
    String? visibleText,
    bool? isDialoguePlaying,
    bool? isWaitingForTap,
    bool? isLoading,
    Set<String>? appearedCharacters,
    Set<String>? animatedCharacters,
    bool? isInHistoryView,
    bool? isUIVisible,
    bool? isHistoryPopupView,
    bool? isCgViewVisible,
    Map<String, String>? characterFaces,
  }) {
    return GameScreenState(
      sessionId: sessionId ?? this.sessionId,
      dialogues: dialogues ?? this.dialogues,
      currentLine: currentLine ?? this.currentLine,
      currentDialogueIndex: currentDialogueIndex ?? this.currentDialogueIndex,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      visibleText: visibleText ?? this.visibleText,
      isDialoguePlaying: isDialoguePlaying ?? this.isDialoguePlaying,
      isWaitingForTap: isWaitingForTap ?? this.isWaitingForTap,
      isLoading: isLoading ?? this.isLoading,
      appearedCharacters: appearedCharacters ?? this.appearedCharacters,
      animatedCharacters: animatedCharacters ?? this.animatedCharacters,
      isInHistoryView: isInHistoryView ?? this.isInHistoryView,
      isUIVisible: isUIVisible ?? this.isUIVisible,
      isHistoryPopupView: isHistoryPopupView ?? this.isHistoryPopupView,
      isCgViewVisible: isCgViewVisible ?? this.isCgViewVisible,
      characterFaces: characterFaces ?? this.characterFaces,
    );
  }
}
