import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MoreClientController extends GetxController {
  var profile_pic = ''.obs;
  var firstname = ''.obs;
  var secondname = ''.obs;
  var email = ''.obs;
  var isLoading = true.obs;
  Future<void> refreshData() async {
    _getUserProfile();
  }
  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';

      if (userToken.isNotEmpty) {
        final String apiUrl = 'https://workdonecorp.com/api/get_profile_info';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<String, dynamic> profileData = responseData['data'];

            profile_pic.value = profileData['profile_pic'] ?? '';
            firstname.value = profileData['firstname'] ?? '';
            secondname.value = profileData['lastname'] ?? '';
            email.value = profileData['email'] ?? '';
          } else {
            throw Exception('Failed to load profile information');
          }
        } else {
          throw Exception('Failed to load profile information');
        }
      }
      isLoading.value = false;
    } catch (error) {
      print('Error getting profile information: $error');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _getUserProfile();
  }
}
