import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchUserData() async {
  final response = await http.get(Uri.parse('https://api.example.com/user'));

  if (response.statusCode == 200) {
    final userData = response.body;
    print(userData);
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
  // Inside your response handling code:
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    print(responseData['data']);
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}
Future<void> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('https://api.example.com/login'),
    body: {
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    final responseData = response.body;
    print(responseData);
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}

Future<void> fetchData() async {
final response = await http.get(Uri.parse('https://api.example.com/data'));
// Handle response...
}
