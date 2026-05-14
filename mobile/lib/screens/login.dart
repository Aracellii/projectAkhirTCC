import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = Uri.parse('$apiBaseUrl/login');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final token = body['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _error = body['message'] ?? 'Login gagal. Coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo / Brand
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Heading
                  const Text(
                    'Selamat datang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  const SizedBox(height: 40),

                  // Error banner
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D4D).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF4D4D).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFFF6B6B),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Username wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF8A8FA8),
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lupa password?',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Button
                  _buildGradientButton(
                    label: 'Masuk',
                    loading: _loading,
                    onPressed: _login,
                  ),

                  const Spacer(),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: Color(0xFF8A8FA8),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: const Color(0xFF6C63FF),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8A8FA8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1C1F2E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2D3E), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF4D4D), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            loading ? 'Memproses...' : label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
