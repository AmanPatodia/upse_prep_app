import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

  static final ApiClient instance = ApiClient._();

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return (response.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(path, data: data);
    return (response.data as Map).cast<String, dynamic>();
  }
}
