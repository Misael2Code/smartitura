import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstrumentoMemoria {
  static const String _keyInstrumento = "INSTRUMENTO";

  // Salva Instrumento do Usuário na Memória
  static Future<void> salvarInstrumento(String instrumento) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInstrumento, instrumento);
    debugPrint("Instrumento salvo: $instrumento");
  }

  // Recupera o instrumento do usuário da memória
  static Future<String?> obterInstrumento() async {
    final prefs = await SharedPreferences.getInstance();
    final instrumento = prefs.getString(_keyInstrumento);
    debugPrint("Instrumento recuperado: $instrumento");
    return instrumento;
  }

  // Remove o instrumento salvo (opcional)
  static Future<void> removerInstrumento() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyInstrumento);
    debugPrint("Instrumento removido");
  }
}