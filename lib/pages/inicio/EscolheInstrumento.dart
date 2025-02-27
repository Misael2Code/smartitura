import 'package:Smartitura/pages/homePage.dart';
import 'package:Smartitura/services/InstrumentoMemoria.dart';
import 'package:flutter/material.dart';
import 'package:Smartitura/model/nipes.dart';

class EscolheInstrumento extends StatefulWidget {
  final String escolha; // Recebe a escolha do usuário ("Eu Canto" ou "Eu Toco")

  const EscolheInstrumento({super.key, required this.escolha});

  @override
  State<EscolheInstrumento> createState() => _EscolheInstrumentoState();
}

class _EscolheInstrumentoState extends State<EscolheInstrumento> {
  int? selectedIndex;
  String? instrumentoSelecionado;

  @override
  Widget build(BuildContext context) {
    List<String> nipesParaExibir;
    nipesParaExibir = Nipes.getTodosOsNipes(widget.escolha);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Qual o seu instrumento?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedIndex != null
                ? Text(
                    'A Paz do Senhor, ${Nipes.tituloMusico(instrumentoSelecionado!)}!',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )
                : const SizedBox(height: 0),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: nipesParaExibir.length,
                        itemBuilder: (context, index) {
                          final instrumento = nipesParaExibir[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                instrumentoSelecionado = nipesParaExibir[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? Colors.black26
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                instrumento,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: instrumentoSelecionado != null
                          ? () async {
                              print(
                                  "Instrumento do Usuário: $instrumentoSelecionado");
                              await InstrumentoMemoria.salvarInstrumento(
                                  instrumentoSelecionado.toString());
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          tituloUsuario: Nipes.tituloMusico(
                                              instrumentoSelecionado!),
                                          page: 2,
                                        )),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Amém!',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
