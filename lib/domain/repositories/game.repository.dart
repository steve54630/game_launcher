import "../entities/game.entity.dart";

abstract interface class GameRepository {
  // Récupère tous les jeux de la BDD
  Future<List<Game>> getAllGames();

  // Ajoute ou met à jour un jeu
  Future<void> upsertGame(Game game);

  // Supprime un jeu (mais garde éventuellement le cache si tu veux)
  Future<void> deleteGame(int id);

  Stream<List<Game>> watchAllGames();
}
