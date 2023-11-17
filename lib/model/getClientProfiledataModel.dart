import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Replace these values with your actual endpoint and Bearer token
  final String apiUrl = 'https://workdonecorp.com/api/get_profile_info';
  Future<String?> _getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('your_bearer_token_key');
  }
  final String? bearerToken = await _getUserToken();

  // Create the headers with the Bearer token
  Map<String, String> headers = {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json', // You can add other headers as needed
  };

  // Make the HTTP request
  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    // Check the status code of the response
    if (response.statusCode == 200) {
      // Successful response
      print('Response: ${response.body}');
    } else {
      // Handle error response
      print('Error: ${response.statusCode}, ${response.reasonPhrase}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error: $error');
  }
}