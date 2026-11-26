class Moneda {
  final int id;
  final String moneda;
  final String sigla;

  Moneda({required this.id, required this.moneda, required this.sigla});

  factory Moneda.fromJson(Map<String, dynamic> json) {
    return Moneda(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      moneda: (json['nombre'] ?? json['moneda'] ?? '') as String,
      sigla: (json['sigla'] ?? json['Sigla'] ?? '') as String,
    );
  }
}