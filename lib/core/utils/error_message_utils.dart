import 'package:dio/dio.dart';

/// Returns a user-friendly error message for display in the UI.
/// Never exposes technical details like stack traces or raw exception text.
String toUserFriendlyErrorMessage(Object error, {String? fallback}) {
  const defaultMessage = 'Something went wrong. Please try again later.';

  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please try again.';
        case 401:
          return 'Session expired. Please log in again.';
        case 403:
          return 'You do not have permission to view this.';
        case 404:
          return 'The requested item was not found.';
        case 500:
        case 502:
        case 503:
          return 'Server is temporarily unavailable. Please try again later.';
        default:
          return fallback ?? defaultMessage;
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';
      default:
        return fallback ?? defaultMessage;
    }
  }

  return fallback ?? defaultMessage;
}

/// Returns true if [message] looks like a technical/developer error.
bool _looksTechnical(String? message) {
  if (message == null || message.isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('exception') ||
      lower.contains('status code') ||
      lower.contains('dioexception') ||
      lower.contains('stacktrace') ||
      lower.contains('stack trace') ||
      lower.contains('requestoptions') ||
      lower.contains('developer.mozilla');
}

/// Returns a user-friendly message. If [message] looks technical, returns [fallback].
String sanitizeErrorMessage(String? message, {String fallback = 'Something went wrong. Please try again later.'}) {
  if (message == null || message.trim().isEmpty) return fallback;
  if (_looksTechnical(message)) return fallback;
  return message;
}
