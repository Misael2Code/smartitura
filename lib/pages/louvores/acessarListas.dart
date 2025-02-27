import 'package:Smartitura/pages/louvores/services/compartilharLista.dart';
import 'package:Smartitura/pages/louvores/services/deletarLista.dart';
import 'package:Smartitura/pages/louvores/services/visibilidadeLista.dart';
import 'package:Smartitura/services/formatarContador.dart';
import 'package:Smartitura/services/formatarTexto.dart';
import 'package:Smartitura/services/servicoUsuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AcessarListas extends StatefulWidget {
  const AcessarListas({super.key});

  @override
  State<AcessarListas> createState() => _AcessarListasState();
}

class _AcessarListasState extends State<AcessarListas> {
  TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> _selectedLists = [];
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> listas = [];
  String? userName;
  bool isConnected = true;
  int liked = 0;
  int shared = 0;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    loadListas();
    buscarNomeUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedLists.isEmpty
          ? null
          : AppBar(
              title: Text('${_selectedLists.length} lista(s) selecionada(s)',
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
              backgroundColor: Colors.grey.shade100,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedLists.clear();
                  });
                },
              ),
              titleSpacing: 0,
            ),
      body: _uid == null
          ? Center(
              child: Text('Faça o login para visualizar ou criar listas.',
                  style: TextStyle(color: Colors.grey.shade800)),
            )
          : Center(
              child: listas.isEmpty
                  ? Text(
                      'Nenhuma lista disponível.',
                      style: TextStyle(color: Colors.grey.shade800),
                    )
                  : ListView.builder(
                      itemCount: listas.length,
                      itemBuilder: (context, index) {
                        final lista = listas[index];

                        final isOwner = lista['user'] == _uid;
                        final isShared = lista['shared'].contains(_uid);
                        final isLiked = lista['liked']?.contains(_uid) ?? false;

                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _selectedLists
                                  .add({'id': lista['id'], 'isOwner': isOwner});
                            });
                          },
                          onTap: () {
                            if (_selectedLists.isNotEmpty) {
                              if (_selectedLists.any(
                                  (list) => list.containsValue(lista['id']))) {
                                setState(() {
                                  _selectedLists.removeWhere(
                                      (list) => list['id'] == lista['id']);
                                  _selectedLists.removeWhere(
                                      (list) => list['id'] == lista['id']);
                                });
                              } else {
                                setState(() {
                                  _selectedLists.add(
                                      {'id': lista['id'], 'isOwner': isOwner});
                                });
                              }
                            } else {
                              print('Clicou na lista: ${lista['id']}');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                lista['id'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isShared)
                                    const Text(
                                      'COMPARTILHADA COM VOCÊ',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  Text(
                                    'Criado por: ${lista['userName']}',
                                    style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () => _toggleLike(
                                                  lista['id'], isLiked),
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color:
                                                    isLiked ? Colors.red : null,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                textAlign: TextAlign.start,
                                                formatarContador(
                                                    lista['likedCount']),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.share),
                                              onPressed: isOwner
                                                  ? () {
                                                      compartilharLista(
                                                          context,
                                                          lista['id'],
                                                          searchController,
                                                          _uid);
                                                      loadListas();
                                                    }
                                                  : lista['allShared']
                                                      ? () {
                                                          compartilharLista(
                                                              context,
                                                              lista['id'],
                                                              searchController,
                                                              _uid);
                                                          loadListas();
                                                        }
                                                      : null,
                                            ),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                textAlign: TextAlign.start,
                                                formatarContador(
                                                    lista['sharedCount']),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(
                                                  Icons.queue_music_rounded),
                                            ),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                '0',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: _selectedLists.isNotEmpty
                                  ? Checkbox(
                                      activeColor: Colors.red.shade400,
                                      checkColor: Colors.white,
                                      value: _selectedLists.any((selected) =>
                                          selected['id'] == lista['id']),
                                      onChanged: (bool? isSelected) {
                                        if (isSelected == true) {
                                          setState(() {
                                            _selectedLists.add({
                                              'id': lista['id'],
                                              'isOwner': isOwner
                                            });
                                          });
                                        } else {
                                          setState(() {
                                            _selectedLists.removeWhere((list) =>
                                                list['id'] == lista['id']);
                                          });
                                        }
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        lista['public']
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: isOwner
                                          ? () {
                                              toggleVisibility(lista['id'],
                                                  lista['public'], context);
                                              loadListas();
                                            }
                                          : null,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: _selectedLists.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                for (var list in _selectedLists) {
                  final listId = list['id'];
                  final isOwner = list['isOwner'];

                  await deleteList(listId, isOwner, _uid!);
                }
                loadListas();
              },
              mini: true,
              backgroundColor: Colors.red.shade400,
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            )
          : FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black,
              onPressed: () {
                _criarNovaLista(context);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
    );
  }

  void _toggleLike(String listId, bool isLiked) async {
    final docRef = FirebaseFirestore.instance.collection('Listas').doc(listId);
    if (isLiked) {
      await docRef.update({
        'liked': FieldValue.arrayRemove([_uid])
      });
    } else {
      await docRef.update({
        'liked': FieldValue.arrayUnion([_uid])
      });
    }
    loadListas();
  }

  Future<void> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = result != ConnectivityResult.none;
    });
  }

  Future<void> loadListas() async {
    if (isConnected == true && _uid != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Listas')
          .where('active', isEqualTo: true)
          .where('user', isEqualTo: _uid)
          .get();

      final sharedSnapshot = await FirebaseFirestore.instance
          .collection('Listas')
          .where('active', isEqualTo: true)
          .where('shared', arrayContains: _uid)
          .get();

      setState(() {
        listas = [
          ...snapshot.docs.map((doc) {
            final data = doc.data();
            data['likedCount'] = data['liked']?.length ?? 0;
            data['sharedCount'] = data['shared']?.length ?? 0;
            return data;
          }),
          ...sharedSnapshot.docs.map((doc) {
            final data = doc.data();
            data['likedCount'] = data['liked']?.length ?? 0;
            data['sharedCount'] = data['shared']?.length ?? 0;
            return data;
          }),
        ];
      });
    }
  }

  Future<String> buscarNomeUsuario() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var user = await firestore.collection('Usuarios').doc(_uid).get();
    if (user.exists) {
      setState(() {
        userName = user.data()?['FullName'];
      });
    }
    return userName!;
  }

  void _criarNovaLista(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();
    bool isPublic = false;
    bool allShared = false;

    showModalBottomSheet(
      backgroundColor: Colors.grey.shade800,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Criar Nova Lista',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                inputFormatters: [CapitalizeWordsInputFormatter()],
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Lista',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Permitir Compartilhamento',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                  Switch(
                    activeColor: Colors.green,
                    hoverColor: Colors.grey,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade200,
                    value: allShared,
                    onChanged: (value) {
                      setState(() {
                        allShared = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tornar Lista Pública',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                  Switch(
                    activeColor: Colors.green,
                    hoverColor: Colors.grey,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade200,
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                ],
              ),
              const Text(
                'Listas públicas podem ser localizadas por outros músicos, mas para eles acessarem o conteúdo da lista é necessário que você conceda permissão.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nomeController.text.isNotEmpty) {
                    final String listaId = nomeController.text.trim();

                    try {
                      await FirebaseFirestore.instance
                          .collection('Listas')
                          .doc(listaId) // Define o nome do documento
                          .set({
                        'id': listaId,
                        'user': _uid,
                        'userName': userName,
                        'public': isPublic,
                        'allShared': allShared,
                        'active': true,
                        'shared': [],
                        'date': DateTime.now(),
                      });

                      Navigator.pop(context); // Fecha o BottomSheet
                      loadListas(); // Atualiza as listas exibidas
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Lista criada com sucesso!'),
                        backgroundColor: Colors.green.shade400,
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: const Duration(seconds: 5),
                      ));

                      await UserService().incrementList(
                          FirebaseAuth.instance.currentUser!.uid);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Erro ao criar lista: $e'),
                        backgroundColor: Colors.red.shade400,
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: const Duration(seconds: 8),
                      ));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          const Text('Por favor, insira um nome para a lista.'),
                      backgroundColor: Colors.white,
                      elevation: 10,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 5),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Criar Lista',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
