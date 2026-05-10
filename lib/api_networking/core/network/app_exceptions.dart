// =============================================================================
// 🚨 Exception Mapping (Sealed Classes)
// =============================================================================
//
// WHY EXCEPTION MAPPING?
//   We don't want raw `DioException` or `SocketException` leaking to the UI.
//   We map them into domain-specific exceptions so the ViewModel/UI can show
//   user-friendly messages ("No Internet" instead of "OS Error 113").
// =============================================================================

sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No Internet Connection.']);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException([super.message = 'The connection timed out. Please try again.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session expired. Please log in again.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(this.statusCode, [super.message = 'A server error occurred.']);
}

class UnknownAppException extends AppException {
  const UnknownAppException([super.message = 'An unexpected error occurred.']);
}

class CancelledByUserException extends AppException {
  const CancelledByUserException([super.message = 'Request was cancelled.']);
}
