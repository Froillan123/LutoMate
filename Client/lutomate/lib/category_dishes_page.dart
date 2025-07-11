import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dish_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryDishesPage extends StatefulWidget {
  final String category;
  final String token;
  const CategoryDishesPage({super.key, required this.category, required this.token});

  @override
  State<CategoryDishesPage> createState() => _CategoryDishesPageState();
}

class _CategoryDishesPageState extends State<CategoryDishesPage> {
  List<String> dishes = [];
  Map<String, String?> dishImages = {};
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
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'dishes_${widget.category}';

    // Check cache first
    if (prefs.containsKey(cacheKey)) {
      final cached = json.decode(prefs.getString(cacheKey)!);
      setState(() {
        dishes = List<String>.from(cached);
        loading = false;
      });
      fetchDishImages();
      return;
    }

    final result = await apiService.getDishes(widget.category, widget.token);
    if (result['success']) {
      setState(() {
        dishes = result['dishes'];
        loading = false;
      });
      // Save to cache
      await prefs.setString(cacheKey, json.encode(result['dishes']));
      // Fetch images for each dish (do not block UI)
      fetchDishImages();
    } else {
      setState(() { error = result['message']; loading = false; });
    }
  }

  Future<void> fetchDishImages() async {
    for (int i = 0; i < dishes.length; i++) {
      final dish = dishes[i];
      try {
        final imageUrl = await apiService.getOpenverseImage(dish);
        if (imageUrl != null) {
          setState(() {
            dishImages[dish] = imageUrl;
          });
        }
        // Add delay between requests to prevent buffer overflow
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('Error fetching image for $dish: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFFD7BFA6);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final cacheKey = 'dishes_${widget.category}';
              await prefs.remove(cacheKey);
              setState(() {
                dishes = [];
                dishImages.clear();
                loading = true;
                error = null;
              });
              await fetchDishes();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  cacheExtent: 500,
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    final imageUrl = dishImages[dish];

                    // Lazy load image if not already loaded
                    if (imageUrl == null && !dishImages.containsKey(dish)) {
                      apiService.getOpenverseImage(dish).then((url) {
                        if (url != null) {
                          setState(() {
                            dishImages[dish] = url;
                          });
                        } else {
                          setState(() {
                            dishImages[dish] = '';
                          });
                        }
                      });
                    }
                    
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DishDetailsPage(dish: dish, token: widget.token),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dish Image
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: imageUrl != null && imageUrl.isNotEmpty
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 40),
                                              ),
                                            ),
                                            // Gradient overlay for text visibility
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withOpacity(0.7),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 40),
                                        ),
                                ),
                              ),
                            ),
                            // Dish Name and View Recipe
                            Container(
                              // Give the lower section a background color and flexible height
                              decoration: BoxDecoration(
                                color: Color(0xFFD7BFA6), // main color for contrast
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              constraints: BoxConstraints(minHeight: 80), // Minimum height, can grow
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, // Let it grow as needed
                                children: [
                                  Text(
                                    dish,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.restaurant, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        'View Recipe',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 