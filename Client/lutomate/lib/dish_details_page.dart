import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class DishDetailsPage extends StatefulWidget {
  final String dish;
  final String token;
  const DishDetailsPage({super.key, required this.dish, required this.token});

  @override
  State<DishDetailsPage> createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage> {
  List<Map<String, dynamic>> ingredients = [];
  List<String> steps = [];
  String? reference;
  bool loading = true;
  String? error;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    setState(() { loading = true; });
    final result = await apiService.getIngredients(widget.dish, widget.token);
    if (result['success'] ?? true) {
      final rawIngredients = result['ingredients'] ?? [];
      ingredients = rawIngredients.map<Map<String, dynamic>>((ing) {
        if (ing is Map<String, dynamic>) return ing;
        return {'name': ing.toString(), 'image': null};
      }).toList();
      setState(() {
        steps = List<String>.from(result['steps'] ?? []);
        reference = result['reference'];
      });
    } else {
      setState(() { error = result['message']; });
    }
    setState(() { loading = false; });
  }

  Widget _buildIngredientCard(Map<String, dynamic> ingredient) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: ingredient['image'] != null
                ? Image.network(
                    ingredient['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6)),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood, color: Color(0xFFD7BFA6)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
              child: Text(
                ingredient['name'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
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
                            final url = Uri.parse(reference!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
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
                    ],
                  ),
                ),
    );
  }
} 