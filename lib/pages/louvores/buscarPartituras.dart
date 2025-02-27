import 'package:Smartitura/services/abrirPartitura.dart';
import 'package:Smartitura/services/playlistService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BuscarPartituras extends StatefulWidget {
  final bool criarLista;

  const BuscarPartituras({super.key, required this.criarLista});

  @override
  State<BuscarPartituras> createState() => _BuscarPartiturasState();
}

class _BuscarPartiturasState extends State<BuscarPartituras> {
  List<Map<String, dynamic>> collections = [];
  List<Map<String, dynamic>> filteredCollections = [];
  bool isLoading = true;
  bool isOffline = false;
  bool isProcessing = false;
  String searchQuery = "";
  Set<String> selectedItems = {};
  Set<String> cachedItems = {};
  String message = "";

  @override
  void initState() {
    super.initState();
    checkConnectionAndFetchCollections();
    loadCachedItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 10,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: filterCollections,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Pesquisar...',
                  prefixIcon: const Icon(Icons.search),
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
            const SizedBox(
              width: 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Transform.scale(
                    scale: 1,
                    child: IconButton(
                        onPressed: () {
                          downloadAllItems();
                        },
                        icon: isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Icon(
                                Icons.download,
                                color: Colors.black,
                              ))),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.amber,
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              isLoading
                  ? const CircularProgressIndicator()
                  : filteredCollections.isEmpty
                      ? const Text('Nenhuma coleção encontrada.')
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: filteredCollections.length,
                            itemBuilder: (context, index) {
                              final item = filteredCollections[index];
                              bool isSelected =
                                  selectedItems.contains(item['key']);
                              bool isCached = cachedItems.contains(item['key']);

                              return item['aprovated']
                                  ? ListTile(
                                      onTap: () => abrirOuAdicionar(
                                          item['key'], context, isSelected),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.black12,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      title: Text(
                                        "${item['id']}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  size: 18),
                                              const SizedBox(width: 2),
                                              Text('Arr. ${item['composer']}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        item['number']
                                                                .toString()
                                                                .contains(
                                                                    'Avulso')
                                                            ? '${item['number']}'
                                                            : 'Nº ${item['number']}',
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          item['type']
                                                                  .toString()
                                                                  .contains(
                                                                      'Não Oficial')
                                                              ? const SizedBox(
                                                                  width: 0)
                                                              : const Icon(
                                                                  Icons
                                                                      .verified,
                                                                  size: 18),
                                                          Text(
                                                              ' ${item['type']}'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: isProcessing &&
                                              selectedItems
                                                  .contains(item['key'])
                                          ? const CircularProgressIndicator()
                                          : IconButton(
                                              onPressed: () =>
                                                  toggleDownload(item),
                                              icon: Icon(
                                                isCached
                                                    ? Icons.cloud_done
                                                    : Icons
                                                        .cloud_download_outlined,
                                                color: isCached
                                                    ? Colors.green
                                                    : Colors.black,
                                              ),
                                            ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> downloadAllItems() async {
    setState(() {
      isProcessing = true;
    });

    final prefs = await SharedPreferences.getInstance();

    // Salva todos os itens no cache
    await prefs.setStringList(
      'cachedItems',
      collections.map((e) => e['key'].toString()).toList(),
    );

    setState(() {
      cachedItems = collections.map((e) => e['key'].toString()).toSet();
      isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(30),
        elevation: 10,
        backgroundColor: Colors.white,
        content: const Wrap(
          children: [
            Text(
              "Todos os itens foram salvos para acesso offline.",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> checkConnectionAndFetchCollections() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? instrumento = prefs.getString("INSTRUMENTO");

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var instrumentoSnapshot = await firestore.collection(instrumento!).get();

      List<Map<String, dynamic>> instrumentData = instrumentoSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      setState(() {
        collections = instrumentData;
        filteredCollections = instrumentData;
        isLoading = false;
        isOffline = false;
      });

      debugPrint("Documentos carregados com sucesso!");
    } catch (e) {
      setState(() {
        isLoading = false;
        isOffline = true;
        message = "Modo offline ativado. Itens listados do cache local.";
      });
      debugPrint('Erro ao buscar documentos: $e');
    }
  }

  Future<void> loadCachedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cachedData = prefs.getStringList('cachedItems');

    if (cachedData != null) {
      setState(() {
        cachedItems = cachedData.toSet();
      });
    } else {
      debugPrint('Nenhum item no cache.');
    }
  }

  Future<void> saveCachedItems(String item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedItems', jsonEncode(cachedItems.toList()));
  }

  void filterCollections(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredCollections = collections
          .where((item) => item.toString().toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  Future<void> toggleDownload(Map<String, dynamic> item) async {
    String textSnack = '';
    setState(() {
      isProcessing = true;
    });

    if (cachedItems.contains(item['key'])) {
      cachedItems.remove(item['key']);
      textSnack = ' foi removido dos downloads.';
    } else {
      cachedItems.add(item['key']);
      textSnack = ' foi baixado com sucesso.';
    }

    await saveCachedItems(item['id']);

    setState(() {
      isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(30),
        elevation: 10,
        backgroundColor: Colors.white,
        content: Wrap(
          children: [
            Text(
              item['id'],
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Text(
              textSnack,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.normal),
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

  void abrirOuAdicionar(
      String base64ToPDF, BuildContext context, bool isSelected) async {
    late String snackbarText;
    final item =
        collections.firstWhere((element) => element['key'] == base64ToPDF);

    if (widget.criarLista) {
      if (isSelected) {
        snackbarText = 'Removido da sua lista: ';
        setState(() {
          selectedItems.remove(base64ToPDF);
        });
      } else {
        snackbarText = 'Adicionado à sua lista: ';
        PlaylistService().addToPlaylist(item);

        setState(() {
          selectedItems.add(base64ToPDF);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: const EdgeInsets.all(30),
          elevation: 10,
          backgroundColor: Colors.white,
          content: Wrap(
            children: [
              Text(
                snackbarText,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              Text(
                '${item['id']}',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
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
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AbrirPartitura(base64Pdf: base64ToPDF),
        ),
      );
    }
  }
}
