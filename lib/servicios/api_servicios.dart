import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelo/moneda.dart';
import '../modelo/cambio_moneda.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<String?> login(String usuario, String clave) async {
    final url = Uri.parse('$baseUrl/api/usuarios/login/$usuario/$clave');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('token') && data['token'] != null) {
          return data['token'].toString();
        }
        return null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Moneda>> listarMonedas(String token) async {
    final url = Uri.parse('$baseUrl/api/monedas'); // <--- RUTA CORREGIDA
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Moneda.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error ${response.statusCode}');
  }

  Future<List<CambioMoneda>> listarPorPeriodo({
    required String token,
    required int idMoneda,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    final url = Uri.parse('$baseUrl/api/monedas/cambiosporperiodo'); // <--- RUTA CORREGIDA
    final response = await http.post( // <--- MÉTODO POST
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'idMoneda': idMoneda,
        'desde': fechaInicio,
        'hasta': fechaFin,
      }),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CambioMoneda.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error ${response.statusCode}');
  }
}