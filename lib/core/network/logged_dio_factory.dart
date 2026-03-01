import 'package:dio/dio.dart';

import '../logging/app_logger.dart';

class LoggedDioFactory {
  LoggedDioFactory._();

  static Dio create(String tag) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.debug(
            tag,
            'HTTP -> ${options.method} ${options.uri}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
            tag,
            'HTTP <- ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            tag,
            'HTTP xx ${error.requestOptions.method} ${error.requestOptions.uri}',
            error: error.error ?? error.message,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );
    return dio;
  }
}
