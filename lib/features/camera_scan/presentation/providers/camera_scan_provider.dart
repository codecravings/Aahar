import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../../services/camera/camera_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Provider for camera service
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

/// State for camera scan flow
class CameraScanState {
  final CameraScanStatus status;
  final CapturedImage? capturedImage;
  final FoodAnalysisResult? analysisResult;
  final Failure? error;
  final String? statusMessage;

  const CameraScanState({
    this.status = CameraScanStatus.idle,
    this.capturedImage,
    this.analysisResult,
    this.error,
    this.statusMessage,
  });

  CameraScanState copyWith({
    CameraScanStatus? status,
    CapturedImage? capturedImage,
    FoodAnalysisResult? analysisResult,
    Failure? error,
    String? statusMessage,
  }) {
    return CameraScanState(
      status: status ?? this.status,
      capturedImage: capturedImage ?? this.capturedImage,
      analysisResult: analysisResult ?? this.analysisResult,
      error: error,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  bool get isIdle => status == CameraScanStatus.idle;
  bool get isCapturing => status == CameraScanStatus.capturing;
  bool get isCaptured => status == CameraScanStatus.captured;
  bool get isProcessing => status == CameraScanStatus.processing;
  bool get isAnalyzing => status == CameraScanStatus.analyzing;
  bool get isComplete => status == CameraScanStatus.complete;
  bool get hasError => status == CameraScanStatus.error;
  bool get isLoading => isCapturing || isProcessing || isAnalyzing;
}

enum CameraScanStatus {
  idle,
  capturing,
  captured,
  processing,
  analyzing,
  complete,
  error,
}

/// Provider for camera scan state
final cameraScanProvider =
    StateNotifierProvider<CameraScanNotifier, CameraScanState>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  final aiService = ref.watch(aiServiceProvider);
  return CameraScanNotifier(cameraService, aiService);
});

/// Camera scan state notifier
class CameraScanNotifier extends StateNotifier<CameraScanState> {
  final CameraService _cameraService;
  final AIService _aiService;

  CameraScanNotifier(this._cameraService, this._aiService)
      : super(const CameraScanState());

  /// Capture from camera — pauses at captured state for user description
  Future<void> captureImage() async {
    state = state.copyWith(
      status: CameraScanStatus.capturing,
      statusMessage: 'Opening camera...',
      error: null,
    );

    final captureResult = await _cameraService.captureFromCamera();

    captureResult.fold(
      onSuccess: (image) {
        state = state.copyWith(
          status: CameraScanStatus.captured,
          capturedImage: image,
          statusMessage: 'Photo captured! Add a description or tap Analyze.',
        );
      },
      onFailure: (failure) {
        state = CameraScanState(
          status: CameraScanStatus.error,
          error: failure,
        );
      },
    );
  }

  /// Pick from gallery — pauses at captured state for user description
  Future<void> pickImage() async {
    state = state.copyWith(
      status: CameraScanStatus.capturing,
      statusMessage: 'Opening gallery...',
      error: null,
    );

    final captureResult = await _cameraService.pickFromGallery();

    captureResult.fold(
      onSuccess: (image) {
        state = state.copyWith(
          status: CameraScanStatus.captured,
          capturedImage: image,
          statusMessage: 'Photo selected! Add a description or tap Analyze.',
        );
      },
      onFailure: (failure) {
        state = CameraScanState(
          status: CameraScanStatus.error,
          error: failure,
        );
      },
    );
  }

  /// Send the captured image to AI for analysis, with optional user hint
  Future<void> analyzeWithHint({String? userHint}) async {
    if (state.capturedImage == null) {
      state = const CameraScanState(
        status: CameraScanStatus.error,
        error: ImageProcessingFailure(message: 'No image to analyze'),
      );
      return;
    }

    await _analyzeImage(state.capturedImage!, userHint: userHint);
  }

  /// Analyze a captured image
  Future<void> _analyzeImage(CapturedImage image, {String? userHint}) async {
    state = state.copyWith(
      status: CameraScanStatus.processing,
      capturedImage: image,
      statusMessage: 'Processing image...',
    );

    // Short delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      status: CameraScanStatus.analyzing,
      statusMessage: 'AI analyzing food (${_aiService.modelName})...',
    );

    final analysisResult = await _aiService.analyzeFood(
      image.compressedBytes,
      userHint: userHint,
    );

    analysisResult.fold(
      onSuccess: (result) {
        state = state.copyWith(
          status: CameraScanStatus.complete,
          analysisResult: result,
          statusMessage: 'Analysis complete!',
        );
      },
      onFailure: (failure) {
        state = CameraScanState(
          status: CameraScanStatus.error,
          capturedImage: image,
          error: failure,
        );
      },
    );
  }

  /// Retry analysis with existing image
  Future<void> retryAnalysis({String? userHint}) async {
    if (state.capturedImage == null) {
      state = const CameraScanState(
        status: CameraScanStatus.error,
        error: ImageProcessingFailure(message: 'No image to retry'),
      );
      return;
    }

    await _analyzeImage(state.capturedImage!, userHint: userHint);
  }

  /// Reset state
  void reset() {
    state = const CameraScanState();
  }

  /// Clear error and return to idle
  void clearError() {
    if (state.capturedImage != null) {
      state = CameraScanState(
        status: CameraScanStatus.captured,
        capturedImage: state.capturedImage,
      );
    } else {
      reset();
    }
  }
}

/// Provider for AI analysis loading state
final isAnalyzingProvider = Provider<bool>((ref) {
  final state = ref.watch(cameraScanProvider);
  return state.isLoading;
});

/// Provider for current AI model name
final currentModelNameProvider = Provider<String>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.modelName;
});
