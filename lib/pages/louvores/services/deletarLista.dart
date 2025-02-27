import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteList(String listId, bool isOwner, String uidUser) async {
  if (isOwner) {
    FirebaseFirestore.instance
        .collection('Listas')
        .doc(listId)
        .update({'active': false});
  } else {
    final uid = uidUser;
    final doc = FirebaseFirestore.instance.collection('Listas').doc(listId);
    final data = (await doc.get()).data()!;
    final updatedShared =
        data['shared'].toString().split(',').where((id) => id != uid).join(',');

    doc.update({'shared': updatedShared});
  }
}
