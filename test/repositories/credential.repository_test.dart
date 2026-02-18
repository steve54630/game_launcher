import 'package:flutter_test/flutter_test.dart';
import 'package:game_launcher/data/repositories/credential.repository.dart';
import 'package:mocktail/mocktail.dart'; // Ou mockito
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// On crée un mock du plugin
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage mockStorage;
  late CredentialsRepositoryImpl repository;

  setUp(() {
    mockStorage = MockSecureStorage();
    // /!\ Attention : Pour injecter le mock, tu dois modifier ton Impl
    // pour accepter l'instance de stockage dans le constructeur.
    repository = CredentialsRepositoryImpl(storage: mockStorage);
  });

  test('Should return credentials when they exist', () async {
    // Arrange
    when(
      () => mockStorage.read(key: 'igdb_client_id'),
    ).thenAnswer((_) async => 'my_id');
    when(
      () => mockStorage.read(key: 'igdb_client_secret'),
    ).thenAnswer((_) async => 'my_secret');

    // Act
    final result = await repository.getIgdbCredentials();

    // Assert
    expect(result?.clientId, 'my_id');
    expect(result?.clientSecret, 'my_secret');
  });
}
