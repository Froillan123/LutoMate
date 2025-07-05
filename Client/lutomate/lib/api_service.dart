import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://lutomate.onrender.com';
  String get unsplashApiKey => dotenv.env['UNSPLASH_API_KEY'] ?? '';

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
        return {
          'success': true,
          'ingredients': List<String>.from(data['ingredients'] ?? []),
        };
      } else {
        return {'success': false, 'message': 'Failed to load ingredients'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get Unsplash image
  Future<String?> getUnsplashImage(String query) async {
    if (unsplashApiKey.isEmpty) return null;
    final url = Uri.parse(
      'https://api.unsplash.com/search/photos?query=${Uri.encodeComponent(query)}&client_id=$unsplashApiKey&per_page=1',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['urls']['regular'];
        }
      }
    } catch (_) {}
    return null;
  }
} 