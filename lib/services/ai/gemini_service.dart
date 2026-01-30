import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import 'ai_service.dart';

/// Gemini API implementation of AIService
class GeminiService implements AIService {
  final Dio _dio;
  final GeminiModel _model;

  GeminiService({
    required GeminiModel model,
    Dio? dio,
  })  : _model = model,
        _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  String get modelId => _model.modelId;

  @override
  String get modelName => _model.displayName;

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _dio.get(
        '/models/${_model.modelId}',
        queryParameters: {'key': AppConstants.geminiApiKey},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Result<FoodAnalysisResult>> analyzeFood(Uint8List imageBytes, {String? userHint}) async {
    return _analyzeFoodWithRetry(imageBytes, retriesLeft: 1, userHint: userHint);
  }

  Future<Result<FoodAnalysisResult>> _analyzeFoodWithRetry(
    Uint8List imageBytes, {
    required int retriesLeft,
    String? userHint,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final prompt = _buildPrompt(userHint: userHint);

      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_NONE',
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_NONE',
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_NONE',
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_NONE',
          },
        ],
      };

      final response = await _dio.post(
        '/models/${_model.modelId}:generateContent',
        queryParameters: {'key': AppConstants.geminiApiKey},
        data: requestBody,
      );

      if (response.statusCode != 200) {
        return Result.failure(
          AIServiceFailure(
            message: 'API returned status ${response.statusCode}',
          ),
        );
      }

      final result = _parseResponse(response.data);
      return result;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        if (retriesLeft > 0) {
          await Future.delayed(const Duration(seconds: 2));
          return _analyzeFoodWithRetry(imageBytes, retriesLeft: retriesLeft - 1, userHint: userHint);
        }
        return Result.failure(
          const NetworkFailure(
            message: 'Request timed out. Check your connection and try again.',
          ),
        );
      }

      if (statusCode == 429) {
        if (retriesLeft > 0) {
          await Future.delayed(const Duration(seconds: 3));
          return _analyzeFoodWithRetry(imageBytes, retriesLeft: retriesLeft - 1, userHint: userHint);
        }
        final suggestion = _suggestAlternativeModel();
        return Result.failure(
          AIServiceFailure(
            message: 'Rate limited on ${_model.displayName}. $suggestion',
          ),
        );
      }

      if (statusCode == 500 || statusCode == 503) {
        if (retriesLeft > 0) {
          await Future.delayed(const Duration(seconds: 2));
          return _analyzeFoodWithRetry(imageBytes, retriesLeft: retriesLeft - 1, userHint: userHint);
        }
        return Result.failure(
          const AIServiceFailure(
            message: 'AI service is temporarily unavailable. Please try again.',
          ),
        );
      }

      if (statusCode == 404) {
        return Result.failure(
          AIServiceFailure(
            message: 'Model "${_model.displayName}" is not available. Try switching to a different model in Settings.',
          ),
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return Result.failure(
          const NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }

      return Result.failure(
        const AIServiceFailure(
          message: 'Something went wrong. Please try again.',
        ),
      );
    } catch (e) {
      return Result.failure(
        const AIServiceFailure(message: 'Analysis failed. Please try again.'),
      );
    }
  }

  String _suggestAlternativeModel() {
    switch (_model) {
      case GeminiModel.flash:
        return 'Try switching to Flash Lite or Pro in Settings.';
      case GeminiModel.pro:
        return 'Try switching to Flash or Flash Lite in Settings.';
      case GeminiModel.flashLite:
        return 'Try switching to Flash or Pro in Settings.';
    }
  }

  String _buildPrompt({String? userHint}) {
    final hintSection = userHint != null && userHint.isNotEmpty
        ? '\nUSER DESCRIPTION: The user describes this food as: "$userHint". Use this to improve your analysis.\n'
        : '';
    return '''
You are a nutrition analysis AI. Analyze this food image and estimate the nutritional content.
$hintSection
IMPORTANT INSTRUCTIONS:
1. Identify all visible food items in the image
2. Estimate portion sizes based on visual cues
3. Calculate total macronutrients for the entire meal
4. Be conservative with estimates - slightly under-estimate rather than over
5. If multiple items are visible, list them separately
6. Provide a brief, helpful description about the food (ingredients, cooking style, health tips)

Return ONLY valid JSON in this exact format (no markdown, no explanation):

For single food item:
{
  "food_name": "name of the food",
  "description": "Brief description about the food - what it contains, how it's prepared, or health notes (1-2 sentences)",
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "confidence": number between 0 and 1
}

For multiple food items:
{
  "items": [
    {
      "name": "food item 1",
      "portion": "estimated portion",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fat": number
    }
  ],
  "description": "Brief description about the meal - what it contains, or health notes (1-2 sentences)",
  "confidence": number between 0 and 1
}

If you cannot identify the food or it's not food, return:
{
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "confidence": 0,
  "error": "description of issue"
}

All macros should be realistic values. Protein, carbs, fat in grams.
''';
  }

  Result<FoodAnalysisResult> _parseResponse(Map<String, dynamic> responseData) {
    try {
      // Navigate Gemini response structure
      final candidates = responseData['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return Result.failure(
          const ParseFailure(message: 'No response from AI model'),
        );
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        return Result.failure(
          const ParseFailure(message: 'Empty response from AI model'),
        );
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.isEmpty) {
        return Result.failure(
          const ParseFailure(message: 'No text in AI response'),
        );
      }

      // Extract JSON from response (handle markdown code blocks)
      String jsonStr = text.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        return Result.failure(
          ParseFailure(message: 'Invalid JSON response: $e'),
        );
      }

      // Check for error response
      if (jsonData.containsKey('error')) {
        return Result.failure(
          AIServiceFailure(
            message: jsonData['error'] as String? ?? 'Could not analyze food',
          ),
        );
      }

      final result = FoodAnalysisResult.fromJson(jsonData);

      // Validate result has reasonable values
      if (result.calories == 0 &&
          result.protein == 0 &&
          result.carbs == 0 &&
          result.fat == 0) {
        return Result.failure(
          const AIServiceFailure(
            message: 'Could not identify food in image',
          ),
        );
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(
        ParseFailure(message: 'Failed to parse response: $e'),
      );
    }
  }
}

/// Factory for creating AI service instances
class AIServiceFactory {
  static AIService create(GeminiModel model) {
    return GeminiService(model: model);
  }

  static AIService createFlash() => create(GeminiModel.flash);
  static AIService createPro() => create(GeminiModel.pro);
}
