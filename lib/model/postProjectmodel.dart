import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PostProjectApi {
  static const String baseUrl = 'https://workdonecorp.com/api';


  static Future<void>  PostnewProject({
    required String token,
    required String project_type_id,
    required String title,
    required String desc,
    required String timeframe_start,
    required String timeframe_end,
    required String primary_image,
  }) async {
    final String url = '$baseUrl/insert_project';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    final Map<String, String> body = {
      'project_type_id': project_type_id,
      'title': title,
      'desc': desc,
      'timeframe_start': timeframe_start,
      'timeframe_end': timeframe_end,
    };
    final Map<String, String> files = {
      'primary_image': primary_image,
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

        return json.decode(response.body);
      } else {
        throw Exception('Failed to Post a Project. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error during Post a Project: $error');
    }
  }
}
