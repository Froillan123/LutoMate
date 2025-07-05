import 'package:flutter/material.dart';
import 'api_service.dart';

const List<String> foodOptions = [
  'Chicken', 'Spicy', 'Seafood', 'Fried', 'Vegetarian', 'Beef', 'Pasta', 'Soup', 'Rice', 'Dessert', 'Vegan', 'Pork', 'Fish', 'Salad', 'Noodles', 'Grilled', 'Steamed', 'Egg', 'Bread', 'Fruit', 'Snacks', 'Healthy', 'Sweet', 'Sour', 'Savory', 'BBQ', 'Soup', 'Stew', 'Tofu', 'Dairy', 'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Asian', 'Western', 'Filipino', 'Italian', 'Mexican', 'Indian', 'Korean', 'Japanese', 'Chinese', 'American', 'Mediterranean', 'Street Food', 'Fast Food', 'Home Cooked', 'Exotic', 'Comfort Food', 'Finger Food', 'Appetizer', 'Main Dish', 'Side Dish', 'Drink', 'Smoothie', 'Juice', 'Coffee', 'Tea', 'Chocolate', 'Ice Cream', 'Cake', 'Pie', 'Cookies', 'Pastry', 'Sandwich', 'Burger', 'Pizza', 'Sushi', 'Dimsum', 'Curry', 'Adobo', 'Sinangag', 'Chicharon', 'Bangus', 'Lechon', 'Sisig', 'Kare-Kare', 'Laing', 'Bicol Express', 'Pancit', 'Lumpia', 'Halo-Halo', 'Turon', 'Bibingka', 'Puto', 'Kutsinta', 'Taho', 'Sinigang', 'Tinola', 'Menudo', 'Afritada', 'Caldereta', 'Dinuguan', 'Pakbet', 'Pinakbet', 'Ginataan', 'Ginisang', 'Inihaw', 'Nilaga', 'Paksiw', 'Pares', 'Tapsilog', 'Tocino', 'Longganisa', 'Bopis', 'Bulalo', 'Batchoy', 'Mami', 'Goto', 'Arroz Caldo', 'Champorado', 'Lomi', 'Maja Blanca', 'Sapin-Sapin', 'Ube', 'Macapuno', 'Langka', 'Mango', 'Banana', 'Pineapple', 'Watermelon', 'Melon', 'Avocado', 'Papaya', 'Guava', 'Lanzones', 'Rambutan', 'Durian', 'Mangosteen', 'Santol', 'Star Apple', 'Tamarind', 'Coconut', 'Jackfruit', 'Lychee', 'Pomelo', 'Sugarcane', 'Corn', 'Cassava', 'Sweet Potato', 'Taro', 'Yam', 'Squash', 'Pumpkin', 'Carrot', 'Potato', 'Tomato', 'Onion', 'Garlic', 'Ginger', 'Pepper', 'Chili', 'Okra', 'Eggplant', 'Ampalaya', 'Malunggay', 'Kangkong', 'Spinach', 'Lettuce', 'Cabbage', 'Broccoli', 'Cauliflower', 'Beans', 'Peas', 'Mushroom', 'Bell Pepper', 'Celery', 'Radish', 'Turnip', 'Zucchini', 'Cucumber', 'Apple', 'Orange', 'Grapes', 'Strawberry', 'Blueberry', 'Raspberry', 'Blackberry', 'Cherry', 'Peach', 'Plum', 'Pear', 'Apricot', 'Kiwi', 'Lemon', 'Lime', 'Grapefruit', 'Pomegranate', 'Fig', 'Date', 'Persimmon', 'Quince', 'Cranberry', 'Gooseberry', 'Mulberry', 'Boysenberry', 'Elderberry', 'Currant', 'Soursop', 'Sapote', 'Tamarillo', 'Dragonfruit', 'Passionfruit', 'Mangosteen', 'Salak', 'Longan', 'Jujube', 'Medlar', 'Miracle Fruit', 'Noni', 'Rose Apple', 'Sweetsop', 'Breadfruit', 'Chempedak', 'Duku', 'Langsat', 'Marang', 'Pulasan', 'Santol', 'Sugar Apple', 'Tamarind', 'Velvet Apple', 'Wampi', 'Yantok', 'Ziziphus', 'Other'
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
  String? _error;
  int _step = 1;
  int _foodPage = 0;
  static const int _pageSize = 12;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _step = 2;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful!'),
        content: const Text('You have successfully registered your account.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to login
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
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
      setState(() {
        _error = result['message'] ?? 'Registration failed';
      });
    }
  }

  Widget _buildStep1() {
    return Column(
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
              const SizedBox(height: 16),
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
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF8D6E63)),
                  filled: true,
                  fillColor: Color(0xFFF8F5F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                obscureText: true,
                onChanged: (v) => _password = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final start = _foodPage * _pageSize;
    final end = ((_foodPage + 1) * _pageSize).clamp(0, foodOptions.length);
    final pageOptions = foodOptions.sublist(start, end);
    final totalPages = (foodOptions.length / _pageSize).ceil();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    _selectedPreferences.add(food);
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
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
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
              _step = 1;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(320.0, 440.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFFD7BFA6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                child: _step == 1 ? _buildStep1() : _buildStep2(),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 