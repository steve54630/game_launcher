import 'package:file_picker/file_picker.dart';
import 'package:game_launcher/domain/repositories/file_picker.repository.dart';

class FilePickerService implements IFilePickerService {
  @override
  Future<String?> pickExecutable() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe', 'sh', 'app'],
    );
    return result?.files.single.path;
  }
}
