import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://lutomate.onrender.com/api/lutome';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'token': data['access_token']};
      } else {
        return {'success': false, 'message': 'Invalid username or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error connecting to server'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, List<String> preferences) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
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
} 