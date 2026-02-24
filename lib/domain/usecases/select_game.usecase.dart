import 'package:game_launcher/domain/repositories/file_picker.repository.dart';

class PickGameFileUseCase {
  final IFilePickerService pickerService;

  PickGameFileUseCase(this.pickerService);

  Future<FileSelectionResult?> execute() async {
    final path = await pickerService.pickExecutable();

    if (path == null) return null;

    final fileName = path.split(RegExp(r'[/\\]')).last.split('.').first;

    return FileSelectionResult(path: path, displayName: fileName);
  }
}

class FileSelectionResult {
  final String path;
  final String displayName;

  FileSelectionResult({required this.path, required this.displayName});
}
