import 'package:game_launcher/domain/entities/discovery_result.entity.dart';

class ImportState {
  final DiscoveryResult?
  result; // Contient tout : path, match, status, proposals
  final bool isSaving;
  final String? error;

  ImportState({this.result, this.isSaving = false, this.error});

  ImportState copyWith({
    DiscoveryResult? Function()? result,
    bool? isSaving,
    String? error,
  }) {
    return ImportState(
      result: result != null ? result() : this.result,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}
