import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_launcher/core/utils/database_helper.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper.instance);
