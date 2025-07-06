import 'package:flutter/material.dart';
import 'api_service.dart';

const List<String> foodOptions = [
  'Chicken', 'Beef', 'Pork', 'Fish', 'Seafood', 'Vegetarian', 'Vegan', 'Rice', 'Noodles',
  'Soup', 'Salad', 'Egg', 'Bread', 'Snacks', 'Dessert', 'BBQ', 'Grilled', 'Fried',
  'Pasta', 'Pizza', 'Burger', 'Sandwich', 'Sushi', 'Dimsum', 'Adobo', 'Sinigang',
  'Kare-Kare', 'Lechon', 'Sisig', 'Pancit', 'Lumpia', 'Halo-Halo', 'Turon', 'Bibingka',
  'Ice Cream', 'Cake', 'Fruit', 'Coffee', 'Tea', 'Juice', 'Other',
];

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  Set<String> _selectedPreferences = {};
  bool _loading = false;
  bool _obscurePassword = true;
  int _step = 1;
  int _foodPage = 0;
  static const int _pageSize = 12;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _step++;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green[600],
          size: 48,
        ),
        title: const Text(
          'Registration Successful!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8D6E63),
          ),
        ),
        content: const Text(
          'You have successfully registered your account.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to login
            },
            child: const Text(
              'Go to Login',
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
          'Registration Failed',
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

  Future<void> _register() async {
    setState(() {
      _loading = true;
    });
    final api = ApiService();
    final result = await api.register(
      _firstName,
      _lastName,
      _email,
      _password,
      _selectedPreferences.toList(),
    );
    setState(() {
      _loading = false;
    });
    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result['message'] ?? 'Registration failed');
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text('Next'),
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
              onPressed: _nextStep,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Color(0xFFD7BFA6),
                  thickness: 1,
                  endIndent: 10,
                ),
              ),
              const Text(
                '-or-',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              Expanded(
                child: Divider(
                  color: Color(0xFFD7BFA6),
                  thickness: 1,
                  indent: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD7BFA6), width: 1.5),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () {
                // TODO: Implement Google Sign Up
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/google.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign up with Google',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.login, color: Color(0xFF8D6E63)),
            label: const Text('Already have an account? Login'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey,
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
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'First Name',
              prefixIcon: Icon(Icons.person, color: Color(0xFF8D6E63)),
              filled: true,
              fillColor: Color(0xFFF8F5F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (v) => _firstName = v,
            validator: (v) => v == null || v.isEmpty ? 'Enter first name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Last Name',
              prefixIcon: Icon(Icons.person, color: Color(0xFF8D6E63)),
              filled: true,
              fillColor: Color(0xFFF8F5F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (v) => _lastName = v,
            validator: (v) => v == null || v.isEmpty ? 'Enter last name' : null,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text('Next'),
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
              onPressed: _nextStep,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6E63)),
            label: const Text('Back'),
            onPressed: () {
              setState(() {
                _step = 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final start = _foodPage * _pageSize;
    final end = ((_foodPage + 1) * _pageSize).clamp(0, foodOptions.length);
    final pageOptions = foodOptions.sublist(start, end);
    final totalPages = (foodOptions.length / _pageSize).ceil();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const Text(
          'What foods do you like?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF795548)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pageOptions.map((food) {
            final selected = _selectedPreferences.contains(food);
            return FilterChip(
              label: Text(food),
              selected: selected,
              selectedColor: Color(0xFFD7BFA6),
              checkmarkColor: Color(0xFF8D6E63),
              backgroundColor: Color(0xFFF8F5F2),
              labelStyle: TextStyle(
                color: selected ? Color(0xFF8D6E63) : Color(0xFFBCA18C),
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    if (_selectedPreferences.length < 5) {
                      _selectedPreferences.add(food);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You can select up to 5 preferences only.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    _selectedPreferences.remove(food);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_foodPage > 0)
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6E63)),
                label: const Text('Prev'),
                onPressed: () {
                  setState(() {
                    _foodPage--;
                  });
                },
              ),
            Text('Page ${_foodPage + 1} of $totalPages', style: const TextStyle(color: Color(0xFF8D6E63))),
            if (end < foodOptions.length)
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF8D6E63)),
                label: const Text('Next'),
                onPressed: () {
                  setState(() {
                    _foodPage++;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Register'),
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
            onPressed: _selectedPreferences.isEmpty || _loading ? null : _register,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8D6E63)),
          label: const Text('Back'),
          onPressed: () {
            setState(() {
              _step = 2;
            });
          },
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.login, color: Color(0xFF8D6E63)),
          label: const Text('Already have an account? Login'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(320.0, 440.0);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: width,
              maxWidth: width,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _step == 1
                    ? _buildStep1()
                    : _step == 2
                        ? _buildStep2()
                        : _buildStep3(),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 