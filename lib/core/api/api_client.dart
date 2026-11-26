import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:suska_starter/core/api/token_refresher.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/token_storage.dart';

/// HTTP client backend aplikasi (`AppConfig.apiUrl`).
///
/// - Menyisipkan header `Authorization: Bearer <jwt>` dari [TokenStorage].
/// - Saat 401: refresh token via SSOT ([TokenRefresher]) sekali, lalu
///   mengulang request.
class ApiClient {
  ApiClient({
    required this._tokenStorage,
    required this._refresher,
    Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiUrl,
                connectTimeout: AppConfig.apiTimeout,
                receiveTimeout: AppConfig.apiTimeout,
                headers: {
                  'X-App-Id': AppConfig.appId,
                  // Dipasang di SEMUA request supaya backend bisa menolak
                  // versi aplikasi lama tanpa bergantung pada tiap endpoint.
                  'X-App-Version': AppConfig.appVersion,
                },
              ),
            ) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: _onRequest,
            onError: _onError,
          ),
        );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;
  final TokenRefresher _refresher;
  bool _refreshing = false;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '[API ERROR] ${err.requestOptions.method} '
        '${err.requestOptions.path} -> ${err.response?.statusCode} '
        '(${err.type})\n'
        'message: ${err.message}\n'
        'response: ${err.response?.data}',
      );
    }
    final is401 = err.response?.statusCode == 401;
    if (!is401 || _refreshing) return handler.next(err);

    _refreshing = true;
    try {
      final refreshed = await _refresher.refresh();
      if (!refreshed) return handler.next(err);

      // Ulangi request asli — interceptor onRequest akan memasang token baru.
      final response = await dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    } finally {
      _refreshing = false;
    }
  }
}
