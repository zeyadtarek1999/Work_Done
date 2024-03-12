import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterWorkerApiClient {
  final String baseUrl;

  RegisterWorkerApiClient({required this.baseUrl});

  Future<Map<String, dynamic>> registerworker({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String experience,
    List<int>?  jobType,
    String? licenseNumber,
    String? licensePic,
    required String street1,
    required String street2,
    required String city,
    required String state,
    // required String paypal,
    required String addressZip,
    List<int>? languageIds,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/register_worker');

      final request = http.MultipartRequest('POST', url)
        ..fields.addAll({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'experience': experience,
          // 'job_type': jobType,
          // 'paypal': paypal,
          'license_number': licenseNumber ?? '',
          'street1': street1,
          'street2': street2,
          'city': city,
          'state': state,
          'address_zip': addressZip,
        });

      // Explicitly set the 'Content-Type' header
      request.headers['Content-Type'] = 'multipart/form-data';

      // Iterate over the languageIds list and append each language ID as a separate field
      if (languageIds != null) {
        for (var i = 0; i < languageIds.length; i++) {
          request.fields['language[$i]'] = languageIds[i].toString();
        }
      }
      if (jobType != null) {
        for (var i = 0; i < jobType.length; i++) {
          request.fields['job_type[$i]'] = jobType[i].toString();
        }
      }

      if (licensePic != null) {
        final file = File(licensePic);
        request.files.add(
          await http.MultipartFile.fromPath('license_pic', file.path),
        );
      }


// Print after setting up the fields
      print('Request fields: ${request.fields}');
      print('Request fields: ${request.fields}');
      print('Request fields: ${request.fields}');


      final response = await http.Response.fromStream(await request.send());
      print('Request fields: ${request.fields}');
      print('Request fields: ${request.fields}');
      print('Request fields: ${request.fields}');

      if (response.statusCode == 200) {
        // Decode the response body
        final responseBody = json.decode(response.body);

        // Return the decoded response
        return responseBody;
      } else {
        // If the status code is not 200, throw an exception with the error message
        throw Exception(
            'Failed to register worker. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // If an error occurs during the API call, throw an exception with the error message
      throw Exception('Error during registration: $error');
    }
  }
}
