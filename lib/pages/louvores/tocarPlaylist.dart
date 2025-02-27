import 'package:Smartitura/services/abrirPartitura.dart';
import 'package:Smartitura/services/playlistService.dart';
import 'package:flutter/material.dart';

class TocarPlaylist extends StatefulWidget {
  final bool removeItem;
  const TocarPlaylist({super.key, required this.removeItem});

  @override
  State<TocarPlaylist> createState() => _TocarPlaylistState();
}

class _TocarPlaylistState extends State<TocarPlaylist> {
  List<Map<String, dynamic>> playlistItems = [];

  @override
  void initState() {
    super.initState();
    loadPlaylist();
  }

  void loadPlaylist() {
    setState(() {
      playlistItems = PlaylistService().playlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              playlistItems.isEmpty
                  ? const Text('Sua lista está vazia.')
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: playlistItems.length,
                        itemBuilder: (context, index) {
                          final item = playlistItems[index];
                          return ListTile(
                              onTap: () {
                                abrirPartitura(item['key'], context);
                                if (widget.removeItem) {
                                  PlaylistService().removeFromPlaylist(item);
                                }
                                setState(() {
                                  loadPlaylist();
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Colors.black12,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              title: Wrap(
                                children: [
                                  Text(
                                    "${item['id']}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              leading: Text(item['number']),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['composer']),
                                ],
                              ),
                              trailing: item['type']
                                      .toString()
                                      .contains('Não Oficial')
                                  ? null
                                  : const Icon(Icons.verified, size: 22));
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void abrirPartitura(String base64ToPDF, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbrirPartitura(base64Pdf: base64ToPDF),
      ),
    );
  }
}
