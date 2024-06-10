import 'package:flutter/material.dart';
import 'package:act/domain/use_cases/login_use_case.dart';
import 'package:act/presentation/screens/register_screen.dart';
import 'package:act/presentation/screens/users_screen.dart';
import 'package:act/data/repositories/auth_repository.dart';
import 'package:act/data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final SignInUseCase _signInUseCase;

  @override
  void initState() {
    super.initState();
    _signInUseCase = SignInUseCase(AuthRepository(AuthService()));
  }

  Future<void> _login() async {
    try {
      await _signInUseCase.execute(_emailController.text, _passwordController.text);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => UsersScreen()));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
