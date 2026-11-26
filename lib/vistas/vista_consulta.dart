import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modelo/moneda.dart';
import '../modelo/cambio_moneda.dart';
import '../servicios/api_servicios.dart';
import '../diseño/diseño_app.dart';
import 'vista_login.dart';

class ConsultaScreen extends StatefulWidget {
  final String token;
  const ConsultaScreen({super.key, required this.token});

  @override
  State<ConsultaScreen> createState() => _ConsultaScreenState();
}

class _ConsultaScreenState extends State<ConsultaScreen> {
  final _api = ApiService();
  final _fmt = DateFormat('yyyy-MM-dd');
  final _fmtBonito = DateFormat('dd MMM yyyy');

  List<Moneda> _monedas = [];
  Moneda? _monedaSeleccionada;
  List<CambioMoneda> _cambios = [];

  DateTime _desde = DateTime(2025, 1, 1);
  DateTime _hasta = DateTime(2025, 1, 31);

  bool _loadingMonedas = true;
  bool _loadingCambios = false;
  bool _consultado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMonedas();
  }

  Future<void> _cargarMonedas() async {
    try {
      final lista = await _api.listarMonedas(widget.token);
      if (!mounted) return;
      setState(() {
        _monedas = lista;
        _loadingMonedas = false;
        if (lista.isNotEmpty) _monedaSeleccionada = lista.first;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingMonedas = false;
        _error = 'No se pudieron cargar las monedas';
      });
    }
  }

  void _mostrarBuscadorMonedas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _BuscadorMonedas(
            monedas: _monedas,
            onSeleccionar: (m) {
              setState(() => _monedaSeleccionada = m);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<void> _pickFecha(bool esDesde) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: esDesde ? _desde : _hasta,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.background,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => esDesde ? _desde = picked : _hasta = picked);
    }
  }

  Future<void> _consultar() async {
    if (_monedaSeleccionada == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loadingCambios = true;
      _error = null;
      _consultado = true;
    });
    try {
      final lista = await _api.listarPorPeriodo(
        token: widget.token,
        idMoneda: _monedaSeleccionada!.id,
        fechaInicio: _fmt.format(_desde),
        fechaFin: _fmt.format(_hasta),
      );
      if (!mounted) return;
      setState(() {
        _cambios = lista;
        _loadingCambios = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCambios = false;
        _cambios = [];
        _error = 'No se pudo obtener la consulta';
      });
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambios de Moneda'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loadingMonedas
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildFiltros(),
                Expanded(child: _buildResultados()),
              ],
            ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _mostrarBuscadorMonedas,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _monedaSeleccionada != null
                          ? '${_monedaSeleccionada!.moneda} (${_monedaSeleccionada!.sigla})'
                          : 'Buscar moneda...',
                      style: TextStyle(
                        color: _monedaSeleccionada != null ? AppColors.textDark : AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.textSoft),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildFechaBox('Desde', _desde, true)),
              const SizedBox(width: 10),
              Expanded(child: _buildFechaBox('Hasta', _hasta, false)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadingCambios ? null : _consultar,
            icon: const Icon(Icons.search),
            label: _loadingCambios
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(AppColors.background),
                    ),
                  )
                : const Text('Consultar Cambios'),
          ),
        ],
      ),
    );
  }

  Widget _buildFechaBox(String label, DateTime fecha, bool esDesde) {
    return InkWell(
      onTap: () => _pickFecha(esDesde),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _fmt.format(fecha),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados() {
    if (_loadingCambios) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 46, color: AppColors.danger),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
        ),
      );
    }
    if (!_consultado) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Selecciona una moneda y un rango de fechas,\nluego pulsa "Consultar Cambios".',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSoft, fontSize: 15),
          ),
        ),
      );
    }
    if (_cambios.isEmpty) {
      return const Center(
        child: Text(
          'No hay cambios registrados en ese periodo.',
          style: TextStyle(color: AppColors.textSoft),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _cambios.length,
      itemBuilder: (context, i) {
        final c = _cambios[i];
        final fechaBonita = _formatearFecha(c.fecha);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fechaBonita,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    const Text('Valor de cambio', style: TextStyle(fontSize: 12, color: AppColors.textSoft)),
                  ],
                ),
              ),
              Text(
                c.valor.toStringAsFixed(4),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final parsed = DateTime.parse(fecha);
      return _fmtBonito.format(parsed);
    } catch (_) {
      return fecha;
    }
  }
}

class _BuscadorMonedas extends StatefulWidget {
  final List<Moneda> monedas;
  final Function(Moneda) onSeleccionar;

  const _BuscadorMonedas({required this.monedas, required this.onSeleccionar});

  @override
  State<_BuscadorMonedas> createState() => _BuscadorMonedasState();
}

class _BuscadorMonedasState extends State<_BuscadorMonedas> {
  final _searchCtrl = TextEditingController();
  List<Moneda> _filtradas = [];

  @override
  void initState() {
    super.initState();
    _filtradas = widget.monedas;
  }

  void _filtrar(String query) {
    setState(() {
      _filtradas = widget.monedas.where((m) {
        final texto = '${m.moneda.toLowerCase()} ${m.sigla.toLowerCase()}';
        return texto.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            onChanged: _filtrar,
            autofocus: true,
            style: const TextStyle(color: AppColors.textDark),
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o sigla (ej. Peso, USD)...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSoft),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _filtradas.length,
              itemBuilder: (context, i) {
                final m = _filtradas[i];
                return ListTile(
                  title: Text(m.moneda, style: const TextStyle(color: AppColors.textDark)),
                  subtitle: Text(m.sigla, style: const TextStyle(color: AppColors.textSoft)),
                  onTap: () => widget.onSeleccionar(m),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}