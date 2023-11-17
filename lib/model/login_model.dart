import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final loginEndpoint = "/api/login";
    final loginUrl = Uri.parse('$baseUrl$loginEndpoint');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        loginUrl,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successful login, parse the response
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        // Login failed, handle the error
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      throw Exception('Failed to connect: $error');
    }
  }
}


