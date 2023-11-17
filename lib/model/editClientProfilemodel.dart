import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UpdateClientProfileApiClient {
  final String baseUrl;
  final String authToken;

  UpdateClientProfileApiClient({required this.baseUrl, required this.authToken});

  Future<Map<String, dynamic>> updateClientProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required File image,
    required String language,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/update_client_profile');

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': 'Bearer $authToken'})
        ..fields.addAll({
          'firstname': firstName,
          'lastname': lastName,
          'phone': phone,
          'language': language,
        })
        ..files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update client profile');
      }
    } catch (error) {
      throw error;
    }
  }
}
