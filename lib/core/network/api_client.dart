import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Dio client with auth refresh / retry hooks (SRD §3.2, §10.2).
/// Wired for when the Python API is available; demo mode skips network.
class ApiClient {
  ApiClient(this.config, {String? accessToken})
      : dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Idempotency-Key for mutating requests (SRD sync push).
          if (const {'POST', 'PUT', 'PATCH', 'DELETE'}
              .contains(options.method)) {
            options.headers.putIfAbsent(
              'Idempotency-Key',
              () => DateTime.now().microsecondsSinceEpoch.toString(),
            );
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Placeholder for 401 refresh + exponential back-off.
          handler.next(error);
        },
      ),
    );
  }

  final AppConfig config;
  final Dio dio;

  void setAccessToken(String? token) {
    if (token == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
