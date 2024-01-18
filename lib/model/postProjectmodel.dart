import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PostProjectApi {
  static Future<void> postNewProject({
    required String token,
    required String projectTypeId,
    required String title,
    required String description,
    required String timeframeStart,
    required String timeframeEnd,
    required List<String> imagesPaths,
    required List<String> videosPaths, // Add this parameter to take video paths
  }) async {
    final String url = 'https://www.workdonecorp.com/api/insert_project';
    final Uri uri = Uri.parse(url);

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {
      'project_type_id': projectTypeId,
      'title': title,
      'desc': description,
      'timeframe_start': timeframeStart,
      'timeframe_end': timeframeEnd,
    };

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields.addAll(body);

    // Add images to the request
    for (var imagePath in imagesPaths) {
      request.files.add(await http.MultipartFile.fromPath('images[]', imagePath));
    }
     for (var videoPath in videosPaths) {
      request.files.add(await http.MultipartFile.fromPath('video', videoPath));
    }

    // Add videos to the request
    // for (var videoPath in videosPaths) {
    //   request.files.add(await http.MultipartFile.fromPath('videos[]', videoPath));
    // }

    try {
      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post a project. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error during post a project: $error');
    }
  }
}