import 'package:Smartitura/model/usuario.dart';
import 'package:Smartitura/pages/homePage.dart';
import 'package:Smartitura/pages/inicio/CantaOuToca.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const Aplication());
}

class Aplication extends StatelessWidget {
  const Aplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smartitura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: validaSessao(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar a aplicação'));
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }

  Future<Widget> validaSessao() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instrumento = prefs.getString('INSTRUMENTO');
    String? user = prefs.getString('USER');
    String? pass = prefs.getString('PASS');

    if (user != null && pass != null) {
      Usuario.instance.usuario = user;
      Usuario.instance.senha = pass;
      return HomePage(tituloUsuario: instrumento ?? 'Usuário', page: 2);
    } else {
      return const Cantaoutoca();
    }
  }
}
