sealed class AppError implements Exception {
  final String message;
  const AppError(this.message);

  factory AppError.network(String message) = NetworkError;
  factory AppError.timeout(String message) = TimeoutError;
  factory AppError.server(String message, int statusCode) = ServerError;
  factory AppError.notFound(String message) = NotFoundError;
  factory AppError.parse(String message) = ParseError;
  factory AppError.unknown(String message) = UnknownError;

  @override
  String toString() => 'AppError: $message';
}

final class NetworkError extends AppError {
  const NetworkError(super.message);
}

final class TimeoutError extends AppError {
  const TimeoutError(super.message);
}

final class ServerError extends AppError {
  final int statusCode;
  const ServerError(super.message, this.statusCode);
}

final class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

final class ParseError extends AppError {
  const ParseError(super.message);
}

final class UnknownError extends AppError {
  const UnknownError(super.message);
}

extension AppErrorX on AppError {
  String get userFriendlyMessage {
    return switch (this) {
      NetworkError() => 'No internet connection. Please check your network.',
      TimeoutError() => 'The request took too long. Please try again.',
      ServerError(statusCode: final code) when code >= 500 =>
        'Something went wrong on our end. Please try again later.',
      ServerError() => 'Request failed. Please try again.',
      NotFoundError() => 'The requested item was not found.',
      ParseError() => 'Unexpected data received. Please try again.',
      UnknownError() => 'An unexpected error occurred.',
    };
  }
}
