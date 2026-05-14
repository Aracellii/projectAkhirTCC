import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = Uri.parse('$apiBaseUrl/register');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 201) {
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _error = body['message'] ?? 'Registrasi gagal. Coba lagi.';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2A2D3E),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Logo
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

                const SizedBox(height: 28),

                // Heading
                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Daftarkan diri Anda untuk memulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8A8FA8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

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
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$',
                          ).hasMatch(v)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
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
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (v.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Terms notice
                
                const SizedBox(height: 28),

                // Register Button
                _buildGradientButton(
                  label: 'Daftar Sekarang',
                  loading: _loading,
                  onPressed: _register,
                ),

                const SizedBox(height: 28),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Color(0xFF8A8FA8), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
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
