import 'package:Smartitura/pages/homePage.dart';
import 'package:Smartitura/services/formatarTexto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NovoUsuario extends StatefulWidget {
  const NovoUsuario({super.key});

  @override
  _NovoUsuarioState createState() => _NovoUsuarioState();
}

class _NovoUsuarioState extends State<NovoUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String fullName = '';
  String email = '';
  String uid = '';
  String password = '';
  String birthDate = '';
  String instrument = '';
  bool isSectionLeader = false;
  bool isWorshipGroupLeaderMaanaim = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var instrumento = prefs.getString('INSTRUMENTO');

      _formKey.currentState!.save();
      try {
        // Create user in Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get the uid from the authenticated user
        String userUid = userCredential.user!.uid;

        // Add user profile to Firestore using uid as the document ID
        await _firestore.collection('Usuarios').doc(userUid).set({
          'AllowAddSheetMusic': true,
          'AllowDeleteSheetMusic': false,
          'AllowEditSheetMusic': true,
          'BirthDate': birthDate,
          'FullName': fullName,
          'FullNameLowerCase': fullName.toLowerCase(),
          'Instrument': instrumento,
          'Email': email,
          'IsSectionLeaderDomMartins': false,
          'IsSectionLeader': isSectionLeader,
          'IsWorshipGroupLeaderDomMartins': false,
          'IsWorshipGroupLeaderMaanaim': isWorshipGroupLeaderMaanaim,
          'IsWorshipGroupMemberDomMartins': false,
          'Profile': 'grupolouvor',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cadastro realizado com sucesso!',
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
            duration: const Duration(seconds: 5),
          ),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      tituloUsuario: instrumento.toString(),
                      page: 2,
                    )));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao Novo Usuario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.navigate_before),
          color: Colors.white,
        ),
        title: const Text(
          'Cadastrando Novo Usuário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                inputFormatters: [CapitalizeWordsInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Digite seu nome completo' : null,
                onSaved: (value) => fullName = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Digite um e-mail válido' : null,
                onSaved: (value) => email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'A senha deve ter pelo menos 6 caracteres'
                    : null,
                onSaved: (value) => password = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento (DD/MM/AAAA)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Digite sua data de nascimento' : null,
                onSaved: (value) => birthDate = value!,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Responsável Grupo de Louvor'),
                  Switch(
                    value: isSectionLeader,
                    onChanged: (value) {
                      setState(() {
                        isSectionLeader = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Responsável Grupo de Louvor Maanaim'),
                  Switch(
                    value: isWorshipGroupLeaderMaanaim,
                    onChanged: (value) {
                      setState(() {
                        isWorshipGroupLeaderMaanaim = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Concluir',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
