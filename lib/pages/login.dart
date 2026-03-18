import 'package:flutter/material.dart';
import 'package:green_pill/service/matrix_service.dart';
import 'package:matrix/matrix_api_lite/model/matrix_exception.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _matrixServerUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login'),
      ),
      body: Center(
        heightFactor: 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _matrixServerUrlController,
                decoration: InputDecoration(
                  labelText: 'Matrix Server URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await Provider.of<MatrixService>(context, listen: false).login(
                    homeserver: _matrixServerUrlController.text,
                    username: _usernameController.text, 
                    password: _passwordController.text
                  );
                } on MatrixException catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(e.errorMessage)),
                  );
                }catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Verbindung fehlgeschlagen')),
                  );

                  print(e);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Einloggen', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}