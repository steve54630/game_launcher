import 'package:file_picker/file_picker.dart';

class FilePickerService {
  static Future<String?> pickExecutable() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'], // On limite aux exécutables
      dialogTitle: 'Sélectionner l\'exécutable du jeu',
    );

    if (result != null && result.files.single.path != null) {
      return result.files.single.path;
    }
    return null;
  }
}
