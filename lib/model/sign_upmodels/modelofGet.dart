import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:untitled/model/sign_upmodels/modelofGet.dart';
//
// import 'modelofGet.dart';
// import 'modelofGet.dart';
//
//
// class UserModel {
//   UserModel({
//     required this.id,
//     required this.firstname,
//     required this.lastname,
//     required this.email,
//     required this.address,
//     required this.phone,
//     required this.license_no,
//     required this.exp_years,
//     required this.password,
//     required this.worker_zip,
//     required this.worker_raduis,
//     required this.license_photo, required langs,
//   });
//
//   int id;
//   String firstname;
//   String lastname;
//   String email;
//   Address address;
//   String phone;
//   String license_no;
//   String exp_years;
//   String password;
//   String worker_zip;
//   String worker_raduis;
//   String license_photo;
//   langs langs;
//
//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//         id: json["id"],
//         email: json["email"],
//         address: Address.fromJson(json["address"]),
//         phone: json["phone"],
//         langs: langs.fromJson(json["langs"]),
//         firstname: '',
//         lastname: '',
//         license_no: '',
//         exp_years: '',
//         password: '',
//         worker_zip: '',
//         worker_raduis: '',
//         license_photo: '',
//       );
//
//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "email": email,
//         "address": address.toJson(),
//         "phone": phone,
//         "langs": langs.toJson(),
//
//       };
//
// }
//
// class Address {
//   Address({
//     required this.street,
//     required this.suite,
//     required this.city,
//     required this.zipcode,
//   });
//
//   String street;
//   String suite;
//   String city;
//   String zipcode;
//
//   factory Address.fromJson(Map<String, dynamic> json) => Address(
//         street: json["street"],
//         suite: json["suite"],
//         city: json["city"],
//         zipcode: json["zipcode"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "street": street,
//         "suite": suite,
//         "city": city,
//         "zipcode": zipcode,
//       };
// }
//
// class langs {
//   langs({
//     required this.name,
//     required this.catchPhrase,
//     required this.bs,
//   });
//
//   String name;
//   String catchPhrase;
//   String bs;
//
//   factory langs.fromJson(Map<String, dynamic> json) => langs(
//         name: json["name"],
//         catchPhrase: json["catchPhrase"],
//         bs: json["bs"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "catchPhrase": catchPhrase,
//         "bs": bs,
//       };
// }
// Future<List<UserModel>> fetchUsers() async {
//   final response = await http.get(Uri.parse('http://172.233.199.17/worker.php'));
//
//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     final List<UserModel> users = data.map((json) => UserModel.fromJson(json)).toList();
//     return users;
//   } else {
//     throw Exception('Failed to load users');
//   }
// }
//

import 'dart:convert';

class WorkerApi {
  static const String baseUrl = 'http://172.233.199.17/worker.php';

  Future<Map<String, dynamic>> _sendRequest(Map<String, dynamic> formData) async {
    final response = await http.post(Uri.parse(baseUrl), body: formData);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> addWorker(Map<String, dynamic> formData) async {
    formData['action'] = 'add_worker';
    return await _sendRequest(formData);
  }

  Future<Map<String, dynamic>> editWorkerAddress(Map<String, dynamic> formData) async {
    formData['action'] = 'edit_address';
    return await _sendRequest(formData);
  }

// Define more methods for other API requests as needed
}
