import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contribuicoes {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> getTotalContribuicao() async {
    int totalContribuicao = await getTotalLouvoresAdicionados() +
        await getTotalArranjosAdicionados();
    return totalContribuicao;
  }

  /// Obtém o UID do usuário logado
  Future<String?> _getUserUID() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Verifica o total de louvores adicionados pelo usuário logado
  Future<int> getTotalLouvoresAdicionados() async {
    try {
      String? uid = await _getUserUID();
      if (uid == null) {
        throw Exception("Usuário não está logado.");
      }

      QuerySnapshot louvoresSnapshot = await firestore
          .collection('Louvores')
          .where('user', isEqualTo: uid)
          .get();

      return louvoresSnapshot.docs.length;
    } catch (e) {
      print('Erro ao obter total de louvores adicionados: $e');
      return 0;
    }
  }

  Future<int> getTotalArranjosAdicionados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? instrumento = prefs.getString('INSTRUMENTO');
    try {
      String? uid = await _getUserUID();
      if (uid == null) {
        throw Exception("Usuário não está logado.");
      }

      QuerySnapshot arranjosSnapshot = await firestore
          .collection(instrumento!)
          .where('user', isEqualTo: uid)
          .get();

      return arranjosSnapshot.docs.length;
    } catch (e) {
      print('Erro ao obter total de arranjos adicionados: $e');
      return 0;
    }
  }
}
