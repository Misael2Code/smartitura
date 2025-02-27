String formatarContador(int valor) {
  if (valor >= 1000000) {
    return '${(valor / 1000000).toStringAsFixed(1).replaceAll('.0', '')}mi';
  } else if (valor >= 1000) {
    return '${(valor / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
  } else {
    return valor.toString();
  }
}
