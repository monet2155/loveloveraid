// 커스텀 예외 클래스들
class GameException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  GameException(this.message, {this.details, this.originalError});

  @override
  String toString() =>
      'GameException: $message${details != null ? ' ($details)' : ''}';
}

class NetworkException extends GameException {
  NetworkException(String message, {String? details, dynamic originalError})
    : super(message, details: details, originalError: originalError);
}

class SessionException extends GameException {
  SessionException(String message, {String? details, dynamic originalError})
    : super(message, details: details, originalError: originalError);
}

class TTSException extends GameException {
  TTSException(String message, {String? details, dynamic originalError})
    : super(message, details: details, originalError: originalError);
}
