import 'package:http/http.dart' as http;

class UpdateAddressApi {
  static const String baseUrl = 'https://workdonecorp.com/api';

  static Future<void> updateAddress({
    required String token,
    required String street1,
    required String street2,
    required String city,
    required String state,
    required String zipCode,
  }) async {
    final String url = '$baseUrl/update_address';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {
      'street1': street1,
      'street2': street2,
      'city': city,
      'state': state,
      'address_zip': zipCode,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      // Request successful
      print('Address updated successfully');
    } else {
      // Request failed
      print('Failed to update address. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
