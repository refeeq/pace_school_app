enum AppError {
  notFound,
  badRequest,
  unauthorized,
  forbidden,
  internalServerError,
  unknown,
}

class MyError {
  final AppError key;
  final String? message;

  const MyError({
    required this.key,
    this.message,
  });
}
