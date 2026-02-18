import 'package:game_launcher/domain/entities/librairy.entity.dart';

class LibrarySourceModel extends LibrarySource {
  LibrarySourceModel({
    super.id,
    required super.path,
    required super.lastScanAt,
  });

  factory LibrarySourceModel.fromMap(Map<String, dynamic> map) {
    return LibrarySourceModel(
      id: map['id'] as int?,
      path: map['path'] as String,
      lastScanAt: DateTime.parse(map['last_scan_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'last_scan_at': lastScanAt.toIso8601String(),
    };
  }
}
