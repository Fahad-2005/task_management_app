import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_management_app/models/user_profile.dart';

class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<UserProfile> fetchUserProfile() async {
    try {
      // Fetch a mock user payload from JSONPlaceholder matching requirements
      final response = await http.get(Uri.parse('$_baseUrl/users/1'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Server returned code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to network service: $e');
    }
  }
}