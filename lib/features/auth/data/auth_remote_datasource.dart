import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';

/// Talks to the DummyJSON auth endpoints.
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.authLogin,
        data: {
          'username': username.trim(),
          'password': password,
          'expiresInMins': 60 * 24,
        },
      );
      return _asMap(response.data);
    } on ServerException catch (e) {
      // DummyJSON answers wrong credentials with 400 "Invalid credentials".
      if (e.statusCode == 400) {
        throw const ApiException('Incorrect username or password.');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await dioClient.get(ApiConstants.authMe);
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ServerException('Unexpected response from the auth server.');
  }
}
