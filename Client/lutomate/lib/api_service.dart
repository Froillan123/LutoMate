import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  String get baseUrl => const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://lutomate.onrender.com');

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/lutome/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'token': data['access_token']};
      } else {
        return {'success': false, 'message': 'Incorrect email or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error connecting to server'};
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password, List<String> preferences) async {
    final url = Uri.parse('$baseUrl/api/lutome/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'preferences': preferences,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        String message = 'Registration failed';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            message = data['detail'].toString();
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error connecting to server'};
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/lutome/me');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'first_name': data['first_name'],
          'last_name': data['last_name'],
          'preferences': List<String>.from(data['preferences'] ?? []),
        };
      } else {
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get AI dishes for category
  Future<Map<String, dynamic>> getDishes(String category, String token) async {
    final url = Uri.parse('$baseUrl/api/lutome/recipes/ai_dishes?category=${Uri.encodeComponent(category)}');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'dishes': List<String>.from(data['dishes'] ?? []),
        };
      } else {
        return {'success': false, 'message': 'Failed to load dishes'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get AI ingredients for dish
  Future<Map<String, dynamic>> getIngredients(String dish, String token) async {
    final url = Uri.parse('$baseUrl/api/lutome/recipes/ai_ingredients?dish=${Uri.encodeComponent(dish)}');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Defensive: always return a list of strings for ingredients
        final rawIngredients = data['ingredients'] ?? [];
        final ingredients = rawIngredients.map((ing) {
          if (ing is String) return ing;
          if (ing is Map<String, dynamic>) return ing['name'] ?? ing.toString();
          return ing.toString();
        }).toList();
        return {
          'success': true,
          'ingredients': ingredients,
          'steps': List<String>.from(data['steps'] ?? []),
          'reference': data['reference'],
        };
      } else {
        return {'success': false, 'message': 'Failed to load ingredients'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get Openverse image (free alternative to Unsplash)
  Future<String?> getOpenverseImage(String query) async {
    final queries = [
      '[32m$query food[0m',
      '[32m$query recipe[0m',
      '[32m$query dish[0m',
      query,
    ];
    for (final q in queries) {
      final url = Uri.parse(
        'https://api.openverse.engineering/v1/images/?q=${Uri.encodeComponent(q)}&page_size=1&filter=license_type:commercial',
      );
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            return data['results'][0]['url'];
          }
        }
      } catch (_) {}
    }
    return null;
  }

  // AI Conversation
  Future<Map<String, dynamic>> aiConversation(String userInput, String token) async {
    final url = Uri.parse('$baseUrl/api/lutome/recipes/ai_conversation');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_input': userInput}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'user_input': data['user_input'],
          'suggestions': List<Map<String, dynamic>>.from(data['suggestions'] ?? []),
          'ai_response': data['ai_response'],
        };
      } else {
        return {'success': false, 'message': 'Failed to get AI suggestions'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
} 