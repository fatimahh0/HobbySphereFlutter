import 'package:dio/dio.dart'; // HTTP client
import 'api_config.dart'; // baseUrl source

class ApiClient {
  static final ApiClient _i = ApiClient._internal(); // singleton instance
  factory ApiClient() => _i; // factory constructor
  late final Dio dio; // shared Dio client

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, // set base url
        connectTimeout: const Duration(seconds: 15), // connect timeout
        receiveTimeout: const Duration(seconds: 15), // read timeout
        headers: {
          'Content-Type': 'application/json', // default header
          'Accept': 'application/json', // accept json
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        // optional logs (dev)
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  void refreshBaseUrl() {
    // call after ApiConfig.load()
    dio.options.baseUrl = ApiConfig.baseUrl; // update base url in-place
  }

  void setToken(String token) {
    // set global Authorization
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    // remove Authorization
    dio.options.headers.remove('Authorization');
  }
}
