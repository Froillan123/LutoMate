import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dish_details_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagePage extends StatefulWidget {
  final String token;
  final String userInput;
  final List<Map<String, dynamic>> suggestions;
  
  const MessagePage({
    super.key, 
    required this.token, 
    required this.userInput, 
    required this.suggestions
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Map<String, String?> dishImages = {};
  final String defaultFoodImage = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80'; // fallback image
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDishImages();
  }

  Future<void> fetchDishImages() async {
    for (int i = 0; i < widget.suggestions.length; i++) {
      final suggestion = widget.suggestions[i];
      final dishName = suggestion['name'];
      if (dishName != null) {
        try {
          final imageUrl = await apiService.getOpenverseImage(dishName);
          if (imageUrl != null) {
            setState(() {
              dishImages[dishName] = imageUrl;
            });
          }
          // Add delay between requests to prevent buffer overflow
          await Future.delayed(const Duration(milliseconds: 150));
        } catch (e) {
          print('Error fetching image for $dishName: $e');
        }
      }
    }
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final dishName = suggestion['name'] ?? '';
    final imageUrl = dishImages[dishName];
    final reference = suggestion['reference'] ?? suggestion['link'] ?? '';
    String? validReference;
    if (reference is String && reference.isNotEmpty) {
      validReference = reference.trim();
      if (!validReference.startsWith('http://') && !validReference.startsWith('https://')) {
        validReference = 'https://' + validReference;
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dish Image
          Container(
            width: double.infinity,
            height: 200,
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
              child: imageUrl == null
                  ? Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : (imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.network(
                            defaultFoodImage,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.network(
                          defaultFoodImage,
                          fit: BoxFit.cover,
                        )),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish Name
                Text(
                  dishName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 20, 
                    color: Color(0xFF8D6E63)
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description
                if (suggestion['description'] != null && suggestion['description'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      suggestion['description'],
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                
                // Ingredients
                if (suggestion['ingredients'] != null && suggestion['ingredients'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        children: [
                          const TextSpan(text: 'Ingredients: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: suggestion['ingredients']),
                        ],
                      ),
                    ),
                  ),
                
                // Time and Difficulty
                Row(
                  children: [
                    if (suggestion['time'] != null && suggestion['time'].toString().isNotEmpty)
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                            children: [
                              const TextSpan(text: '⏱️ Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: suggestion['time']),
                            ],
                          ),
                        ),
                      ),
                    if (suggestion['difficulty'] != null && suggestion['difficulty'].toString().isNotEmpty)
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                            children: [
                              const TextSpan(text: '📊 Difficulty: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: suggestion['difficulty']),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Cooking Instructions
                if (suggestion['instructions'] != null && suggestion['instructions'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Cooking Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8D6E63)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    suggestion['instructions'],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Reference Link
                if (validReference != null && validReference.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        final url = Uri.parse(validReference!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cannot open link: $validReference')),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: Color(0xFF1976D2), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              validReference!,
                              style: const TextStyle(
                                color: Color(0xFF1976D2),
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Get Full Recipe Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DishDetailsPage(
                            dish: dishName,
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                    label: const Text('Get Full Recipe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7BFA6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI Suggestions'),
        backgroundColor: const Color(0xFFD7BFA6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // User Input Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8F5F2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Request:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8D6E63)),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.userInput,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          
          // AI Suggestions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.suggestions.length,
              itemBuilder: (context, index) => _buildSuggestionCard(widget.suggestions[index]),
            ),
          ),
        ],
      ),
    );
  }
} 