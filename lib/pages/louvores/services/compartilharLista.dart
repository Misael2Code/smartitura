import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void compartilharLista(BuildContext context, String listId,
    TextEditingController searchController, String uid) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      ValueNotifier<List<Map<String, dynamic>>> searchResults =
          ValueNotifier([]);

      void searchUsers(String query) async {
        if (query.isEmpty) {
          searchResults.value = [];
          return;
        }

        query = query.toLowerCase();

        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('Usuarios')
            .where('FullNameLowerCase', isGreaterThanOrEqualTo: query)
            .where('FullNameLowerCase', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        List<Map<String, dynamic>> results = usersSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id,
            'name': data['FullName'] ?? '',
            'email': data['Email'] ?? '',
            'picture': data['Picture'] ?? '',
          };
        }).toList();

        searchResults.value = results;
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  hintText: 'Buscar por nome',
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
                onChanged: searchUsers,
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: searchResults,
                builder: (context, results, _) {
                  if (results.isEmpty) {
                    return Center(
                        child: Text(
                      'Nenhum usuário encontrado.',
                      style: TextStyle(color: Colors.grey.shade800),
                    ));
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];
                      final pictureBase64 = user['picture'];
                      ImageProvider? imageProvider;

                      if (pictureBase64.isNotEmpty) {
                        try {
                          final decodedBytes = base64Decode(pictureBase64);
                          imageProvider = MemoryImage(decodedBytes);
                        } catch (e) {
                          imageProvider =
                              const AssetImage('assets/default_avatar.png');
                        }
                      } else {
                        imageProvider =
                            const AssetImage('assets/default_avatar.png');
                      }

                      return user['uid'] == uid
                          ? null
                          : ListTile(
                              leading: CircleAvatar(
                                backgroundImage: imageProvider,
                              ),
                              title: Text(
                                user['name'],
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                user['email'],
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                              onTap: () async {
                                searchController.clear();

                                // Adicionar UID ao campo `shared`
                                await FirebaseFirestore.instance
                                    .collection('Listas')
                                    .doc(listId)
                                    .update({
                                  'shared': FieldValue.arrayUnion([user['uid']])
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Lista compartilhada com ${user['name']}'),
                                    backgroundColor: Colors.green.shade400,
                                    elevation: 5,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      side:
                                          const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
