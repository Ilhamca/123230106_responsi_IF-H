// ============================================================
// HALAMAN REGISTER
// ============================================================
// Konsep yang digunakan:
// - StatefulWidget: widget dengan state yang bisa berubah
// - TextEditingController: mengontrol input text
// - Form & GlobalKey<FormState>: validasi form
// - GetX: state management & navigasi
// - SharedPreferences: menyimpan data user (via AuthService)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/controllers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // TextEditingController: mengambil & mengontrol nilai TextField
  // Harus di-dispose untuk mencegah memory leak
  // ============================================================
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // GlobalKey: mengidentifikasi Form secara unik untuk validasi
  final _formKey = GlobalKey<FormState>();

  // State lokal: apakah password tersembunyi
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ============================================================
  // Get.find<T>(): mendapatkan instance controller yang sudah dibuat
  // AuthController harus sudah di-register di GetMaterialApp routes
  // ============================================================
  final AuthController _authController = Get.find<AuthController>();

  // ============================================================
  // dispose(): dipanggil saat widget dihapus dari tree
  // WAJIB dispose controller untuk mencegah memory leak
  // ============================================================
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // Method submit form
  // ============================================================
  void _handleRegister() {
    // validate(): menjalankan semua validator di dalam Form
    // Mengembalikan true jika semua valid
    if (_formKey.currentState!.validate()) {
      _authController.register(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                const Icon(
                  Icons.rocket_launch_rounded,
                  size: 72,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar untuk mulai menjelajahi berita luar angkasa',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // ============================================================
                // FORM WIDGET
                // Membungkus semua TextField agar bisa divalidasi sekaligus
                // ============================================================
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ============================================================
                      // TextFormField: TextField dengan validasi
                      // validator: function yang mengembalikan pesan error (String?)
                      //            atau null jika valid
                      // ============================================================
                      TextFormField(
                        controller: _usernameController,
                        decoration: _inputDecoration(
                          'Username',
                          Icons.person_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Username minimal 3 karakter';
                          }
                          return null; // null = valid
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, // Sembunyikan teks
                        decoration: _inputDecoration(
                          'Password',
                          Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            // setState: memperbarui UI setelah state berubah
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: _inputDecoration(
                          'Konfirmasi Password',
                          Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // ============================================================
                      // Obx(): widget reaktif dari GetX
                      // Rebuild otomatis saat errorMessage berubah
                      // ============================================================
                      Obx(() {
                        if (_authController.errorMessage.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _authController.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Tombol Register dengan loading state
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _authController.isLoading.value
                                  ? null // Disable saat loading
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _authController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )),

                      const SizedBox(height: 16),

                      // Link ke halaman Login
                      TextButton(
                        // Get.back(): kembali ke halaman sebelumnya
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Sudah punya akun? Login di sini',
                          style: TextStyle(color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method untuk dekorasi TextField
  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
