import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadUserPfp({
    required File file,
    required String uid,
  }) async {
    Reference fileRef = _firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then(
      (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = _firebaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then(
      (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }
    Future<String?> uploadMediaToChat({
    required File file, required String chatID, required MediaType mediaType}) async {
    String fileExtension = p.extension(file.path);
    Reference fileRef = _firebaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}$fileExtension');
    UploadTask task = fileRef.putFile(file);
    return task.then(
      (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }

  Future<String?> uploadAudioToStorage({required File audioFile, required String chatID}) async {
    try {
      String fileExtension = p.extension(audioFile.path);
      Reference storageReference = FirebaseStorage.instance
          .ref('chats/$chatID/audios')
          .child('${DateTime.now().toIso8601String()}$fileExtension');

      UploadTask uploadTask = storageReference.putFile(audioFile);
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        return await storageReference.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading audio file: $e');
    }
    return null;
  }

}