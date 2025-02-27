import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> incrementList(String uid) async {
    try {
      print('Vai tentar salvar a lista');
      final userDoc = _firestore.collection('Usuarios').doc(uid);

      // Tenta buscar o campo "Playlists"
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        int currentPlaylists = data?['Lists'] ?? 0;
        print('Current List $currentPlaylists');
        // Incrementa o valor do campo "Playlists"
        await userDoc.update({
          'Lists': currentPlaylists + 1,
        });
        print('Acrescentou');
      } else {
        // Caso o documento não exista, inicializa com o valor 1
        await userDoc.set({
          'Lists': 1,
        });
        print('Primeira lista desse usuário');
      }
    } catch (e) {
      print('Erro ao incrementar Listas: $e');
    }
  }
}
