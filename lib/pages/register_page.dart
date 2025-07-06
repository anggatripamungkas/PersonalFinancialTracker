import 'package:flutter/material.dart';
import 'login_page.dart'; // Mengimpor LoginPage untuk navigasi setelah registrasi
import '../services/api_service.dart'; // Mengimpor ApiService untuk request API

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController(); // Field email
  final _firstNameController = TextEditingController(); // Field nama depan
  final _lastNameController = TextEditingController(); // Field nama belakang
  final _phoneController = TextEditingController(); // Field telepon
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Fungsi untuk toggle visibilitas password
  void _togglePasswordView() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Fungsi untuk toggle visibilitas confirm password
  void _toggleConfirmPasswordView() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  // Validasi Email dengan format tertentu (harus berakhiran @gmail.com)
  bool _isEmailValid(String email) {
    return email.contains('@gmail.com');
  }

  Future<void> _register() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final email = _emailController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final phone = _phoneController.text;

    // Validasi input form
    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Harap isi semua kolom');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Password tidak cocok');
      return;
    }

    if (!_isEmailValid(email)) {
      _showErrorDialog('Email harus berakhiran @gmail.com');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kirim request API untuk registrasi
      final registerResponse = await ApiService.postRequest(
        'auth/register/', // Endpoint untuk registrasi
        {
          'username': username,
          'password': password,
          'password2': confirmPassword,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'token_registrasi': 'bk-token-reg', // Token registrasi yang sudah ditentukan
        },
      );

      debugPrint("Register Response: $registerResponse"); // Log untuk melihat respons API

      // Menangani respons sukses
      if (registerResponse['message'] == 'Registrasi berhasil! Selamat datang di Journal Invest.') {
        // Jika registrasi sukses, arahkan ke LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else if (registerResponse.containsKey('message')) {
        // Jika ada pesan kesalahan dari server
        _showErrorDialog('Registrasi gagal: ${registerResponse['message']}');
      }
    } catch (e) {
      // Tangkap error dari API atau dari koneksi internet
      debugPrint("Error during registration: $e"); // Log error ke debug console
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Arahkan kembali ke halaman LoginPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        title: const Text('Register'),
      ),
      body: Center( // Pusatkan semua konten
        child: SingleChildScrollView( // Menghindari overflow saat keyboard muncul
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Teks judul
              const Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50), // Jarak antara teks judul dan input

              // Username Input dengan ikon
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input dengan toggle visibilitas
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue,
                    ),
                    onPressed: _togglePasswordView,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password Input dengan toggle visibilitas
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue,
                    ),
                    onPressed: _toggleConfirmPasswordView,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email Input dengan ikon
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // First Name Input
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Last Name Input
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Input
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: const TextStyle(color: Colors.blue),
                  prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Register Button dengan lebar lebih besar
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity, // Membuat tombol lebih lebar
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
