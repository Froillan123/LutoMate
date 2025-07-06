import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  Map<int, String?> stepImages = {}; // step index to image url

  @override
  void initState() {
    super.initState();
    fetchDetails();
    fetchDishImage();
    // Step images will be fetched after steps are loaded
  }

  Future<void> fetchStepImages() async {
    for (int i = 0; i < steps.length; i++) {
      final stepText = steps[i];
      if (stepText.trim().isEmpty) continue;
      try {
        final imageUrl = await apiService.getOpenverseImage(stepText);
        if (imageUrl != null) {
          setState(() {
            stepImages[i] = imageUrl;
          });
        } else {
          setState(() {
            stepImages[i] = '';
          });
        }
        await Future.delayed(const Duration(milliseconds: 150));
      } catch (e) {
        setState(() { stepImages[i] = ''; });
      }
    }
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
        fetchStepImages();
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
        fetchStepImages();
        
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
    final imageUrl = stepImages[idx];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl == null)
            Container(
              width: double.infinity,
              height: 120,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  height: 120,
                  child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 40),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              color: Colors.grey[300],
              child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6), size: 40),
            ),
          const SizedBox(height: 8),
          Row(
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
                            const Text('How to Cook:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 12),
                            ...steps.asMap().entries.map((e) => _buildStep(e.key, e.value)),
                            const SizedBox(height: 28),
                            const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 12),
                            ...ingredients.map(_buildIngredientCard),
                            if (reference != null && reference!.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              const Text('Reference:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 8),
                              _buildReferenceWidget(reference!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReferenceWidget(String reference) {
    final trimmed = reference.trim();
    final isUrl = trimmed.startsWith('http://') || trimmed.startsWith('https://');
    if (isUrl) {
      return Row(
        children: [
          Icon(Icons.link, color: Color(0xFF1976D2), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              trimmed,
              style: const TextStyle(
                color: Color(0xFF1976D2),
                decoration: TextDecoration.underline,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Color(0xFF8D6E63)),
            tooltip: 'Copy to clipboard',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: trimmed));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard!')),
                );
              }
            },
          ),
        ],
      );
    } else {
      return Text(
        trimmed,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      );
    }
  }
} 