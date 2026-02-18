import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/credential.repository.dart';
import 'package:game_launcher/domain/entities/credentials.entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage mockStorage;
  late CredentialsRepositoryImpl repository;

  setUp(() {
    mockStorage = MockSecureStorage();
    repository = CredentialsRepositoryImpl(storage: mockStorage);
  });

  group('CredentialsRepositoryImpl - Secure Storage Tests', () {
    const tClientId = 'test_client_id';
    const tClientSecret = 'test_client_secret';
    final tCredentials = IgdbCredentials(
      clientId: tClientId,
      clientSecret: tClientSecret,
    );

    test('Should return credentials when they exist in storage', () async {
      // Arrange
      when(
        () => mockStorage.read(key: 'igdb_client_id'),
      ).thenAnswer((_) async => tClientId);
      when(
        () => mockStorage.read(key: 'igdb_client_secret'),
      ).thenAnswer((_) async => tClientSecret);

      // Act
      final result = await repository.getIgdbCredentials();

      // Assert
      expect(result?.clientId, tClientId);
      expect(result?.clientSecret, tClientSecret);
      verify(() => mockStorage.read(key: any(named: 'key'))).called(2);
    });

    test('Should return null when one or both keys are missing', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final result = await repository.getIgdbCredentials();

      expect(result, isNull);
    });

    test('Should save credentials correctly', () async {
      // Arrange
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});

      // Act
      await repository.saveIgdbCredentials(tCredentials);

      // Assert
      verify(
        () => mockStorage.write(key: 'igdb_client_id', value: tClientId),
      ).called(1);
      verify(
        () =>
            mockStorage.write(key: 'igdb_client_secret', value: tClientSecret),
      ).called(1);
    });

    test('Should clear credentials correctly', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      await repository.clearCredentials();

      verify(() => mockStorage.delete(key: 'igdb_client_id')).called(1);
      verify(() => mockStorage.delete(key: 'igdb_client_secret')).called(1);
    });
  });

  group('CredentialsRepositoryImpl - Error Handling', () {
    test('getIgdbCredentials should return null and log on error', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenThrow(Exception('Storage error'));

      final result = await repository.getIgdbCredentials();

      expect(result, isNull);
    });

    test('saveIgdbCredentials should rethrow on error', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Write error'));

      expect(
        () => repository.saveIgdbCredentials(
          IgdbCredentials(clientId: 'a', clientSecret: 'b'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
