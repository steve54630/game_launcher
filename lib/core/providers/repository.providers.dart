import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/data/repositories/process.repository.dart';
import 'package:game_launcher/data/repositories/settings.repository.dart';
import 'package:game_launcher/domain/repositories/credentails.repository.dart';
import 'package:game_launcher/domain/repositories/game.repository.dart';
import 'package:game_launcher/domain/repositories/igbd.repository.dart';
import 'package:game_launcher/domain/repositories/igbd_cache.repository.dart';
import 'package:game_launcher/domain/repositories/process.repository.dart';
import 'package:game_launcher/domain/repositories/settings.repository.dart';
import 'database.providers.dart';
import 'package:game_launcher/data/repositories/game.repository.dart';
import 'package:game_launcher/data/repositories/igbd.repository.dart';
import 'package:game_launcher/data/repositories/igbd_cache.repository.dart';
import 'package:game_launcher/data/repositories/credential.repository.dart';

final gameProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(ref.watch(databaseHelperProvider));
});

final igdbCacheProvider = Provider<IgdbCacheRepository>((ref) {
  return IgdbCacheRepositoryImpl(ref.watch(databaseHelperProvider));
});

final igdbSearchProvider = Provider<IgdbSearchRepository>((ref) {
  return IgdbSearchRepositoryImpl();
});

final credentialsProvider = Provider<CredentialsRepository>((ref) {
  return CredentialsRepositoryImpl(); // C'est ici que tu gères ton BYOK
});

final processProvider = Provider<ProcessRepository>((ref) {
  return ProcessRepositoryImpl();
});

final appSettingsProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepositoryImpl(ref.watch(databaseHelperProvider));
});
