import 'package:flutter/material.dart';
import 'package:act/data/services/auth_service.dart';
import 'package:act/presentation/screens/message_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _authService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['email']),
                    trailing: IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MessageScreen(receiverId: document.id, receiverEmail: data['email']),
                        ));
                      },
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}
