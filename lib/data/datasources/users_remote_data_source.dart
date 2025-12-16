import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getAllUsers(String token);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio dio;

  UsersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getAllUsers(String token) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.users}',
        options: Options(
          headers: {
            ...ApiConstants.headers,
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data as List<dynamic>;
        return usersJson
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch users with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch users. Please try again.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
