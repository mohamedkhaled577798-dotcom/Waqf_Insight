import 'package:dio/dio.dart';
import 'package:waqf_insight/core/constants/app_constants.dart';
import 'package:waqf_insight/core/errors/exceptions.dart';
import 'package:waqf_insight/core/network/auth_token_holder.dart';

/// Centralized HTTP client wrapper around [Dio].
class ApiClient {
  late final Dio _dio;
  final AuthTokenHolder _tokenHolder;

  ApiClient({required AuthTokenHolder tokenHolder}) : _tokenHolder = tokenHolder {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_tokenHolder),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'انتهت مهلة الاتصال بالخادم');
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'لا يوجد اتصال بالإنترنت');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(
          error.response,
          error.response?.statusMessage ?? 'خطأ من الخادم',
        );
        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        }
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: error.message ?? 'حدث خطأ غير متوقع',
        );
    }
  }

  static String _extractErrorMessage(Response<dynamic>? response, String fallback) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['title'] ?? data['error'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return fallback;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenHolder);

  final AuthTokenHolder _tokenHolder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenHolder.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
