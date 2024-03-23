import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:workdone/model/firebaseNotification.dart';
import 'package:workdone/model/save_notification_to_firebase.dart';

import '../../widgets/rounded_button.dart';

class SupportScreen extends StatefulWidget {
  final Uint8List? screenshotImageBytes;
 String? unique ;
  SupportScreen({required this.screenshotImageBytes, required this.unique});

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  TextEditingController descriptionController = TextEditingController();
  File? screenshotImageFile;
  late AnimationController ciruclaranimation;
  bool _isUploading = false;
  void _toggleUploadingState(bool isUploading) {
    setState(() => _isUploading = isUploading);
  }
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int  ? userId ;

  Future<void> getuserid() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);
      print ('fetching user id');
      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://www.workdonecorp.com/api/get_user_id_by_token';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          print ('done  user id');

          if (responseData.containsKey('user_id')) {

            userId = responseData['user_id'];

            // Now, userId contains the extracted user_id value
            print('User ID: $userId');

            // Optionally, save the user_id to SharedPreferences
            prefs.setInt('user_id', userId ?? 0);
          } else {
            print('Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }
      }
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }


  @override
  void initState() {
    super.initState();
    getuserid();
    if (widget.screenshotImageBytes != null) {
      // Convert Uint8List to File
      screenshotImageFile = _imageFileFromBytes(widget.screenshotImageBytes!);
    }
    ciruclaranimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    ciruclaranimation.repeat(reverse: false);

  }

  File _imageFileFromBytes(Uint8List bytes) {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/screenshot.png');
    file.writeAsBytesSync(bytes);
    return file;
  }

  Future<void> submitsupport() async {
    print('Fetching user token from SharedPreferences...');


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('user_token') ?? '';

    print('Creating request...');
    // Define headers in a map
    final headers = <String, String>{
      'Authorization': 'Bearer $userToken',
      // 'Content-Type': 'multipart/form-data', This is added automatically when adding files to the MultipartRequest.
    };



    var request = http.MultipartRequest('POST', Uri.parse('https://www.workdonecorp.com/api/support'))
      ..headers.addAll(headers)
      ..fields['issue'] = descriptionController.text;

    if (screenshotImageFile != null) {
      var file = await http.MultipartFile.fromPath(
        'screenshot',
        screenshotImageFile!.path,
      );
      request.files.add(file);
    }else{
      Fluttertoast.showToast(
        msg: 'no image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    print('Request fields: ${request.fields}');
    print('Request files: ${request.files.length}');
    print('Sending request...');

    try {
      _toggleUploadingState(true); // Start loading

      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');
      var streamedResponse = await request.send();

      print('Request sent. Status code: ${streamedResponse.statusCode}');
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        setState(() {
          _toggleUploadingState(false);
        });
        DateTime currentTime = DateTime.now();

        // Format the current time into your desired format
        String formattedTime = DateFormat('h:mm a').format(currentTime);
        Map<String, dynamic> newNotification = {
          'title': 'Support Ticket 🔔',
          'body': 'A new support ticket has been submitted. 🎫 ',
          'time': formattedTime,
          // Add other notification data as needed
        };
        print('sended notification ${[newNotification]}');


        SaveNotificationToFirebase.saveNotificationsToFirestore(userId.toString(), [newNotification]);
        print('getting notification');

        // Get the user document reference
        // Get the user document reference
        // Get the user document reference
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId.toString());

// Get the user document
        DocumentSnapshot doc = await userDocRef.get();

// Check if the document exists
        if (doc.exists) {
          // Extract the FCM token and notifications list from the document
          String? receiverToken = doc.get('fcmToken');
          List<Map<String, dynamic>> notifications = doc.get('notifications').cast<Map<String, dynamic>>();

          // Check if the new notification is not null and not already in the list
          if (newNotification != null && !notifications.any((notification) => notification['id'] == newNotification['id'])) {
            // Add the new notification to the beginning of the list
            notifications.insert(0, newNotification);

            // Update the user document with the new notifications list
            await userDocRef.update({
              'notifications': notifications,
            });

            print('Notifications saved for user $userId');
          }

          // Display the notifications list in the app
          print('Notifications for user $userId:');
          for (var notification in notifications) {
            String? title = notification['title'];
            String? body = notification['body'];
            print('Title: $title, Body: $body');
            await NotificationUtil.sendNotification(title ?? 'Default Title', body ?? 'Default Body', receiverToken ?? '2',DateTime.now());
            print('Last notification sent to $userId');
          }
        } else {
          print('User document not found for user $userId');
        }


        Fluttertoast.showToast(
          msg: 'Support Ticket Inserted',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);

        // Handle success
      } else {
        Fluttertoast.showToast(
          msg: 'Error : ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Failed with status code: ${response.statusCode}');
        _toggleUploadingState(false); // Stop loading regardless of the outcome

        // Handle failure
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error : $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('An exception occurred: $e');
      // Handle exception
    }
  }



  @override
  void dispose() {
    // Dispose of any resources when the widget is removed
    if (widget.screenshotImageBytes != null) {
      widget.screenshotImageBytes!.buffer.asUint8List().clear();
    }
    ciruclaranimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('F5F5F5'),
      appBar: AppBar(
        title: Text(
          'Support',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: HexColor('3A3939'),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 3,
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_sharp,
            color: HexColor('1A1D1E'),
            size: 27,
          ),
        ),
        toolbarHeight: 67,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content of Screen',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: HexColor('424347'),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (widget.screenshotImageBytes != null)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 300,
                      height: 340,
                      child: Center(
                        child: Hero(
                          tag: 'workdone_${widget.unique}',
                          child: Image.memory(
                            widget.screenshotImageBytes!,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
            
                SizedBox(height: 20),
                Text(
                  'Describe the issue:',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: HexColor('424347'),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[200],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(controller:descriptionController ,
                      decoration: InputDecoration(
            
                        hintText: 'Please write a detailed message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a detailed message';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: _isUploading
                      ? Center(
                    child: RotationTransition(
                      turns: ciruclaranimation,
                      child: SvgPicture.asset(
                        'assets/images/Logo.svg',
                        semanticsLabel: 'Your SVG Image',
                        width: 70,
                        height: 80,
                      ),
                    ),
                  )
                  // Show loading indicator when uploading
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedButton(
                        text: 'Submit',
                        press: () {
                          if (_formKey.currentState!.validate()) {
                            submitsupport();
                          } else  { Fluttertoast.showToast(
                            msg: 'please enter the issue description',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );}                                              },
                      ),
                    ],
                  ),
                ),            ],
            ),
          ),
        ),
      ),
    );
  }
}
