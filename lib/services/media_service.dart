import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    if (_file != null) {
      return File(_file!.path);
    }
    return null;
  }

  Future<File?> getVideoFromGallery() async {
    final XFile? _file = await _picker.pickVideo(source: ImageSource.gallery);
    if (_file != null) {
      return File(_file!.path);
    }
    return null;
  }

  Future<File?> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }
}