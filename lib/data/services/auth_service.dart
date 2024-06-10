import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
    });
    return userCredential;
  }

  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

Future<void> sendMessage(String senderId, String receiverId, String message, File? imageFile) async {
  String imageUrl = '';
  if (imageFile != null) {
    imageUrl = await uploadImage(imageFile, 'messages/${DateTime.now().millisecondsSinceEpoch}');
  }
  
  await _firestore.collection('messages').add({
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'imageUrl': imageUrl, 
    'timestamp': FieldValue.serverTimestamp(),
  });
}

  Stream<QuerySnapshot> getMessages(String userId) {
    return _firestore.collection('messages')
      .where('receiverId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots();
  }

    Future<String> uploadImage(File image, String path) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }
}
