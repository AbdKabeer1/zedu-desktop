import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockApiBaseService extends Mock implements ApiBaseService {}

void main() {
  group('UserProfileRemoteDataSourceImpl.deleteAccount (Ziki #584)', () {
    late MockApiBaseService api;
    late UserProfileRemoteDataSourceImpl datasource;

    setUp(() {
      api = MockApiBaseService();
      datasource = UserProfileRemoteDataSourceImpl(
        config: const AppConfig(apiBaseUrl: 'http://test', usesMockData: false),
        apiBaseService: api,
      );
      when(
        () => api.delete<Map<String, dynamic>>(path: '/users/me'),
      ).thenAnswer(
        (_) async => ApiResponseModel<Map<String, dynamic>>(
          data: const <String, dynamic>{},
          statusCode: 200,
        ),
      );
    });

    test('deactivates the account with DELETE /users/me', () async {
      await datasource.deleteAccount();

      verify(
        () => api.delete<Map<String, dynamic>>(path: '/users/me'),
      ).called(1);
    });

    test('never calls the non-existent /profile/account route', () async {
      await datasource.deleteAccount();

      verifyNever(
        () => api.delete<Map<String, dynamic>>(path: '/profile/account'),
      );
    });
  });
}
