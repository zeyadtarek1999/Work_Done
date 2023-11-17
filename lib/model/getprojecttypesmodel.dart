import 'dart:convert';
import 'package:http/http.dart' as http;

class GetAllProjectTypesApi {
  final String baseUrl;

  GetAllProjectTypesApi({required this.baseUrl});

  Future<List<Map<String, String>>> getAllProjectTypes() async {
    try {
      final url = Uri.parse('$baseUrl/api/get_all_project_types');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> typesData = responseData['types_data'];

          // Extract both ID and Name from the typesData and return them as a list of maps
          return typesData
              .map((type) => {'id': type['id'].toString(), 'name': type['name'].toString()})
              .toList();
        } else {
          throw Exception('Failed to get project types. Message: ${responseData['msg']}');
        }
      } else {
        throw Exception('Failed to get project types. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error during API call: $error');
    }
  }
}
