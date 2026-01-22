import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Color bgPurple = const Color(0xFF6C5CE7);

  Future<void> _handleRegister() async {
    // 1. Validasi Form (Email format, Pass length, dll) dijalankan di sini
    if (!_formKey.currentState!.validate()) return;

    // 2. Validasi Manual: Password Match
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 3. Lakukan Pendaftaran
      await ref.read(authControllerProvider).signUp(
            _emailCtrl.text.trim(),
            _passCtrl.text.trim(),
            _nameCtrl.text.trim(),
          );
      
      // 4. Segera Logout agar tidak otomatis masuk ke Home
      await ref.read(authControllerProvider).signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akun berhasil dibuat! Silakan login."), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context); // Kembali ke Login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: bgPurple),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Buat Akun Baru", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: bgPurple)),
              const Text("Mulai perjalanan kesehatan mentalmu hari ini.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              // NAMA (Validasi Standar: Tidak Boleh Kosong)
              _buildTextField(
                "Nama Lengkap", 
                Icons.person, 
                _nameCtrl
              ),
              const SizedBox(height: 16),
              
              // EMAIL (Validasi: Format Email)
              _buildTextField(
                "Email", 
                Icons.email, 
                _emailCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email wajib diisi";
                  // Regex sederhana untuk cek format email
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return "Format email tidak valid";
                  }
                  return null;
                }
              ),
              const SizedBox(height: 16),
              
              // PASSWORD (Validasi: Min 8 Karakter)
              _buildTextField(
                "Password", 
                Icons.lock, 
                _passCtrl, 
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Password wajib diisi";
                  if (value.length < 8) {
                    return "Password minimal 8 karakter";
                  }
                  return null;
                }
              ),
              const SizedBox(height: 16),
              
              // KONFIRMASI PASS
              _buildTextField(
                "Konfirmasi Password", 
                Icons.lock_outline, 
                _confirmPassCtrl, 
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Konfirmasi password wajib diisi";
                  if (value != _passCtrl.text) return "Password tidak cocok";
                  return null;
                }
              ),
              
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("DAFTAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget yang sudah dimodifikasi untuk menerima Validator Kustom
  Widget _buildTextField(
    String label, 
    IconData icon, 
    TextEditingController ctrl, 
    {
      bool isPassword = false, 
      String? Function(String?)? validator // Parameter opsional untuk validasi kustom
    }
  ) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: bgPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: bgPurple, width: 2), borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(12)),
      ),
      // Jika validator kustom tidak diisi, gunakan validasi default (tidak boleh kosong)
      validator: validator ?? (v) => v!.isEmpty ? "$label wajib diisi" : null,
    );
  }
}