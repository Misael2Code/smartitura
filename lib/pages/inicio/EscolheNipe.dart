import 'package:Smartitura/pages/homePage.dart';
import 'package:Smartitura/pages/inicio/EscolheInstrumento.dart';
import 'package:Smartitura/services/InstrumentoMemoria.dart';
import 'package:flutter/material.dart';
import 'package:Smartitura/model/nipes.dart';

class EscolheNipe extends StatefulWidget {
  final String escolha; // Recebe a escolha do usuário ("Eu Canto" ou "Eu Toco")

  const EscolheNipe({super.key, required this.escolha});

  @override
  State<EscolheNipe> createState() => _EscolheNipeState();
}

class _EscolheNipeState extends State<EscolheNipe> {
  int? selectedIndex;
  String? vozSelecionada;

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> nipesParaExibir;

    // Determina quais nipes exibir com base na escolha do usuário
    if (widget.escolha == "Eu Canto") {
      nipesParaExibir = {
        'Vozes': Nipes.getVozes(),
      };
    } else {
      nipesParaExibir = {
        'Nipes': Nipes.getNipes(),
      };
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.escolha == "Eu Canto" ? "Em qual voz?" : "Em qual nipe?",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: widget.escolha == "Eu Canto"
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selectedIndex != null
                      ? Text(
                          'A Paz do Senhor, ${Nipes.tituloMusico(vozSelecionada!)}!',
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
                              itemCount: Nipes.getVozes().length,
                              itemBuilder: (context, index) {
                                final vozes = Nipes.getVozes()[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      vozSelecionada = Nipes.getVozes()[index];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: selectedIndex == index
                                          ? Colors.black26
                                          : Colors
                                              .white, // Fundo vermelho se selecionado
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      vozes,
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
                            onPressed: vozSelecionada != null
                                ? () {
                                    InstrumentoMemoria.salvarInstrumento(
                                        vozSelecionada.toString());
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage(
                                              tituloUsuario: Nipes.tituloMusico(
                                                  vozSelecionada!),
                                              page: 2)),
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 400,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: nipesParaExibir.entries.map((entry) {
                      List<String> nipes = entry.value;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: nipes.map((nipe) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Navegação para a próxima página do nipe (comentado)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EscolheInstrumento(escolha: nipe)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                nipe,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
