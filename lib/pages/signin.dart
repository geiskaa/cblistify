import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    final namaLengkap = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (namaLengkap.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi dan konfirmasi tidak cocok')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 6 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': namaLengkap},
      );

      final user = response.user;

      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': namaLengkap,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil!')),
        );

        Navigator.pop(context); // kembali ke login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran gagal.')),
        );
      }
    } catch (error) {
      String errorMsg = 'Pendaftaran gagal.';
      if (error.toString().contains('user already registered')) {
        errorMsg = 'Email sudah terdaftar.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color focusColor = Color(0xFF673AB7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Daftar Akun Baru",
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/listifylogo.png', height: 100),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Buat Akun Barumu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Hanya butuh beberapa langkah untuk memulai.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              const Text("Nama Lengkap", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _namaController,
                cursorColor: focusColor,
                decoration: _buildInputDecoration(
                  hintText: 'Masukkan nama lengkap Kamu',
                  theme: theme,
                  focusColor: focusColor,
                ),
              ),
              const SizedBox(height: 20),

              const Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: focusColor,
                decoration: _buildInputDecoration(
                  hintText: 'Masukkan email Kamu',
                  theme: theme,
                  focusColor: focusColor,
                ),
              ),
              const SizedBox(height: 20),

              const Text("Kata Sandi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                cursorColor: focusColor,
                decoration: _buildInputDecoration(
                  hintText: 'Buat kata sandi Kamu',
                  theme: theme,
                  focusColor: focusColor,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Konfirmasi Kata Sandi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                cursorColor: focusColor,
                decoration: _buildInputDecoration(
                  hintText: 'Ulangi kata sandi Kamu',
                  theme: theme,
                  focusColor: focusColor,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6572),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Masuk di sini',
                        style: const TextStyle(
                          color: Color(0xFF3498db),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required ThemeData theme,
    required Color focusColor,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: theme.canvasColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: focusColor, width: 2.0),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
    );
  }
}
