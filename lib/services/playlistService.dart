class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;

  PlaylistService._internal();

  // Lista de músicas (playlist)
  final List<Map<String, dynamic>> _playlist = [];

  // Retorna a playlist
  List<Map<String, dynamic>> get playlist => List.unmodifiable(_playlist);

  // Adiciona um item à playlist
  void addToPlaylist(Map<String, dynamic> item) {
    _playlist.add(item);
  }

  // Remove um item da playlist
  void removeFromPlaylist(Map<String, dynamic> item) {
    _playlist.remove(item);
  }

  // Limpa a playlist
  Future<void> clearPlaylist() async {
    _playlist.clear();
  }
}
