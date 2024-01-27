import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PostProjectApi {
  static Future<http.Response> postNewProject({
    required String token,
    required String projectTypeId,
    required String title,
    required String description,
    required String timeframeStart,
    required String timeframeEnd,
    required List<String> imagesPaths,
    required List<String> videosPaths, // Assuming you have a list of video paths
  }) async {
    var uri = Uri.parse('https://your-api-endpoint.com/projects'); // Replace with your API endpoint

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      })
      ..fields['project_type_id'] = projectTypeId
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['timeframe_start'] = timeframeStart
      ..fields['timeframe_end'] = timeframeEnd;

    // Add images to the request
    for (var imagePath in imagesPaths) {
      request.files.add(await http.MultipartFile.fromPath('images[]', imagePath));
    }

    // Add videos to the request
    for (var videoPath in videosPaths) {
      request.files.add(await http.MultipartFile.fromPath('videos[]', videoPath));
    }

    // Send the request
    var streamedResponse = await request.send();

    // Get the response from the stream
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('Upload successful');
    } else {
      print('Upload failed');
    }

    return response;
  }
}