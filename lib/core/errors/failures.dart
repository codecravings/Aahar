import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed. Check your internet.',
    super.code = 'NETWORK_ERROR',
  });
}

/// AI Service failures
class AIServiceFailure extends Failure {
  const AIServiceFailure({
    required super.message,
    super.code = 'AI_SERVICE_ERROR',
  });
}

/// Image processing failures
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure({
    super.message = 'Failed to process image. Try again.',
    super.code = 'IMAGE_PROCESSING_ERROR',
  });
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    super.message = 'Local storage error occurred.',
    super.code = 'DATABASE_ERROR',
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied. Please grant access in settings.',
    super.code = 'PERMISSION_ERROR',
  });
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong. Try again.',
    super.code = 'UNKNOWN_ERROR',
  });
}

/// API Response parsing failure
class ParseFailure extends Failure {
  const ParseFailure({
    super.message = 'Failed to parse AI response. Try again.',
    super.code = 'PARSE_ERROR',
  });
}
