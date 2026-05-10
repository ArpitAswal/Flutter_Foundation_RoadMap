import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// =============================================================================
// 🚀 DioClient — Enterprise Networking Core
// =============================================================================

class AppDioClient {
  late final Dio _dio;
  
  // 💡 Token Refresh State
  bool _isRefreshing = false;
  String _simulatedAccessToken = 'expired_token_123';

  Dio get instance => _dio;

  AppDioClient() {
    final baseOptions = BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    );

    _dio = Dio(baseOptions);

    // =========================================================================
    // 🔥 CORE INTERCEPTORS
    // =========================================================================
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Inject Auth Token
          options.headers['Authorization'] = 'Bearer $_simulatedAccessToken';
          
          if (kDebugMode) {
            print('🌐 [REQ] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [RES] ${response.statusCode} - ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('❌ [ERR] ${e.type} - Status: ${e.response?.statusCode}');
          }

          // ===================================================================
          // 🔄 401 TOKEN REFRESH FLOW
          // ===================================================================
          if (e.response?.statusCode == 401) {
            if (kDebugMode) print('⚠️ 401 Unauthorized detected. Attempting refresh...');

            // Basic locking mechanism to prevent multiple simultaneous refresh calls
            if (!_isRefreshing) {
              _isRefreshing = true;
              
              try {
                // 1. Call refresh token API
                _simulatedAccessToken = await _refreshToken();
                
                // 2. Update the failed request with the NEW token
                e.requestOptions.headers['Authorization'] = 'Bearer $_simulatedAccessToken';
                
                // 3. Retry the originally failed request
                if (kDebugMode) print('♻️ Retrying original request with new token...');
                final retryResponse = await _dio.fetch(e.requestOptions);
                
                // 4. Resolve the interceptor with the successful retry response
                return handler.resolve(retryResponse);
              } catch (refreshError) {
                // If refresh fails, log out user
                if (kDebugMode) print('🚨 Token refresh failed! User must log out.');
                return handler.next(e); 
              } finally {
                _isRefreshing = false;
              }
            }
          }

          return handler.next(e); // Continue error if not 401
        },
      ),
    );
  }

  // Simulated backend call to get a new token
  Future<String> _refreshToken() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    if (kDebugMode) print('🔑 Successfully fetched new token!');
    return 'new_fresh_token_456';
  }
}
