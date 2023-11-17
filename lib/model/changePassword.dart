import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class changepasswordapimodel {
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';

      final String apiUrl = 'https://workdonecorp.com/api/change_password';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        // Password changed successfully
        print('Password changed successfully');
      } else {
        // Handle error response
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error changing password: $error');
    }
  }
}