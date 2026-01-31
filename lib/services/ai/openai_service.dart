import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import 'ai_service.dart';

/// OpenAI API implementation of AIService
class OpenAIService implements AIService {
  final Dio _dio;
  final AIModel _model;

  OpenAIService({
    required AIModel model,
    Dio? dio,
  })  : _model = model,
        _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.openaiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.openaiApiKey}',
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
      final response = await _dio.get('/models/${_model.modelId}');
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
      print('🤖 [OpenAI] Starting analysis with model: ${_model.modelId}');
      print('🤖 [OpenAI] API Key present: ${AppConstants.openaiApiKey.isNotEmpty ? "Yes (${AppConstants.openaiApiKey.substring(0, 7)}...)" : "No"}');

      final base64Image = base64Encode(imageBytes);
      final prompt = _buildPrompt(userHint: userHint);

      final requestBody = {
        'model': _model.modelId,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': prompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_completion_tokens': 16000,
      };

      print('🤖 [OpenAI] Request URL: ${AppConstants.openaiBaseUrl}/chat/completions');
      print('🤖 [OpenAI] Image size: ${(base64Image.length / 1024).toStringAsFixed(2)} KB');
      if (userHint != null && userHint.isNotEmpty) {
        print('🤖 [OpenAI] User hint: $userHint');
      }

      final response = await _dio.post(
        '/chat/completions',
        data: requestBody,
      );

      print('🤖 [OpenAI] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ [OpenAI] Non-200 status code: ${response.statusCode}');
        print('❌ [OpenAI] Response data: ${response.data}');
        return Result.failure(
          AIServiceFailure(
            message: 'API returned status ${response.statusCode}: ${response.data}',
          ),
        );
      }

      print('✅ [OpenAI] Parsing response...');
      final result = _parseResponse(response.data);
      return result;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      print('❌ [OpenAI] DioException occurred');
      print('❌ [OpenAI] Error type: ${e.type}');
      print('❌ [OpenAI] Status code: $statusCode');
      print('❌ [OpenAI] Error message: ${e.message}');
      if (e.response?.data != null) {
        print('❌ [OpenAI] Response data: ${e.response?.data}');
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        if (retriesLeft > 0) {
          print('⏳ [OpenAI] Retrying after timeout...');
          await Future.delayed(const Duration(seconds: 2));
          return _analyzeFoodWithRetry(imageBytes, retriesLeft: retriesLeft - 1, userHint: userHint);
        }
        return Result.failure(
          const NetworkFailure(
            message: 'Request timed out. Check your connection and try again.',
          ),
        );
      }

      if (statusCode == 401) {
        return Result.failure(
          const AIServiceFailure(
            message: 'Invalid OpenAI API key. Check your .env file and ensure OPENAI_API_KEY is set correctly.',
          ),
        );
      }

      if (statusCode == 429) {
        if (retriesLeft > 0) {
          print('⏳ [OpenAI] Rate limited, retrying...');
          await Future.delayed(const Duration(seconds: 3));
          return _analyzeFoodWithRetry(imageBytes, retriesLeft: retriesLeft - 1, userHint: userHint);
        }
        return Result.failure(
          AIServiceFailure(
            message: 'Rate limited on ${_model.displayName}. Try switching to a Gemini model in Settings.',
          ),
        );
      }

      if (statusCode == 500 || statusCode == 503) {
        if (retriesLeft > 0) {
          print('⏳ [OpenAI] Server error, retrying...');
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
            message: 'Model "${_model.displayName}" (${_model.modelId}) is not available. Try switching to a different model in Settings.',
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

      // Generic error with actual error details
      final errorDetail = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      return Result.failure(
        AIServiceFailure(
          message: 'OpenAI API Error (${statusCode ?? 'unknown'}): $errorDetail',
        ),
      );
    } catch (e, stackTrace) {
      print('❌ [OpenAI] Unexpected error: $e');
      print('❌ [OpenAI] Stack trace: $stackTrace');
      return Result.failure(
        AIServiceFailure(message: 'Analysis failed: ${e.toString()}'),
      );
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
      print('🔍 [OpenAI] Parsing response data...');
      print('🔍 [OpenAI] Full response: $responseData');

      final choices = responseData['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        print('❌ [OpenAI] No choices in response');
        return Result.failure(
          const ParseFailure(message: 'No response from AI model'),
        );
      }

      print('🔍 [OpenAI] Choices: $choices');
      final message = choices[0]['message'] as Map<String, dynamic>?;
      print('🔍 [OpenAI] Message: $message');

      final text = message?['content'] as String?;
      if (text == null || text.isEmpty) {
        print('❌ [OpenAI] Empty content in response');
        print('❌ [OpenAI] Message object was: $message');
        return Result.failure(
          const ParseFailure(message: 'Empty response from AI model'),
        );
      }

      print('📝 [OpenAI] Raw response text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');

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

      print('📝 [OpenAI] Cleaned JSON: ${jsonStr.substring(0, jsonStr.length > 200 ? 200 : jsonStr.length)}...');

      final Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(jsonStr) as Map<String, dynamic>;
        print('✅ [OpenAI] Successfully parsed JSON');
      } catch (e) {
        print('❌ [OpenAI] JSON parse error: $e');
        return Result.failure(
          ParseFailure(message: 'Invalid JSON response: $e'),
        );
      }

      if (jsonData.containsKey('error')) {
        print('❌ [OpenAI] Error in JSON response: ${jsonData['error']}');
        return Result.failure(
          AIServiceFailure(
            message: jsonData['error'] as String? ?? 'Could not analyze food',
          ),
        );
      }

      final result = FoodAnalysisResult.fromJson(jsonData);
      print('✅ [OpenAI] Parsed food: ${result.foodName}');
      print('✅ [OpenAI] Macros: ${result.calories} cal, ${result.protein}g P, ${result.carbs}g C, ${result.fat}g F');
      print('✅ [OpenAI] Confidence: ${(result.confidence * 100).toInt()}%');

      if (result.calories == 0 &&
          result.protein == 0 &&
          result.carbs == 0 &&
          result.fat == 0) {
        print('❌ [OpenAI] All macros are zero - could not identify food');
        return Result.failure(
          const AIServiceFailure(
            message: 'Could not identify food in image',
          ),
        );
      }

      return Result.success(result);
    } catch (e, stackTrace) {
      print('❌ [OpenAI] Parse error: $e');
      print('❌ [OpenAI] Stack trace: $stackTrace');
      return Result.failure(
        ParseFailure(message: 'Failed to parse response: $e'),
      );
    }
  }
}
