import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AbrirPartitura extends StatefulWidget {
  final String base64Pdf;

  const AbrirPartitura({super.key, required this.base64Pdf});

  @override
  State<AbrirPartitura> createState() => _AbrirPartituraState();
}

class _AbrirPartituraState extends State<AbrirPartitura> {
  String? localPdfPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    decodeAndSavePdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Corpo principal (PDF)
          Positioned.fill(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : localPdfPath != null
                    ? PDFView(
                        filePath: localPdfPath,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageSnap: true,
                      )
                    : const Center(
                        child: Text('Falha ao carregar o PDF.'),
                      ),
          ),
          // AppBar flutuante transparente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: sharePdf,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> decodeAndSavePdf() async {
    try {
      // Decodificar o base64 para bytes
      final bytes = base64Decode(widget.base64Pdf);

      // Criar um arquivo temporário para salvar o PDF
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');

      // Escrever os bytes no arquivo
      await file.writeAsBytes(bytes);

      setState(() {
        localPdfPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao decodificar PDF: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void sharePdf() async {
    if (localPdfPath != null) {
      Share.shareXFiles([XFile(localPdfPath!)],
          text: 'Compartilhado via Smartitura');
    }
  }
}
