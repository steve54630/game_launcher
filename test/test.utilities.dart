// test/utils/test_db_utils.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:game_launcher/core/utils/database_helper.dart';

Future<DatabaseHelper> createTestDatabase() async {
  sqfliteFfiInit();
  final dbHelper = DatabaseHelper.test();

  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

  await dbHelper.onConfigure(db);
  await dbHelper.createDB(db, 1);
  dbHelper.setTestDatabase(db);

  return dbHelper;
}
