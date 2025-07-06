import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage for navigation after login
import 'register_page.dart';
import '../services/api_service.dart'; // Import ApiService for API call
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // To toggle password visibility

  // Toggle password visibility
  void _togglePasswordView() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Login function
  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Username atau Password tidak boleh kosong!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API to login
      final loginResponse = await ApiService.postRequest(
        'auth/login/', // The login endpoint
        {
          'username': username,
          'password': password,
        },
      );

      print('Login Response: $loginResponse'); // Log the full response

      // Assuming the login response returns tokens in the 'tokens' field
      if (loginResponse.containsKey('tokens') && loginResponse['tokens'].containsKey('access')) {
        final accessToken = loginResponse['tokens']['access'];
        final username = loginResponse['user']['full_name']; // Ambil nama lengkap dari respons

        // Simpan token dan nama pengguna ke secure storage
        await FlutterSecureStorage().write(key: 'access_token', value: accessToken);
        await FlutterSecureStorage().write(key: 'username', value: username); // Simpan nama pengguna

        // Verifikasi apakah token disimpan dengan benar
        String? savedToken = await FlutterSecureStorage().read(key: 'access_token');
        print('Saved Token: $savedToken'); // Log saved token

        // Navigasi ke HomePage setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showErrorDialog('Login gagal: Token tidak ditemukan');
      }

    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Error dialog to show when login fails
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
      body: Center( // Centering all the content
        child: SingleChildScrollView( // Prevent overflow when keyboard appears
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Text
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50), // Space between welcome text and fields

              // Username Input with icon
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

              // Password Input with visibility toggle
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
              const SizedBox(height: 24),

              // Row with Sign Up and Sign In buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the Row
                children: [
                  // Sign Up Button (Left)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to RegisterPage if you have one
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between buttons
                  // Sign In Button (Right)
                  Expanded(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
