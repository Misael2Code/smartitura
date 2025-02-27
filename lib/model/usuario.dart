class Usuario {
  late String _usuario;
  late String _senha;

  Usuario._privateConstructor();

  static final Usuario _instance = Usuario._privateConstructor();

  static Usuario get instance => _instance;

  set usuario(String user) {
    _usuario = user;
  }

  set senha(String pass) {
    _senha = pass;
  }

  String get usuario => _usuario;

  String get senha => _senha;
}
