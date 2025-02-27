import 'package:Smartitura/pages/louvores/acessarListas.dart';
import 'package:Smartitura/pages/louvores/buscarPartituras.dart';
import 'package:Smartitura/pages/louvores/adicionarLouvor.dart';
import 'package:Smartitura/pages/perfil/login.dart';
import 'package:Smartitura/services/playlistService.dart';
import 'package:Smartitura/services/servicoUsuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String tituloUsuario;
  final int page;

  const HomePage({super.key, required this.tituloUsuario, required this.page});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 2;
  bool addList = true;
  bool removeItem = false;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _page,
          items: <Widget>[
            const Icon(Icons.add, size: 30, color: Colors.white),
            const Icon(Icons.search, size: 30, color: Colors.white),
            FutureBuilder<Widget>(
              future: instrumentoUsuario(), // Espera o resultado do Future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error, color: Colors.white, size: 30);
                } else if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const Icon(Icons.music_note,
                    size: 30, color: Colors.white); // Caso não haja dados
              },
            ),
            const Icon(Icons.groups_2_rounded, size: 30, color: Colors.white),
            const Icon(Icons.perm_identity, size: 30, color: Colors.white),
          ],
          color: Colors.black,
          buttonBackgroundColor: Colors.black,
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
          height: 50,
        ),
        body: bodyPage());
  }

  Widget bodyPage() {
    switch (_page) {
      case 0:
        return const AdicionarLouvor();
      case 1:
        return BuscarPartituras(criarLista: addList);
      case 2:
        return const AcessarListas();
      //return TocarPlaylist(removeItem: removeItem);
      case 4:
        return const Login();
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_page.toString(), style: const TextStyle(fontSize: 160)),
            ElevatedButton(
              child: const Text('Go To Page of index 1'),
              onPressed: () {
                final CurvedNavigationBarState? navBarState =
                    _bottomNavigationKey.currentState;
                navBarState?.setPage(1);
              },
            )
          ],
        ),
      ),
    );
  }

  AppBar? appBarWidget() {
    Row? appBarTitle() {
      switch (_page) {
        case 0:
        case 1:
        case 2:
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        await PlaylistService().clearPlaylist();

                        final prefs = await SharedPreferences.getInstance();
                        String instrumento =
                            prefs.getString('INSTRUMENTO').toString();

                        await UserService().incrementList(
                            FirebaseAuth.instance.currentUser!.uid);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(
                                    tituloUsuario: instrumento, page: 2)));
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      )),
                  const Text(
                    'Limpar Lista',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Remover após leitura',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Transform.scale(
                      scale: 0.75,
                      child: Switch(
                          activeColor: Colors.grey,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.white, // botão
                          inactiveTrackColor: Colors.grey,
                          value: removeItem,
                          onChanged: (bool value) {
                            setState(() {
                              removeItem = value;
                            });
                          })),
                ],
              ),
            ],
          );
        case 4:
        default:
          return const Row();
      }
    }

    switch (_page) {
      case 0:
        return null;
      case 1:
        return null;
      case 4:
        return null;
      default:
        return AppBar(
          title: appBarTitle(),
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.black,
          backgroundColor: Colors.black,
          shadowColor: Colors.black,
        );
    }
  }

  Future<String?> instrumento() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('INSTRUMENTO');
  }

  Future<Widget> instrumentoUsuario() async {
    String? instrumentoName =
        await instrumento(); // Espera o resultado do Future

    Widget getPaddedImage(String assetPath) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Image(
          image: AssetImage(assetPath),
          color: Colors.white,
          width: 60,
        ),
      );
    }

    switch (instrumentoName?.toLowerCase()) {
      case 'acordeom':
        return getPaddedImage('images/icons/acordeom.png');
      case 'bateria':
        return getPaddedImage('images/icons/bateria.png');
      case 'bombardino':
        return getPaddedImage('images/icons/bombardino.png');
      case 'bongo':
        return getPaddedImage('images/icons/percussao.png');
      case 'chocalho':
        return getPaddedImage('images/icons/percussao.png');
      case 'clarinete':
        return getPaddedImage('images/icons/clarinete.png');
      case 'claves':
        return getPaddedImage('images/icons/percussao.png');
      case 'contrabaixo acústico':
        return getPaddedImage('images/icons/contrabaixo_acustico.png');
      case 'contrabaixo elétrico':
        return getPaddedImage('images/icons/contrabaixo_eletrico.png');
      case 'contrafagote':
        return getPaddedImage('images/icons/contrafagote.png');
      case 'corne inglês':
        return getPaddedImage('images/icons/corne_ingles.png');
      case 'flauta transversal':
        return getPaddedImage('images/icons/flauta_transversal.png');
      case 'flautim piccolo':
        return getPaddedImage('images/icons/flauta_transversal.png');
      case 'fagote':
        return getPaddedImage('images/icons/fagote.png');
      case 'marimba':
        return getPaddedImage('images/icons/percussao.png');
      case 'órgão':
        return getPaddedImage('images/icons/piano.png');
      case 'oboé':
        return getPaddedImage('images/icons/oboe.png');
      case 'piano':
        return getPaddedImage('images/icons/piano.png');
      case 'sax alto':
        return getPaddedImage('images/icons/sax_alto.png');
      case 'sax soprano':
        return getPaddedImage('images/icons/sax_soprano.png');
      case 'sax tenor':
        return getPaddedImage('images/icons/sax_tenor.png');
      case 'tímpano':
        return getPaddedImage('images/icons/percussao.png');
      case 'trombone':
        return getPaddedImage('images/icons/trombone.png');
      case 'trompa':
        return getPaddedImage('images/icons/trompa.png');
      case 'trompete':
        return getPaddedImage('images/icons/trompete.png');
      case 'tuba':
        return getPaddedImage('images/icons/tuba.png');
      case 'vibrafone':
        return getPaddedImage('images/icons/percussao.png');
      case 'viola erudita':
        return getPaddedImage('images/icons/cordas_erudita.png');
      case 'violão':
        return getPaddedImage('images/icons/violao.png');
      case 'violino':
        return getPaddedImage('images/icons/cordas_erudita.png');
      case 'violoncelo':
        return getPaddedImage('images/icons/cordas_erudita.png');
      case 'voz baixo':
        return getPaddedImage('images/icons/voz.png');
      case 'voz contralto':
        return getPaddedImage('images/icons/voz.png');
      case 'voz soprano':
        return getPaddedImage('images/icons/voz.png');
      case 'voz tenor':
        return getPaddedImage('images/icons/voz.png');
      case 'xilofone':
        return getPaddedImage('images/icons/percussao.png');
      default:
        return getPaddedImage('images/icons/default.png');
    }
  }
}
