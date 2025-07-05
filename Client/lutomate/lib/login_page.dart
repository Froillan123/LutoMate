import 'package:flutter/material.dart';
import 'api_service.dart';
import 'overview_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  bool _obscurePassword = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange[600],
          size: 48,
        ),
        title: const Text(
          'Login Failed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8D6E63),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFD7BFA6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });
    final api = ApiService();
    final result = await api.login(_email, _password);
    if (result['success']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OverviewPage(token: result['token'])),
      );
    } else {
      _showErrorDialog(result['message'] ?? 'Login failed');
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(320.0, 440.0);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFD7BFA6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width,
              maxWidth: width,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E9E1),
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/cooking_icon.png', width: 70, height: 70),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(Icons.restaurant_menu, color: Color(0xFFD7BFA6), size: 24),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Icon(Icons.emoji_food_beverage, color: Color(0xFFD7BFA6), size: 20),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'LutoMate',
                            style: TextStyle(
                              color: Color(0xFF8D6E63),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Color(0xFF8D6E63)),
                            filled: true,
                            fillColor: Color(0xFFF8F5F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onChanged: (v) => _email = v,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter email';
                            }
                            if (!_isValidEmail(v)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Color(0xFF8D6E63)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF8D6E63),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Color(0xFFF8F5F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          onChanged: (v) => _password = v,
                          validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 24),
                        _loading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8D6E63)))
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.login, color: Colors.white),
                                  label: const Text('Login'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFD7BFA6),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18)),
                                    ),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                                ),
                              ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          icon: const Icon(Icons.person_add, color: Color(0xFF8D6E63)),
                          label: const Text('Create an account'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 