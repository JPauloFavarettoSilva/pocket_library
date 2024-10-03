import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocket_library/Lista.dart';
import 'package:pocket_library/Models/User.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
  setState(() {
    isLoading = true;
  });

  final User loginData = User(
    userName: userNameController.text,
    password: passwordController.text,
  );

  final response = await http.post(
    Uri.parse('https://localhost:7026/api/users/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(loginData.toJson()), 
  );

  setState(() {
    isLoading = false;
  });

  if (response.statusCode == 200) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LivrosScreen()), 
    );

  } else if (response.statusCode == 404) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuário não encontrado. Verifique suas credenciais.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao fazer login: ${response.statusCode}')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userNameController,
              decoration: InputDecoration(labelText: 'Nome'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      loginUser(context);
                    },
                    child: Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
