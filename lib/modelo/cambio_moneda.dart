class CambioMoneda {
  final String fecha;
  final double valor;

  CambioMoneda({required this.fecha, required this.valor});

  factory CambioMoneda.fromJson(Map<String, dynamic> json) {
    return CambioMoneda(
      fecha: json['fecha']?.toString() ?? '',
      valor: ((json['valor'] ?? 0) as num).toDouble(),
    );
  }
}