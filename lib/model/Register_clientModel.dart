import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterClientApiClient {
  final String baseUrl = "https://workdonecorp.com";

  Future<Map<String, dynamic>> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String language,
    required String street1,
    required String street2,
    required String city,
    required String state,
    required String addressZip,
  }) async {
    final url = Uri.parse('$baseUrl/api/register_client');

    // Define the request body using form data
    final body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'language': language,
      'street1': street1,
      'street2': street2,
      'city': city,
      'state': state,
      'address_zip': addressZip,
    };

    try {
      final response = await http.post(
        url,
        body: body,
      );

      if (response.statusCode == 200) {
        // Decode the response body
        final responseBody = json.decode(response.body);

        // Extract the token from the response

        // Return the decoded response
        return responseBody;
      } else {
        // If the status code is not 200, throw an exception with the error message
        throw Exception('Failed to register worker. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // If an error occurs during the API call, throw an exception with the error message
      throw Exception('Error during registration: $error');
    }
  }
}
