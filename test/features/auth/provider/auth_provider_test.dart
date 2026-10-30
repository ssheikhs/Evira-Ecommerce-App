import 'package:ecommerce_app/core/network/api_exceptions.dart';
import 'package:ecommerce_app/features/auth/data/auth_repository.dart';
import 'package:ecommerce_app/features/auth/models/auth_status.dart';
import 'package:ecommerce_app/features/auth/models/user_model.dart';
import 'package:ecommerce_app/features/auth/provider/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = UserModel(
  id: 1,
  username: 'emilys',
  email: 'emily@example.com',
  firstName: 'Emily',
  lastName: 'Johnson',
);

class FakeAuthRepository implements AuthRepository {
  UserModel? saved;
  bool loggedOut = false;

  FakeAuthRepository({this.saved});

  @override
  UserModel? getSavedUser() => saved;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    if (password != 'emilyspass') {
      throw const ApiException('Incorrect username or password.');
    }
    saved = _user;
    return _user;
  }

  @override
  Future<UserModel?> refreshSession() async => saved;

  @override
  Future<void> logout() async {
    loggedOut = true;
    saved = null;
  }
}

void main() {
  test('starts signed out when nothing is saved', () {
    final auth = AuthProvider(authRepository: FakeAuthRepository());
    expect(auth.isAuthenticated, isFalse);
    expect(auth.user, isNull);
  });

  test('restores a saved session immediately', () {
    final auth = AuthProvider(
      authRepository: FakeAuthRepository(saved: _user),
      verifySession: false,
    );
    expect(auth.isAuthenticated, isTrue);
    expect(auth.user?.fullName, 'Emily Johnson');
  });

  test('successful login stores the user', () async {
    final auth = AuthProvider(authRepository: FakeAuthRepository());
    final ok = await auth.login(username: 'emilys', password: 'emilyspass');

    expect(ok, isTrue);
    expect(auth.status, AuthStatus.authenticated);
    expect(auth.user, _user);
    expect(auth.errorMessage, isNull);
  });

  test('failed login shows the error and stays signed out', () async {
    final auth = AuthProvider(authRepository: FakeAuthRepository());
    final ok = await auth.login(username: 'emilys', password: 'wrong');

    expect(ok, isFalse);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.errorMessage, 'Incorrect username or password.');
  });

  test('logout clears the session', () async {
    final repository = FakeAuthRepository(saved: _user);
    final auth = AuthProvider(authRepository: repository, verifySession: false);

    await auth.logout();

    expect(auth.isAuthenticated, isFalse);
    expect(repository.loggedOut, isTrue);
  });

  test('UserModel builds initials and reads the nested address', () {
    final user = UserModel.fromMap({
      'id': 2,
      'username': 'michaelw',
      'firstName': 'Michael',
      'lastName': 'Williams',
      'address': {'address': '385 Fifth Street', 'city': 'Houston'},
    });
    expect(user.initials, 'MW');
    expect(user.address, '385 Fifth Street');
    expect(user.city, 'Houston');

    // Round-trips through the flat local format.
    expect(UserModel.fromMap(user.toMap()).city, 'Houston');
  });
}
