import 'package:http/http.dart' as http;
import 'package:workdone/view/screens/post%20a%20project/project%20post.dart';
import 'dart:io';

class ApiService {
  Future<http.Response> submitProject(ProjectPost projectPost, String bearerToken) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://www.workdonecorp.com/api/insert_project'),
    )..headers['Authorization'] = 'Bearer $bearerToken';

    request.fields['project_type_id'] = projectPost.projectTypeId.toString();
    request.fields['title'] = projectPost.title;
    request.fields['desc'] = projectPost.desc;
    request.fields['timeframe_start'] = projectPost.timeframeStart.toString();
    request.fields['timeframe_end'] = projectPost.timeframeEnd.toString();

    projectPost.images.forEach((image) async {
      request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
    });

    if (projectPost.video != null) {
      request.files.add(await http.MultipartFile.fromPath('video', projectPost.video!.path));
    }

    return await request.send().then((response) => http.Response.fromStream(response));
  }
}