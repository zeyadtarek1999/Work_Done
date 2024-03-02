import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterClientApiClient {
  final String baseUrl;

  RegisterClientApiClient({required this.baseUrl});

  Future<Map<String, dynamic>> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    List<int>? languageIds,
    required String street1,
    required String street2,
    required String city,
    required String state,
    required String addressZip,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/register_client');

      final request = http.MultipartRequest('POST', url)
        ..fields.addAll({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'street1': street1,
          'street2': street2,
          'city': city,
          'state': state,
          'address_zip': addressZip,
        });

      // Explicitly set the 'Content-Type' header
      request.headers['Content-Type'] = 'multipart/form-data';

      if (languageIds != null) {
        for (var i = 0; i < languageIds.length; i++) {
          request.fields['language[$i]'] = languageIds[i].toString();
        }
      }
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Decode the response body
        final responseBody = json.decode(response.body);

        // Extract the token from the response

        // Return the decoded response
        return responseBody;
      } else {
        // If the status code is not 200, throw an exception with the error message
        throw Exception('Failed to register Client. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // If an error occurs during the API call, throw an exception with the error message
      throw Exception('Error during registration: $error');
    }
  }
}
