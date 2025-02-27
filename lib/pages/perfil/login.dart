import 'package:Smartitura/model/nipes.dart';
import 'package:Smartitura/pages/homePage.dart';
import 'package:Smartitura/pages/perfil/novoUsuario.dart';
import 'package:Smartitura/pages/perfil/perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? instrumentalidade;
  bool _isLoading = false;
  bool _isAuth = false;

  @override
  void initState() {
    super.initState();
    _getInstrumentalidade();
    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return _isAuth
        ? const Perfil()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bem-vindo, $instrumentalidade!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          } else if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      TextButton(
                        onPressed: _resetPassword,
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const Divider(height: 32),
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cadastrar',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      setState(() {
        _isAuth = true;
      });
      debugPrint('Usuário autenticado: ${user.email}');
      prefs.setString('USER', _emailController.text);
      prefs.setString('PASS', _passwordController.text);
    } else {
      setState(() {
        _isAuth = false;
      });
      debugPrint('Nenhum usuário autenticado.');
    }
  }

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String instrumento = prefs.getString('INSTRUMENTO').toString();
    FocusScope.of(context).requestFocus(FocusNode());
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Login realizado com sucesso!',
              style: TextStyle(color: Colors.white),
            ),
            margin: const EdgeInsets.all(30),
            elevation: 10,
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        _checkAuthStatus();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(tituloUsuario: instrumento, page: 4)));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao fazer login: ${e.message}',
              style: const TextStyle(color: Colors.black),
            ),
            margin: const EdgeInsets.all(30),
            elevation: 10,
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, insira seu e-mail para redefinir a senha.',
            style: TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(30),
          elevation: 10,
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'E-mail de redefinição enviado com sucesso.',
            style: TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(30),
          elevation: 10,
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao redefinir a senha: $e',
              style: const TextStyle(color: Colors.black)),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(30),
          elevation: 10,
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _registerUser() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const NovoUsuario()));
  }

  Future<void> _getInstrumentalidade() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var instrumento = prefs.getString('INSTRUMENTO');
    setState(() {
      instrumentalidade = Nipes.tituloMusico(instrumento.toString());
    });
  }
}
