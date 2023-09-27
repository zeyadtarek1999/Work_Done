import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';


// class PostsignupData {
//   final String firstname;
//   final String lastname;
//   final String email;
//   final String phone;
//   final String worker_license_no;
//   final String exp_years;
//   final String langs;
//
//   final String worker_zip;
//   final String worker_raduis;
//   final String address_st1;
//   final String address_st2;
//   final String address_city;
//   final String address_state;
//   final String worker_job_type;
//   final String worker_prefered_pay;
//   final String worker_other_job_type;
//   final String worker_username;
//   final String worker_password;
//   final String action;
//
//
//
//   final String worker_license_photo; // Add this field to hold the image file path
//   final String worker_profile_pic; // Add this field to hold the image file path
//
//   PostsignupData( {
//     required this.address_st1,
//     required this.langs,
//     required this.worker_password,
//     required this.worker_prefered_pay,
//     required this.address_st2,
//     required this.address_city,
//     required this.address_state,
//     required this.firstname,
//     required this.lastname,
//     required this.email,
//     required this.phone,
//     required this.worker_license_no,
//     required this.exp_years,
//     required this.worker_zip,
//     required this.worker_raduis,
//     required this.worker_license_photo,  // Initialize the image file path
//     required this.worker_profile_pic,  // Initialize the image file path
//     required this.worker_job_type,  // Initialize the image file path
//     required this.worker_other_job_type,  // Initialize the image file path
//     required this.worker_username,  // Initialize the image file path
//     required this.action,  // Initialize the image file path
//
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       "worker_firstname": firstname,
//       "worker_password": worker_password,
//       "worker_username": worker_username,
//       "action": action,
//       "worker_prefered_pay": worker_prefered_pay,
//       "worker_lastname": lastname,
//       "worker_other_job_type": worker_other_job_type,
//       "worker_job_type": worker_job_type,
//       "email": email,
//       "phone": phone,
//       "worker_license_no": worker_license_no,
//       "worker_exp_years": exp_years,
//       "worker_zip": worker_zip,
//       "worker_raduis": worker_raduis,
//       "langs[]": langs,
//     "address_st1":address_st1,
//     "address_st2":address_st2,
//     "address_city": address_city,
//     "address_state": address_state,
//     "worker_license_photo": worker_license_photo,
//     "worker_profile_pic": worker_profile_pic,
//
//
//     };
//   }
// }
//
//
//
// Future<void> postDataToApi(PostsignupData data) async {
//   final apiUrl = 'http://172.233.199.17/worker.php';
//   final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//
//   // Set headers
//   request.headers['Content-Type'] = 'multipart/form-data';
//
//   // Add fields to the request
//   request.fields['worker_firstname'] = data.firstname;
//   request.fields['worker_lastname'] = data.lastname;
//   request.fields['action'] = data.action;
//   request.fields['worker_email'] = data.email;
//   request.fields['worker_prefered_pay'] = data.worker_prefered_pay;
//   request.fields['worker_other_job_type'] = data.worker_other_job_type;
//   request.fields['worker_phone'] = data.phone;
//   request.fields['worker_job_type'] = data.worker_job_type;
//   request.fields['worker_license_no'] = data.worker_license_no;
//   request.fields['worker_raduis'] = data.worker_raduis;
//   request.fields['exp_years'] = data.exp_years;
//   request.fields['worker_zip'] = data.worker_zip;
//   request.fields['address_st1'] = data.address_st1;
//   request.fields['address_st2'] = data.address_st2;
//   request.fields['address_city'] = data.address_city;
//   request.fields['address_state'] = data.address_state;
//   request.fields['langs[]'] = data.langs;
//   request.fields['worker_profile_pic'] = data.worker_profile_pic;
//   request.fields['worker_license_photo'] = data.worker_license_photo;
//
//   // Add image file to the request
//   if (data.worker_license_photo.isNotEmpty) {
//     final imageFile = await http.MultipartFile.fromPath(
//       'license_photo',
//       data.worker_license_photo,
//       contentType: MediaType('image', 'jpeg'), // Adjust content type if needed
//     );
//     request.files.add(imageFile);
//   }
//
//   final response = await request.send();
//
//   if (response.statusCode == 201) {
//     print('Data posted successfully');
//
//     final responseData = await response.stream.bytesToString();
//     if (responseData.isNotEmpty) {
//       final jsonResponse = jsonDecode(responseData);
//       print('Response JSON: $jsonResponse');
//
//       if (jsonResponse.containsKey('worker_id')) {
//         final workerId = jsonResponse['worker_id'];
//         // Save workerId to local storage or use it as needed
//         print('Worker ID: $workerId');
//       } else {
//         print('Response does not contain worker_id');
//       }
//     } else {
//       print('Response data is empty');
//     }
//   } else {
//     print('Failed to post data. Status code: ${response.statusCode}');
//   }
// }
Future<void> postDataToApi() async {
  final apiUrl = 'http://172.233.199.17/worker.php';

  // Form data for the request
  final formData = {
    'worker_firstname': 'Mina',
    'worker_lastname': 'Amir',
    'worker_license_no': 'liscence no 1',
    'worker_email': 'test@mina.com',
    'worker_phone': '01207155318',
    'worker_job_type': '1',
    'worker_other_job_type': '',
    'worker_exp_years': '3',
    'worker_zip': '11123',
    'worker_raduis': '23',
    'worker_prefered_pay': 'PayPal',
    'address_st1': '14 st khalat shoubra',
    'address_st2': 'street 2',
    'address_city': 'Cairo',
    'address_state': 'Shoubra',
    'address_zip': '111234',
    'worker_username': 'username',
    'worker_password': 'password',
    'langs[]': '1',
    'action': 'add_worker',
  };

  final response = await http.post(
    Uri.parse(apiUrl),
    body: formData,
  );

  if (response.statusCode == 200) {
    print('Data posted successfully');
    // Handle response data if needed
  } else {
    print('Failed to post data. Status code: ${response.statusCode}');
  }
}
