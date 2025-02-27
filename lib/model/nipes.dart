class Nipes {
  // Lista de instrumentos e vozes
  static const List<String> metais = [
    'Trompete',
    'Trombone',
    'Tuba',
    'Trompa',
  ];

  static const List<String> madeiras = [
    'Clarinete',
    'Flauta Transversal',
    'Flautim Piccolo',
    'Fagote',
    'Contrafagote',
    'Corne Inglês',
    'Oboé',
    'Sax Alto',
    'Sax Soprano',
    'Sax Tenor',
  ];

  static const List<String> cordas = [
    'Violino',
    'Viola Erudita',
    'Violoncelo',
    'Contrabaixo Acústico',
    'Contrabaixo Elétrico',
    'Violão',
  ];

  static const List<String> percussao = [
    'Bateria',
    'Tímpano',
    'Marimba',
    'Vibrafone',
    'Bongo',
    'Chocalho',
    'Claves',
    'Xilofone',
  ];

  static const List<String> teclas = [
    'Piano',
    'Órgão',
    'Acordeom',
  ];

  static const List<String> vozes = [
    'Voz Soprano',
    'Voz Contralto',
    'Voz Tenor',
    'Voz Baixo',
  ];

  // Métodos para obter listas de cada nipe
  static List<String> getMetais() => metais;

  static List<String> getMadeiras() => madeiras;

  static List<String> getCordas() => cordas;

  static List<String> getPercussao() => percussao;

  static List<String> getTeclas() => teclas;

  static List<String> getVozes() => vozes;

  static List<String> getNipes() => todosOsNipes;

  // Método para obter todos os nipes em um único mapa
  static List<String> getTodosOsNipes(String escolha) {
    switch (escolha) {
      case 'Metais':
        return getMetais();
      case 'Madeiras':
        return getMadeiras();
      case 'Cordas':
        return getCordas();
      case 'Percussão':
        return getPercussao();
      case 'Teclas':
        return getTeclas();
      default:
        return [];
    }
  }

  static const List<String> todosOsNipes = [
    'Metais',
    'Madeiras',
    'Cordas',
    'Percussão',
    'Teclas',
  ];

  static const Map<String, String> instrumentosParaMusicos = {
    'acordeom': 'Acordeonista',
    'bateria': 'Baterista',
    'bombardino': 'Bombardinista',
    'bongo': 'Bongosista',
    'chocalho': 'Percussionista',
    'clarinete': 'Clarinetista',
    'claves': 'Percussionista',
    'contrabaixo acústico': 'Contrabaixista',
    'contrabaixo elétrico': 'Contrabaixista',
    'contrafagote': 'Contrafagotista',
    'corne inglês': 'Cornista',
    'flauta transversal': 'Flautista',
    'flautim piccolo': 'Flautista',
    'fagote': 'Fagotista',
    'marimba': 'Marimbista',
    'órgão': 'Organista',
    'oboé': 'Oboísta',
    'piano': 'Pianista',
    'sax alto': 'Saxofonista',
    'sax soprano': 'Saxofonista',
    'sax tenor': 'Saxofonista',
    'tímpano': 'Timpanista',
    'trombone': 'Trombonista',
    'trompa': 'Trompista',
    'trompete': 'Trompetista',
    'tuba': 'Tubista',
    'vibrafone': 'Vibrafonista',
    'viola erudita': 'Violista',
    'violão': 'Violonista',
    'violino': 'Violinista',
    'violoncelo': 'Violoncelista',
    'voz baixo': 'Baixo',
    'voz contralto': 'Contralto',
    'voz soprano': 'Soprano',
    'voz tenor': 'Tenor',
    'xilofone': 'Xilofonista',
  };

  // Método para obter o título do músico com base no instrumento
  static String tituloMusico(String instrumento) {
    return instrumentosParaMusicos[instrumento.toLowerCase()] ?? '';
  }
}
