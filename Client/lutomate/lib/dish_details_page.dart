import 'package:flutter/material.dart';
import 'api_service.dart';

class DishDetailsPage extends StatefulWidget {
  final String dish;
  final String token;
  const DishDetailsPage({super.key, required this.dish, required this.token});

  @override
  State<DishDetailsPage> createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage> {
  List<String> ingredients = [];
  bool loading = true;
  String? error;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    setState(() { loading = true; });
    final result = await apiService.getIngredients(widget.dish, widget.token);
    if (result['success']) {
      setState(() {
        ingredients = result['ingredients'];
      });
    } else {
      setState(() { error = result['message']; });
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFFD7BFA6);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      ...ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Color(0xFFD7BFA6)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ing, style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
    );
  }
} 