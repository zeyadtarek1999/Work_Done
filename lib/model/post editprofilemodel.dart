import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateClientProfileApi {
  static const String baseUrl = 'https://workdonecorp.com/api';

  static Future<void> updateClientProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
    required String profile_pic,
    required String language,
  }) async {
    final String url = 'https://workdonecorp.com/api/update_client_profile';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {
      'firstname': firstName,
      'lastname': lastName,
      'phone': phone,
      'language': language,
    };

    final Map<String, String> files = {
      'image': profile_pic,
    };

    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields.addAll(body);

    for (String key in files.keys) {
      http.MultipartFile file = await http.MultipartFile.fromPath(key, files[key]!);
      request.files.add(file);
    }

    try {
      final http.Response response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Request successful
        print('Client profile updated successfully');
      } else {
        // Request failed
        print('Failed to update client profile. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error updating client profile: $error');
    }
  }
}
