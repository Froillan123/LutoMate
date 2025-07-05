import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DishDetailsPage extends StatefulWidget {
  final String dish;
  final String token;
  const DishDetailsPage({super.key, required this.dish, required this.token});

  @override
  State<DishDetailsPage> createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage> {
  List<String> ingredients = [];
  List<String> steps = [];
  String? reference;
  String? dishImage;
  bool loading = true;
  String? error;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDetails();
    fetchDishImage();
  }

  Future<void> fetchDishImage() async {
    try {
      final imageUrl = await apiService.getOpenverseImage(widget.dish);
      if (imageUrl != null) {
        setState(() {
          dishImage = imageUrl;
        });
      }
    } catch (e) {
      print('Error fetching dish image: $e');
    }
  }

  Future<void> fetchDetails() async {
    setState(() { 
      loading = true; 
      error = null;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'recipe_${widget.dish}';
      
      // Check cache first
      if (prefs.containsKey(cacheKey)) {
        final cached = json.decode(prefs.getString(cacheKey)!);
        setState(() {
          ingredients = List<String>.from(cached['ingredients'] ?? []);
          steps = List<String>.from(cached['steps'] ?? []);
          reference = cached['reference'];
          loading = false;
        });
        return;
      }
      
      // Fetch from API if not cached
      final result = await apiService.getIngredients(widget.dish, widget.token);
      if (result['success'] ?? true) {
        final newIngredients = List<String>.from(result['ingredients'] ?? []);
        final newSteps = List<String>.from(result['steps'] ?? []);
        final newReference = result['reference'];
        
        setState(() {
          ingredients = newIngredients;
          steps = newSteps;
          reference = newReference;
        });
        
        // Save to local storage
        await prefs.setString(cacheKey, json.encode({
          'ingredients': newIngredients,
          'steps': newSteps,
          'reference': newReference,
        }));
      } else {
        setState(() { 
          error = result['message'] ?? 'Failed to fetch recipe details';
        });
      }
    } catch (e) {
      setState(() { 
        error = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() { loading = false; });
    }
  }

  Widget _buildIngredientCard(String ingredient) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD7BFA6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fastfood, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ingredient,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int idx, String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFFD7BFA6),
            child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(step, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
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
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish Image Header
                      if (dishImage != null)
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Image.network(
                              dishImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 60),
                              ),
                            ),
                          ),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 12),
                            ...ingredients.map(_buildIngredientCard),
                            const SizedBox(height: 28),
                            const Text('How to Cook:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 12),
                            ...steps.asMap().entries.map((e) => _buildStep(e.key, e.value)),
                            if (reference != null && reference!.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              const Text('Reference:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  try {
                                    // Check if it's already a valid URL
                                    String urlString = reference!;
                                    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
                                      // Try to make it a valid URL
                                      urlString = 'https://' + urlString;
                                    }
                                    final url = Uri.parse(urlString);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      // Show error if can't launch
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Cannot open link: $urlString')),
                                      );
                                    }
                                  } catch (e) {
                                    // Show error if URL is invalid
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invalid link: ${reference!}')),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.link, color: Color(0xFF1976D2), size: 16),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        reference!,
                                        style: const TextStyle(
                                          color: Color(0xFF1976D2),
                                          decoration: TextDecoration.underline,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
} 