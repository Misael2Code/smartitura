import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void toggleVisibility(String listId, bool isPublic, BuildContext context) {
    FirebaseFirestore.instance
        .collection('Listas')
        .doc(listId)
        .update({'public': !isPublic}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isPublic ? 'Lista agora está privada.' : 'Lista agora está pública.',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ));    
    });
  }