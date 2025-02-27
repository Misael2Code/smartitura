import 'dart:io';

import 'package:Smartitura/model/sampleItem.dart';
import 'package:Smartitura/services/formatarTexto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdicionarLouvor extends StatefulWidget {
  const AdicionarLouvor({super.key});

  @override
  State<AdicionarLouvor> createState() => _AdicionarLouvorState();
}

class _AdicionarLouvorState extends State<AdicionarLouvor> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> louvores = [];
  List<Map<String, dynamic>> filteredLouvores = [];
  TextEditingController composerController = TextEditingController();
  bool isOfficial = false;
  Color tileColor = Colors.black;
  bool isLoading = true;
  String searchQuery = "";
  SampleItem? selectedItem;
  bool? _allowEditMusic = false;
  bool? _allowAddSheetMusic = false;
  bool? _allowEditSheetMusic = false;
  bool? _allowDeleteSheetMusic = false;
  bool? _allowDeleteMusic = false;
  String? pdfBase64;
  FilePickerResult? result;
  bool isAlreadyOfficial = false;
  String selectedFileName = 'Buscar Partitura';

  @override
  void initState() {
    super.initState();
    fetchLouvores();
    obterPermissaoUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 15,
        automaticallyImplyLeading: false,
        title: TextField(
          onChanged: filterLouvores,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: 'Pesquisar...',
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade800,
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            filled: true,
            fillColor: Colors.grey.shade300,
          ),
        ),
      ),
      floatingActionButton: _uid != null
          ? FloatingActionButton(
              onPressed: () => showAddLouvorPopup(context),
              elevation: 5,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : const SizedBox(height: 0),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              isLoading
                  ? const CircularProgressIndicator()
                  : filteredLouvores.isEmpty
                      ? const Text('Nenhum louvor encontrado.')
                      : Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredLouvores.length,
                            itemBuilder: (context, index) {
                              final louvor = filteredLouvores[index];
                              return ListTile(
                                trailing: _uid != null
                                    ? PopupMenuButton<SampleItem>(
                                        iconColor: Colors.white,
                                        color: Colors.white,
                                        initialValue: selectedItem,
                                        onSelected: (SampleItem item) {
                                          Navigator.pop(context);
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<SampleItem>>[
                                              if (_allowEditMusic!)
                                                PopupMenuItem<SampleItem>(
                                                  value:
                                                      SampleItem.allowEditMusic,
                                                  child: TextButton(
                                                      child: const Text(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          'Editar Louvor'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        showEditLouvorPopup(
                                                          context,
                                                          louvor['id'],
                                                          louvor['number']
                                                              .toString(),
                                                        );
                                                      }),
                                                ),
                                              if (_allowDeleteMusic!)
                                                PopupMenuItem<SampleItem>(
                                                    value: SampleItem
                                                        .allowDeleteMusic,
                                                    child: TextButton(
                                                        child: const Text(
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                            'Deletar Louvor'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDeleteLouvorPopup(
                                                              context,
                                                              louvor['id']);
                                                        })),
                                              if (_allowAddSheetMusic!)
                                                PopupMenuItem<SampleItem>(
                                                    value: SampleItem
                                                        .allowAddSheetMusic,
                                                    child: TextButton(
                                                      child: const Text(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          'Incluir Arranjo'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        incluirArranjo(
                                                            context, louvor);
                                                      },
                                                    )),
                                              if (_allowEditSheetMusic!)
                                                PopupMenuItem<SampleItem>(
                                                    value: SampleItem
                                                        .allowEditSheetMusic,
                                                    child: TextButton(
                                                      child: const Text(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          'Editar Arranjo'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        editarArranjo(
                                                            context, louvor);
                                                      },
                                                    )),
                                              if (_allowDeleteSheetMusic!)
                                                PopupMenuItem<SampleItem>(
                                                    value: SampleItem
                                                        .allowDeleteSheetMusic,
                                                    child: TextButton(
                                                      child: const Text(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          'Deletar Arranjo'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        deletarArranjo(
                                                            context, louvor);
                                                      },
                                                    )),
                                            ])
                                    : const SizedBox(height: 0),
                                leading: const Icon(Icons.music_note,
                                    color: Colors.white),
                                title: Text(
                                  "${louvor['id']}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Número: ${louvor['number']}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.black12),
                                ),
                                tileColor: tileColor,
                                minTileHeight: 3,
                                onTap: () {},
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 6),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> obterPermissaoUsuario() async {
    if (_uid != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var userDoc = await firestore.collection('Usuarios').doc(_uid).get();
      String profileName = userDoc.data()?['Profile'] ?? '';
      var profileDoc =
          await firestore.collection('Perfil').doc(profileName).get();
      var profileData = profileDoc.data();

      setState(() {
        _allowAddSheetMusic = profileData?['AllowAddSheetMusic'] ?? false;
        _allowEditSheetMusic = profileData?['AllowEditSheetMusic'] ?? false;
        _allowDeleteSheetMusic = profileData?['AllowDeleteSheetMusic'] ?? false;
        _allowEditMusic = profileData?['AllowEditMusic'] ?? false;
        _allowDeleteMusic = profileData?['AllowDeleteMusic'] ?? false;
      });
    }
  }

  Future<void> fetchLouvores() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Filtrar documentos com 'aprovated' igual a true
      var snapshot = await firestore
          .collection('Louvores')
          .where('aprovated', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> louvorData = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      setState(() {
        louvores = louvorData;
        filteredLouvores = louvorData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Erro ao buscar louvores: $e');
    }
  }

  void filterLouvores(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredLouvores = louvores;
      } else {
        filteredLouvores = louvores
            .where(
                (item) => item.toString().toLowerCase().contains(searchQuery))
            .toList();
      }
    });
  }

  void showAddLouvorPopup(BuildContext context) async {
    String? nomeLouvor;
    String? numeroLouvor;

    await showDialog(
      barrierColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 20,
          shadowColor: Colors.black,
          backgroundColor: Colors.black,
          title: const Text('Adicionar Louvor',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                inputFormatters: [CapitalizeWordsInputFormatter()],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Nome',
                    hintText: 'Ex.: Vou Clamar',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
                onChanged: (value) => nomeLouvor = value,
              ),
              const SizedBox(height: 6),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Nº Louvor',
                    hintText: 'Ex.: Avulso',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
                keyboardType: TextInputType.number,
                onChanged: (value) => numeroLouvor = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ),
            TextButton(
              onPressed: () {
                if (nomeLouvor != null && numeroLouvor != null) {
                  addLouvor(nomeLouvor!, numeroLouvor!, _uid!);
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> addLouvor(String nome, String numero, String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Obter o campo Profile do usuário logado
      var userDoc = await firestore.collection('Usuarios').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado.');
      }

      String? profileName = userDoc.data()?['Profile'];
      if (profileName == null) {
        throw Exception('Perfil do usuário não definido.');
      }

      // Obter o perfil relacionado ao usuário
      var profileDoc =
          await firestore.collection('Perfil').doc(profileName).get();
      if (!profileDoc.exists) {
        throw Exception('Perfil não encontrado.');
      }

      bool allowAddMusic = profileDoc.data()?['AllowAddMusic'] ?? false;
      String profileGroup = profileDoc.id; // Nome do perfil do usuário

      // Verificar se o usuário pode adicionar música
      if (!allowAddMusic) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Você não tem permissão para adicionar novos louvores.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade400,
            margin: const EdgeInsets.all(30),
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Determinar o valor do campo 'aprovated'
      bool isApproved = profileGroup != 'grupolouvor';

      // Adicionar o louvor na coleção
      await firestore.collection('Louvores').doc(nome).set({
        'number': int.parse(numero),
        'aprovated': isApproved,
        'date': DateTime.now().toIso8601String(),
        'user': uid,
      });

      setState(() {
        fetchLouvores();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profileName.contains('grupolouvor')
                ? 'Obrigado por contribuir! O louvor será avaliado e, se aprovado, adicionado à base de dados.'
                : 'Obrigado por contribuir. O Louvor foi adicionado com sucesso!',
            style: const TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 7),
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
      debugPrint('Erro ao adicionar louvor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro ao adicionar o louvor: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(30),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void showEditLouvorPopup(
      BuildContext context, String currentNome, String currentNumero) async {
    String? nomeLouvor = currentNome;
    String? numeroLouvor = currentNumero;

    await showDialog(
      barrierColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 20,
          shadowColor: Colors.black,
          backgroundColor: Colors.black,
          title: const Text('Editar Louvor',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                inputFormatters: [CapitalizeWordsInputFormatter()],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Nome',
                    hintText: 'Ex.: Vou Clamar',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
                controller: TextEditingController(text: currentNome),
                onChanged: (value) => nomeLouvor = value,
              ),
              const SizedBox(height: 6),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Nº Louvor',
                    hintText: 'Ex.: Avulso',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: currentNumero),
                onChanged: (value) => numeroLouvor = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                if (nomeLouvor != null && numeroLouvor != null) {
                  updateLouvor(nomeLouvor!, numeroLouvor!, _uid!, currentNome);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateLouvor(
      String nome, String numero, String uid, String oldNome) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Obter o campo Profile do usuário logado
    var userDoc = await firestore.collection('Usuarios').doc(uid).get();
    if (!userDoc.exists) {
      throw Exception('Usuário não encontrado.');
    }

    String? profileName = userDoc.data()?['Profile'];
    if (profileName == null) {
      throw Exception('Perfil do usuário não definido.');
    }

    // Obter o perfil relacionado ao usuário
    var profileDoc =
        await firestore.collection('Perfil').doc(profileName).get();
    if (!profileDoc.exists) {
      throw Exception('Perfil não encontrado.');
    }

    String profileGroup = profileDoc.id; // Nome do perfil do usuário

    // Determinar o valor do campo 'aprovated'r
    bool isApproved = profileGroup != 'grupolouvor';

    try {
      // Atualizar o louvor na coleção
      await firestore.collection('Louvores').doc(oldNome).delete();
      await firestore.collection('Louvores').doc(nome).set({
        'number': int.parse(numero),
        'aprovated': isApproved,
        'date': DateTime.now().toIso8601String(),
        'user': uid,
      });

      setState(() {
        fetchLouvores();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Louvor atualizado com sucesso!',
            style: TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 5),
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
      debugPrint('Erro ao atualizar louvor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro ao atualizar o louvor: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade400,
          margin: const EdgeInsets.all(30),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void showDeleteLouvorPopup(BuildContext context, String louvorName) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirmar Exclusão',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esta ação é irreversível. Tem certeza que deseja apagar o louvor?',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      deleteLouvor(louvorName, _uid!, context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Apagar',
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

  Future<void> deleteLouvor(
      String louvorName, String uid, BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Verificar se o louvor existe antes de deletar
      var louvorDoc =
          await firestore.collection('Louvores').doc(louvorName).get();
      if (!louvorDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Louvor "$louvorName" não encontrado.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade400,
            margin: const EdgeInsets.all(30),
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Excluir o louvor
      await firestore.collection('Louvores').doc(louvorName).delete();

      setState(() {
        fetchLouvores();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Louvor apagado com sucesso!',
            style: TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 5),
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
      debugPrint('Erro ao apagar louvor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao apagar o louvor: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade400,
          margin: const EdgeInsets.all(30),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void incluirArranjo(BuildContext context, Map<String, dynamic> louvor) async {
    final prefs = await SharedPreferences.getInstance();
    var instrumento = prefs.getString('INSTRUMENTO');

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? fullName;
    String? profile;

    // Obtém o nome completo e o perfil do usuário
    var userDoc = await firestore.collection('Usuarios').doc(_uid).get();
    if (userDoc.exists) {
      fullName = userDoc.data()?['FullName'];
      profile = userDoc.data()?['Profile'];
    }

    String defaultComposer = fullName ?? "Desconhecido";
    bool isGroupLouvor = profile == "grupolouvor";

    showModalBottomSheet(
      elevation: 5,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.grey.shade900),
          child: Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          Text(
                            louvor['id'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        'Número: ${louvor['number']}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white54),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.black,
                        ),
                        label: Text(
                          selectedFileName.contains('Buscar Partitura')
                              ? '$selectedFileName de $instrumento'
                              : selectedFileName,
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          await selecionarArquivoPDF();
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap(
                          children: [
                            Text(
                              'A partitura deve estar em formato .pdf',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        inputFormatters: [CapitalizeWordsInputFormatter()],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        enabled: true,
                        controller: composerController,
                        onSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          prefixIconColor: Colors.white54,
                          labelText: "Compositor",
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Ex.: $defaultComposer',
                          hintStyle:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      if (!isGroupLouvor)
                        CheckboxListTile(
                          title: const Text(
                            "Arranjo Oficial",
                            style: TextStyle(color: Colors.white),
                          ),
                          activeColor: Colors.grey,
                          value: isOfficial,
                          onChanged: (value) async {
                            if (value == true) {
                              var snapshot = await firestore
                                  .collection(instrumento.toString())
                                  .where('id', isEqualTo: louvor['id'])
                                  .where('number', isEqualTo: louvor['number'])
                                  .where('type', isEqualTo: 'Oficial')
                                  .get();

                              if (snapshot.docs.isNotEmpty) {
                                _exibirMensagem(
                                  context,
                                  mensagem:
                                      'Já existe um arranjo oficial para este louvor.',
                                  corFundo: Colors.red.shade400,
                                );
                                return;
                              }
                            }
                            setState(() {
                              isOfficial = value ?? false;
                            });
                          },
                        ),
                      isAlreadyOfficial
                          ? Text(
                              'Este louvor já tem um arranjo oficial! Ajuste o outro primeiro.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red.shade400, fontSize: 14))
                          : const SizedBox(height: 0),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: selectedFileName
                                        .contains('Buscar Partitura')
                                    ? null
                                    : () async {
                                        var withThisComposer = await firestore
                                            .collection(instrumento.toString())
                                            .where('number',
                                                isEqualTo: louvor['number'])
                                            .where('id',
                                                isEqualTo: louvor['id'])
                                            .where('composer',
                                                isEqualTo: composerController
                                                        .text.isEmpty
                                                    ? "Desconhecido"
                                                    : composerController.text)
                                            .get();

                                        if (withThisComposer.docs.isEmpty) {
                                          var snapshot = await firestore
                                              .collection(
                                                  instrumento.toString())
                                              .where('number',
                                                  isEqualTo: louvor['number'])
                                              .where('id',
                                                  isEqualTo: louvor['id'])
                                              .get();

                                          String documentName = louvor['id'];
                                          if (snapshot.docs.isNotEmpty) {
                                            int existingCount =
                                                snapshot.docs.length;
                                            documentName =
                                                "$documentName[${existingCount + 1}]";
                                          }

                                          await firestore
                                              .collection(
                                                  instrumento.toString())
                                              .doc(documentName)
                                              .set({
                                            'id': louvor['id'],
                                            'aprovated': !isGroupLouvor,
                                            'composer':
                                                composerController.text.isEmpty
                                                    ? "Desconhecido"
                                                    : composerController.text,
                                            'date': DateTime.now(),
                                            'key': pdfBase64,
                                            'number': louvor['number'],
                                            'type': isOfficial
                                                ? "Oficial"
                                                : "Não Oficial",
                                            'user': _uid,
                                          });

                                          _exibirMensagem(
                                            context,
                                            mensagem:
                                                'Arranjo incluído com sucesso!',
                                            corFundo: Colors.green.shade400,
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          Navigator.pop(context);
                                          _exibirMensagem(
                                            context,
                                            mensagem:
                                                'Desculpe, mas já existe um arranjo desse louvor feito por este compositor, ou o compositor é desconhecido.',
                                            corFundo: Colors.red.shade400,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text(
                                  "Incluir",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<String?> selecionarArquivoPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        List<int> fileBytes = await file.readAsBytes();

        setState(() {
          selectedFileName = result.files.single.name;
          print('Arquivo PDF Selecionado: $selectedFileName');
          pdfBase64 = base64Encode(fileBytes);
        });
        if (pdfBase64 == null) {
          _exibirMensagem(
            context,
            mensagem: 'Seleção de arquivo cancelada.',
          );
        }
        return pdfBase64;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao selecionar arquivo PDF: $e');
      return null;
    }
  }

  void _exibirMensagem(BuildContext context,
      {required String mensagem, Color corFundo = Colors.grey}) {
    if (mensagem == 'Já existe um arranjo oficial para este louvor.') {
      setState(() {
        isAlreadyOfficial = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: corFundo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 10,
          duration: const Duration(seconds: 7),
          margin: const EdgeInsets.all(30),
        ),
      );
    }
  }

  void editarArranjo(BuildContext context, Map<String, dynamic> louvor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? instrumento = prefs.getString('INSTRUMENTO');

      if (instrumento == null) {
        _exibirMensagem(context,
            mensagem: 'Instrumento não definido.',
            corFundo: Colors.red.shade400);
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> arranjos = [];
      String? selectedDocId;

      // Obtém os arranjos disponíveis para o louvor
      final querySnapshot = await firestore
          .collection(instrumento)
          .where('id', isEqualTo: louvor['id'])
          .where('number', isEqualTo: louvor['number'])
          .get();

      arranjos = querySnapshot.docs;

      if (arranjos.isEmpty) {
        _exibirMensagem(context,
            mensagem: 'Nenhum arranjo encontrado.',
            corFundo: Colors.orange.shade400);
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shadowColor: Colors.black,
                elevation: 5,
                backgroundColor: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Column(
                  children: [
                    const Text(
                      'Editar Arranjo',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const Text(
                      'Selecione um arranjo para editar',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      color: Colors.grey,
                      height: 1,
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.all(4),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: arranjos.length,
                    itemBuilder: (BuildContext context, int index) {
                      var arranjo = arranjos[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Text(
                              arranjo.data()['id'] ?? 'Desconhecido',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            const SizedBox(width: 2),
                            arranjo
                                        .data()['type']
                                        ?.toString()
                                        .contains('Não Oficial') ==
                                    true
                                ? const SizedBox(width: 0)
                                : const Icon(
                                    color: Colors.white54,
                                    Icons.verified,
                                    size: 14,
                                  )
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_stories,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Nº ${arranjo.data()['number'] ?? 'Desconhecido'}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Arr. ${arranjo.data()['composer'] ?? 'Desconhecido'}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ],
                        ),
                        tileColor: selectedDocId == arranjo.id
                            ? Colors.green.shade400
                            : Colors.transparent,
                        onTap: () {
                          setState(() {
                            selectedDocId = arranjo.id;
                            isOfficial = arranjo.data()['type'] == 'Oficial';
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedDocId == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            var selectedArranjo = arranjos.firstWhere(
                                (arranjo) => arranjo.id == selectedDocId);
                            showBottomSheetEdit(
                                context, selectedArranjo.data());
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: selectedDocId == null
                            ? Colors.grey.shade800
                            : Colors.green.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text(
                      'Próximo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      _exibirMensagem(context,
          mensagem: 'Erro ao carregar arranjos.',
          corFundo: Colors.red.shade400);
    }
  }

  void showBottomSheetEdit(
      BuildContext context, Map<String, dynamic> louvor) async {
    final prefs = await SharedPreferences.getInstance();
    var instrumento = prefs.getString('INSTRUMENTO');

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? profile;

    // Obtém o nome completo e o perfil do usuário
    var userDoc = await firestore.collection('Usuarios').doc(_uid).get();
    if (userDoc.exists) {
      profile = userDoc.data()?['Profile'];
    }

    bool isGroupLouvor = profile == "grupolouvor";

    // Preenchendo o controlador com os valores existentes
    composerController.text = louvor['composer'] ?? "Desconhecido";
    isOfficial = louvor['type'] == "Oficial";
    selectedFileName = "${louvor['id']}"; // Apenas um exemplo de exibição
    pdfBase64 = louvor['key'];

    showModalBottomSheet(
      elevation: 5,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.grey.shade900,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          Text(
                            louvor['id'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Número: ${louvor['number']}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white54),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon:
                            const Icon(Icons.upload_file, color: Colors.black),
                        label: Text(
                          selectedFileName,
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          await selecionarArquivoPDF();
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap(
                          children: [
                            Text(
                              'A partitura deve estar em formato .pdf',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        inputFormatters: [CapitalizeWordsInputFormatter()],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        controller: composerController,
                        onSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          prefixIconColor: Colors.white54,
                          labelText: "Compositor",
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      if (!isGroupLouvor)
                        CheckboxListTile(
                          title: const Text(
                            "Arranjo Oficial",
                            style: TextStyle(color: Colors.white),
                          ),
                          activeColor: Colors.grey,
                          value: isOfficial,
                          onChanged: (value) async {
                            if (value == true) {
                              var snapshot = await firestore
                                  .collection(instrumento.toString())
                                  .where('id', isEqualTo: louvor['id'])
                                  .where('number', isEqualTo: louvor['number'])
                                  .where('type', isEqualTo: 'Oficial')
                                  .get();

                              if (snapshot.docs.isNotEmpty) {
                                _exibirMensagem(
                                  context,
                                  mensagem:
                                      'Já existe um arranjo oficial para este louvor.',
                                  corFundo: Colors.red.shade400,
                                );
                                return;
                              }
                            }
                            setState(() {
                              isOfficial = value ?? false;
                            });
                          },
                        ),
                      isAlreadyOfficial
                          ? Text(
                              'Este louvor já tem um arranjo oficial! Ajuste o outro primeiro.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red.shade400, fontSize: 14))
                          : const SizedBox(height: 0),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await firestore
                                      .collection(instrumento.toString())
                                      .doc(louvor['id'])
                                      .update({
                                    'composer': composerController.text.isEmpty
                                        ? "Desconhecido"
                                        : composerController.text,
                                    'type':
                                        isOfficial ? "Oficial" : "Não Oficial",
                                    'key': pdfBase64,
                                    'date': DateTime.now(),
                                  });

                                  _exibirMensagem(
                                    context,
                                    mensagem: 'Arranjo atualizado com sucesso!',
                                    corFundo: Colors.green.shade400,
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  "Atualizar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void deletarArranjo(BuildContext context, Map<String, dynamic> louvor) async {
    final prefs = await SharedPreferences.getInstance();
    var instrumento = prefs.getString('INSTRUMENTO');

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Exibe o BottomSheet para confirmar exclusão
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Confirmação de Exclusão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Deseja excluir um arranjo deste louvor?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Fecha o BottomSheet
                      // Obtém os arranjos na coleção do instrumento com `aprovated == true`
                      var snapshot = await firestore
                          .collection(instrumento.toString())
                          .where('id', isEqualTo: louvor['id'])
                          .where('aprovated', isEqualTo: true)
                          .get();

                      if (snapshot.docs.isEmpty) {
                        _exibirMensagem(
                          context,
                          mensagem:
                              'Não há arranjos disponíveis para este louvor.',
                          corFundo: Colors.red.shade400,
                        );
                        return;
                      }

                      // Exibe os arranjos em um popup para seleção
                      _exibirPopupSelecionarArranjo(context, snapshot.docs,
                          firestore, instrumento.toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Excluir',
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

  void _exibirPopupSelecionarArranjo(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> arranjos,
    FirebaseFirestore firestore,
    String instrumento,
  ) {
    String? selectedDocId;
    bool isOfficial = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shadowColor: Colors.black,
              elevation: 5,
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  const Text(
                    'Excluindo Arranjo',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const Text(
                    'Clique em um arranjo para excluí-lo',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    color: Colors.grey,
                    height: 1,
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.all(4),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Exibe aviso caso seja um arranjo oficial
                    if (isOfficial)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Você está deletando um arranjo oficial',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: arranjos.length,
                      itemBuilder: (BuildContext context, int index) {
                        var arranjo = arranjos[index];
                        return ListTile(
                          title: Row(
                            children: [
                              Text(
                                arranjo.data()['id'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(width: 2),
                              arranjo
                                      .data()['type']
                                      .toString()
                                      .contains('Não Oficial')
                                  ? const SizedBox(width: 0)
                                  : const Icon(
                                      color: Colors.white54,
                                      Icons.verified,
                                      size: 14,
                                    )
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_stories,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Nº ${arranjo.data()['number']}',
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Arr. ${arranjo.data()['composer']}',
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          tileColor: selectedDocId == arranjo.id
                              ? Colors.red.shade400
                              : Colors.transparent,
                          onTap: () {
                            setState(() {
                              selectedDocId = arranjo.id;
                              isOfficial = arranjo.data()['type'] == 'Oficial';
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedDocId == null
                      ? null
                      : () async {
                          // Deleta o documento selecionado
                          await firestore
                              .collection(instrumento)
                              .doc(selectedDocId)
                              .delete();
                          Navigator.pop(context);
                          _exibirMensagem(
                            context,
                            mensagem: 'Arranjo excluído com sucesso!',
                            corFundo: Colors.green.shade400,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedDocId == null
                        ? Colors.grey
                        : Colors.red.shade400,
                  ),
                  child: const Text(
                    'Deletar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
