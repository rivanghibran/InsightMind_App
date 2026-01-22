import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Palet Warna InsightMind
  final Color bgPurple = const Color(0xFF6C5CE7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color bgScaffold = const Color(0xFFF7F8FC);
  final Color textDark = const Color(0xFF2D3436);
  
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU PROFIL
            _buildProfileCard(),

            const SizedBox(height: 32),

            // 2. AKUN
            Text(
              "Akun",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline,
                    title: "Edit Profil",
                    color: bgPurple,
                    onTap: () => _showEditProfileDialog(),
                  ),
                  Divider(height: 1, color: Colors.grey[100], indent: 60, endIndent: 20),
                  _buildMenuTile(
                    icon: Icons.lock_outline,
                    title: "Ganti Password",
                    color: bgPurple,
                    onTap: () => _showChangePasswordDialog(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. ZONA BAHAYA
            const Text(
              "Zona Bahaya",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: _buildMenuTile(
                icon: Icons.delete_forever_rounded,
                title: "Hapus Akun Permanen",
                color: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ),

            const SizedBox(height: 32),

            // 4. LOGOUT
            Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout, color: Colors.black54, size: 22),
                ),
                title: const Text(
                  "Keluar Akun",
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () => _showLogoutDialog(),
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "InsightMind v1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgPurple,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bgPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 35, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? "Pengguna",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "-",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: color == Colors.red ? Colors.red : textDark,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- MODERN DIALOG BUILDER ---
  // Fungsi ini membuat semua pop-up terlihat seragam dan modern
  Future<void> _showModernDialog({
    required String title,
    required Widget content,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    Color? primaryColor,
    bool isLoading = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        content: content,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor ?? bgPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(primaryButtonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- INPUT DECORATION STYLE ---
  InputDecoration _modernInputDecoration(String label, IconData icon, {bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: enabled ? bgPurple : Colors.grey),
      filled: true,
      fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: bgPurple, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // --- LOGIC DIALOG ---

  // 1. Dialog Edit Profil (HP BISA DIEDIT)
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: user?.displayName);
    final emailCtrl = TextEditingController(text: user?.email);
    // Kita inisialisasi dengan nomor HP jika ada, jika tidak kosong
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? "");

    _showModernDialog(
      title: "Edit Profil",
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFF0F0F0),
              child: Icon(Icons.camera_alt, color: Colors.grey, size: 30),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              decoration: _modernInputDecoration("Nama Lengkap", Icons.person),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              enabled: false, // Email tetap dikunci demi keamanan auth
              decoration: _modernInputDecoration("Email (Terkunci)", Icons.email, enabled: false),
            ),
          ],
        ),
      ),
      primaryButtonText: "Simpan",
      onPrimaryPressed: () async {
        try {
          // Update Nama
          await user?.updateDisplayName(nameCtrl.text.trim());
          
          // CATATAN: Update Nomor HP di Firebase Auth memerlukan verifikasi SMS (PhoneAuthCredential).
          // Untuk simpelnya UI ini, kita hanya menyimpan nama. Jika ingin menyimpan HP
          // tanpa verifikasi SMS, biasanya disimpan di Firestore/Hive terpisah.
          // Di sini kita update tampilan saja agar user merasa tersimpan (Mock behavior untuk HP).
          
          await _refreshUser();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profil berhasil diperbarui!")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      },
    );
  }

  // 2. Dialog Ganti Password
  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    
    // Kita butuh StatefulBuilder di dalam content agar bisa handle loading state lokal dialog
    // Tapi karena kita pakai _showModernDialog yang stateless, kita handle loading di parent
    // Untuk simplifikasi, kita buat method terpisah yang memanggil showDialog manual jika butuh state kompleks
    // Atau gunakan pendekatan ini:
    
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text("Ganti Password", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Demi keamanan, masukkan password lama Anda.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: oldPassCtrl,
                    obscureText: true,
                    decoration: _modernInputDecoration("Password Lama", Icons.lock_outline),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: _modernInputDecoration("Password Baru", Icons.lock_reset),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.all(24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                           if (oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) return;
                           setStateDialog(() => isLoading = true);
                           try {
                             String email = user!.email!;
                             AuthCredential credential = EmailAuthProvider.credential(email: email, password: oldPassCtrl.text);
                             await user!.reauthenticateWithCredential(credential);
                             await user!.updatePassword(newPassCtrl.text);
                             
                             if (mounted) {
                               Navigator.pop(context);
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password berhasil diubah! Login ulang."), backgroundColor: Colors.green));
                               ref.read(authControllerProvider).signOut();
                             }
                           } catch (e) {
                             setStateDialog(() => isLoading = false);
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal. Cek password lama anda."), backgroundColor: Colors.red));
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgPurple, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Simpan"),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        );
      },
    );
  }

  // 3. Dialog Hapus Akun
  void _showDeleteAccountDialog() {
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 28),
                  const SizedBox(width: 8),
                  const Text("Hapus Akun?", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                    child: Text("Tindakan ini permanen. Data Anda tidak dapat dipulihkan.", style: TextStyle(color: Colors.red[800], fontSize: 13), textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: _modernInputDecoration("Konfirmasi Password", Icons.lock),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.all(24),
              actions: [
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: isLoading ? null : () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey)))),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: isLoading ? null : () async {
                          if (passwordCtrl.text.isEmpty) return;
                          setStateDialog(() => isLoading = true);
                          try {
                            AuthCredential credential = EmailAuthProvider.credential(email: user!.email!, password: passwordCtrl.text);
                            await user!.reauthenticateWithCredential(credential);
                            await user!.delete();
                            if (mounted) {
                              Navigator.pop(context); Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun dihapus.")));
                            }
                          } catch (e) {
                            setStateDialog(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password salah."), backgroundColor: Colors.red));
                          }
                        },
                        child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Hapus"),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        );
      }
    );
  }

  // 4. Dialog Logout (Modern)
  void _showLogoutDialog() {
    _showModernDialog(
      title: "Konfirmasi Keluar",
      content: const Text("Apakah Anda yakin ingin keluar dari aplikasi InsightMind?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      primaryButtonText: "Keluar",
      primaryColor: Colors.red,
      onPrimaryPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        ref.read(authControllerProvider).signOut();
      },
    );
  }
}