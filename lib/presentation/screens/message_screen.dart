import 'package:flutter/material.dart';
import 'package:act/data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;

  const MessageScreen({Key? key, required this.receiverId, required this.receiverEmail}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController _messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty || _image != null) {
      await _authService.sendMessage(
        _currentUserId,
        widget.receiverId,
        _messageController.text,
        _image
      );
      _messageController.clear();
      setState(() {
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message ${widget.receiverEmail}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _authService.getMessages(_currentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['message']),
                      subtitle: Text('From: ${data['senderId'] == _currentUserId ? 'Me' : data['senderId']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Send a message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
          if (_image != null) // Show thumbnail of the selected image
            Image.file(_image!, width: 100, height: 100),
        ],
      ),
    );
  }
}
