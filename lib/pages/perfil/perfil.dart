import 'dart:convert';
import 'package:Smartitura/pages/homePage.dart';
import 'package:Smartitura/pages/inicio/CantaOuToca.dart';
import 'package:Smartitura/pages/perfil/configuracoes.dart';
import 'package:Smartitura/pages/perfil/minhaConta.dart';
import 'package:Smartitura/pages/perfil/privacidade.dart';
import 'package:Smartitura/pages/perfil/redefinirSenha.dart';
import 'package:Smartitura/services/contribuicoes.dart';
import 'package:Smartitura/services/formatarContador.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? interacoes = '0';
  String? _base64Image;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  String _nome = 'carregando...';
  String _listTotal = '0';
  int _indexPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPicture();
    _loadUserFull();
    _interacoes();
  }

  Widget paginaEscolhida() {
    switch (_indexPage) {
      case 1: //Minha Conta
        return const MinhaConta();
      case 2: //Privacidade
        return const Privacidade();
      case 3: //Configuração
        return const Configuracoes();
      default:
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.only(top: 100),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 44),
                          Center(
                            child: Wrap(
                              children: [
                                Text(
                                  _nome,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Text(interacoes!,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const Text(
                                      'Colaborações',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 11),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Text(_listTotal,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const Text('Listas',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<int>(
                                  future: getTotalLikesForUser(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('0');
                                    } else if (snapshot.hasError) {
                                      return const Text('Erro',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 16));
                                    } else {
                                      final totalLikes = snapshot.data ?? 0;
                                      return Column(
                                        children: [
                                          Text(
                                            formatarContador(
                                                totalLikes), // Formata o valor total obtido
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'Curtidas',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => setState(() {
                              _indexPage = 1;
                            }),
                            child: Card(
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.person,
                                    color: Colors.red.shade200),
                                title: const Text(
                                  "Minha Conta",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                                trailing: const Icon(Icons.navigate_next,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Cantaoutoca())),
                            child: Card(
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.compare_arrows,
                                    color: Colors.red.shade200),
                                title: const Text(
                                  "Trocar Instrumento/Voz",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                                trailing: const Icon(Icons.navigate_next,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(() {
                              _indexPage = 2;
                            }),
                            child: Card(
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.shield,
                                    color: Colors.red.shade200),
                                title: const Text(
                                  "Privacidade",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                                trailing: const Icon(Icons.navigate_next,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RedefinirSenha()),
                            ),
                            child: Card(
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.lock_reset,
                                    color: Colors.red.shade200),
                                title: const Text(
                                  "Redefinir Senha",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                                trailing: const Icon(Icons.navigate_next,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(() {
                              _indexPage = 3;
                            }),
                            child: Card(
                              elevation: 3,
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.settings,
                                    color: Colors.red.shade200),
                                title: const Text(
                                  "Configurações",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                                trailing: const Icon(Icons.navigate_next,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Card(
                            elevation: 3,
                            color: Colors.white,
                            child: ListTile(
                              onTap: () {
                                unDownloadAllItems();
                              },
                              leading: Icon(Icons.delete_forever_rounded,
                                  color: Colors.red.shade200),
                              title: Text("Limpar Downloads",
                                  style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.normal)),
                              trailing: Icon(Icons.navigate_next,
                                  color: Colors.red.shade200),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 3,
                            color: Colors.white,
                            child: ListTile(
                              onTap: _showLogoutConfirmation,
                              leading: Icon(Icons.logout,
                                  color: Colors.red.shade200),
                              title: Text("Sair",
                                  style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.normal)),
                              trailing: Icon(Icons.navigate_next,
                                  color: Colors.red.shade200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(60)),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: _base64Image == null
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : ClipOval(
                                    child: Image.memory(
                                      base64Decode(_base64Image!),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                          ),
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 18,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return paginaEscolhida();
  }

  Future<void> _loadUserFull() async {
    try {
      if (_uid != null) {
        var userDoc = await _firestore.collection('Usuarios').doc(_uid).get();
        if (userDoc.exists) {
          setState(() {
            _nome = userDoc.data()?['FullName'] ?? 'Usuário';
            _listTotal = formatarContador(userDoc.data()?['Lists'] ?? '0');
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar o nome do usuário: $e");
    }
  }

  Future<int> getTotalLikesForUser() async {
    try {
      // Obtém o UID do usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado.');
      }

      final uid = user.uid;

      // Consulta na coleção "Listas" os documentos onde "user" é igual ao UID do usuário
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Listas')
          .where('user', isEqualTo: uid)
          .get();

      // Soma o tamanho do array "liked" para cada documento encontrado
      int totalLikes = 0;
      for (var doc in querySnapshot.docs) {
        final liked = doc.data()['liked'] as List? ?? [];
        totalLikes += liked.length;
      }

      return totalLikes;
    } catch (e) {
      print('Erro ao obter o total de curtidas: $e');
      return 0;
    }
  }

  Future<String> _interacoes() async {
    var qtd = await Contribuicoes().getTotalContribuicao();
    setState(() {
      interacoes = formatarContador(qtd);
    });
    return interacoes!;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
      await _firestore
          .collection('Usuario')
          .doc(_uid)
          .update({'Picture': _base64Image});
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String instrumento = prefs.getString('INSTRUMENTO').toString();
    await _auth.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage(tituloUsuario: instrumento, page: 4)));
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Colors.grey.shade900,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Deseja realmente sair da sessão?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        backgroundColor: Colors.red.shade400),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        backgroundColor: Colors.green.shade400),
                    child: const Text(
                      "Confirmar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadUserPicture() async {
    try {
      if (_uid != null) {
        var userDoc = await _firestore.collection('Usuarios').doc(_uid).get();
        if (userDoc.exists) {
          setState(() {
            _base64Image = userDoc.data()?['Picture'];
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar a imagem do usuário: $e");
    }
  }

  Future<void> unDownloadAllItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String textSnack = '';

    if (prefs.getStringList('cachedItems') == null) {
      textSnack = 'A lista de downloads já está vazia.';
    } else {
      await prefs.remove('cachedItems');
      if (prefs.getString('cachedItems') == null) {
        textSnack = 'Todos os itens foram removidos do cache.';
      } else {
        textSnack = 'Erro ao remover todos os itens do cache.';
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(30),
        elevation: 10,
        backgroundColor: Colors.red.shade400,
        content: Wrap(
          children: [
            Text(
              textSnack,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
