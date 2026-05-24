// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey   = GlobalKey<FormState>();
  final _resetFormKey   = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _tokenCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  bool _loading         = false;
  bool _sent            = false;
  bool _obscurePass     = true;
  bool _obscureConfirm  = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // Step 1 — kirim email
  Future<void> _sendEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final res = await ApiService.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] == true) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  // Step 2 — reset password dengan token
  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final res = await ApiService.resetPassword(
      _emailCtrl.text.trim(),
      _tokenCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil direset! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildResetForm() : _buildEmailForm(),
      ),
    );
  }

  // ── Step 1: Form Email ───────────────────────
  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.lock_reset, size: 56, color: Color(0xFF6C63FF)),
          const SizedBox(height: 20),
          const Text('Lupa Password?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Masukkan email Anda. Kami akan kirimkan kode reset password.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) =>
                v == null || !v.contains('@') ? 'Email tidak valid' : null,
          ),
          const SizedBox(height: 24),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _sendEmail,
                  child: const Text('Kirim Kode Reset'),
                ),
        ],
      ),
    );
  }

  // ── Step 2: Form Token + Password Baru ───────
  Widget _buildResetForm() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.mark_email_read_outlined, size: 56, color: Color(0xFF6C63FF)),
          const SizedBox(height: 20),
          const Text('Cek Email Anda',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Kode reset telah dikirim ke ${_emailCtrl.text}.\nSalin kode dari email dan masukkan di bawah.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Input token
          TextFormField(
            controller: _tokenCtrl,
            decoration: const InputDecoration(
              labelText: 'Kode Reset',
              prefixIcon: Icon(Icons.vpn_key_outlined),
              hintText: 'Salin kode dari email',
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Kode reset wajib diisi' : null,
          ),
          const SizedBox(height: 16),

          // Password baru
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
          ),
          const SizedBox(height: 16),

          // Konfirmasi password
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) =>
                v != _passCtrl.text ? 'Password tidak cocok' : null,
          ),
          const SizedBox(height: 24),

          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Reset Password'),
                ),
          const SizedBox(height: 12),

          // Kirim ulang
          Center(
            child: TextButton(
              onPressed: _loading ? null : () => setState(() => _sent = false),
              child: const Text('Kirim ulang kode'),
            ),
          ),
        ],
      ),
    );
  }
}