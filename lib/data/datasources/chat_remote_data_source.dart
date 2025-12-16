import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/chat_history_response.dart';

abstract class ChatRemoteDataSource {
  Future<ChatHistoryResponse> getChatHistory({
    required String userId,
    required String token,
    String? cursor,
    int limit = 50,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<ChatHistoryResponse> getChatHistory({
    required String userId,
    required String token,
    String? cursor,
    int limit = 50,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
      };

      if (cursor != null) {
        queryParameters['cursor'] = cursor;
      }

      print('🌐 API Call: GET /api/chat/$userId');
      print('   Query params: $queryParameters');
      print('   Token: ${token.substring(0, 20)}...');

      final response = await dio.get(
        '/api/chat/$userId',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            ...ApiConstants.headers,
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ API Response Status: ${response.statusCode}');
      print('   Response data type: ${response.data.runtimeType}');
      print('   Response data: ${response.data}');

      return ChatHistoryResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('❌ API Error: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response data: ${e.response?.data}');
        print('   Request: ${e.requestOptions.uri}');
      }
      throw Exception('Failed to get chat history: $e');
    }
  }
}
