import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/preference_service.dart';
import 'api_exceptions.dart';

/// Thin wrapper around [Dio] that adds the auth header and turns every
/// [DioException] into one of our own [ApiException] types.
class DioClient {
  final Dio _dio;
  final PreferenceService preferenceService;

  DioClient({
    required this.preferenceService,
    String? baseUrl,
    Duration? connectTimeout,
    bool attachAuthToken = true,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? ApiConstants.baseUrl,
               connectTimeout: connectTimeout ?? ApiConstants.connectTimeout,
               receiveTimeout: ApiConstants.receiveTimeout,
               sendTimeout: ApiConstants.sendTimeout,
               headers: const {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
               },
             ),
           ) {
    if (attachAuthToken) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = preferenceService.getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response<dynamic>> put(String path, {Object? data}) {
    return _send(() => _dio.put(path, data: data));
  }

  Future<Response<dynamic>> delete(String path) {
    return _send(() => _dio.delete(path));
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapException(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ApiException _mapException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const UnauthorizedException();
        }
        if (statusCode == 404) return const NotFoundException();
        return ServerException(
          _messageFrom(error.response?.data) ?? 'Server error ($statusCode)',
          statusCode,
        );
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException('Could not verify the server certificate.');
      // `unknown`, `transformTimeout` (newer dio) and any future types.
      default:
        return ApiException(
          error.message ?? 'Unexpected network error. Please try again.',
        );
    }
  }

  String? _messageFrom(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return null;
  }
}
