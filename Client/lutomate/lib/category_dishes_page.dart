import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dish_details_page.dart';

class CategoryDishesPage extends StatefulWidget {
  final String category;
  final String token;
  const CategoryDishesPage({super.key, required this.category, required this.token});

  @override
  State<CategoryDishesPage> createState() => _CategoryDishesPageState();
}

class _CategoryDishesPageState extends State<CategoryDishesPage> {
  List<String> dishes = [];
  bool loading = true;
  String? error;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDishes();
  }

  Future<void> fetchDishes() async {
    setState(() { loading = true; });
    final result = await apiService.getDishes(widget.category, widget.token);
    if (result['success']) {
      setState(() {
        dishes = result['dishes'];
      });
      
      // Save search history
      try {
        await apiService.saveSearchHistory(widget.category, widget.token);
      } catch (e) {
        print('Error saving search history: $e');
      }
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
        title: Text(widget.category),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: dishes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    return ListTile(
                      title: Text(dish, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DishDetailsPage(dish: dish, token: widget.token),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 