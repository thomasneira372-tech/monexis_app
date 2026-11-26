import 'package:flutter/material.dart';
import '../servicios/api_servicios.dart';
import '../diseño/diseño_app.dart';
import 'vista_consulta.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  bool _loading = false;
  bool _ocultarClave = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final token = await _api.login(_usuarioCtrl.text.trim(), _claveCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ConsultaScreen(token: token)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o clave incorrectos'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildHeader(),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _buildCard(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.currency_exchange, color: AppColors.primary, size: 44),
          ),
          const SizedBox(height: 14),
          const Text(
            'Monexis',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consulta el cambio de tus divisas',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Iniciar sesión',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _usuarioCtrl,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppColors.textDark),
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textSoft),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _claveCtrl,
              obscureText: _ocultarClave,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Clave',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSoft),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _ocultarClave = !_ocultarClave),
                  icon: Icon(_ocultarClave ? Icons.visibility_off : Icons.visibility, color: AppColors.textSoft),
                ),
              ),
              onFieldSubmitted: (_) => _login(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu clave' : null,
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(AppColors.background),
                      ),
                    )
                  : const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}