import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../model/mediaquery.dart';
import '../Bid Details/Bid details Client.dart';
import '../Bid Details/Bid details Worker.dart';
import '../Support Screen/Support.dart';
import '../homescreen/home screenClient.dart';



class Workerprofileother extends StatefulWidget {
  final String userId;
  Workerprofileother( {required this.userId,});
  @override
  _WorkerprofileotherState createState() => _WorkerprofileotherState();
}

class _WorkerprofileotherState extends State<Workerprofileother> {


  bool shouldShowNextButton(List<Item>? nextPageData) {
    // Add your condition to check if the next page is not empty here
    return nextPageData != null && nextPageData.isNotEmpty;
  }
  late  Future<UserProfile> futureProjects;
  List<Item> items = [];
  TextEditingController searchController = TextEditingController();

  final StreamController<String> _likedStatusController = StreamController<String>();

  late Future<RatingInfo> futureRatingInfo;
double barwidth= 150;
double widthofbar = 150;
  Stream<String> get likedStatusStream => _likedStatusController.stream;
  List<String> likedProjects = []; // List to store liked project IDs
  Map<int, bool> likedProjectsMap = {};

  Future<Map<String, dynamic>> addProjectToLikes(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/add_project_to_likes'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $userToken',
        },
        body: {
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          // Project added to likes successfully
          print('Project added to likes successfully');
          _likedStatusController.add("true");

        } else if (responseBody['msg'] == 'This Project is Already in Likes !') {
          // Project is already liked
          print('Project is already liked');
        } else {
          // Handle other error scenarios
          print('Error: ${responseBody['msg']}');
        }

        return responseBody;
      } else {
        // Handle other status codes
        print('Failed to add project to likes. Status code: ${response.statusCode}');
        return {'status': 'error', 'msg': 'Failed to add project to likes'};
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }


  Future<Map<String, dynamic>> removeProjectFromLikes(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('user_token') ?? '';
      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/remove_project_from_likes'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: {
          'project_id': projectId,
        },
      );

      if (response.statusCode == 200) {
        // Successful request, you can handle the response here if needed
        print('Project removed from likes successfully');
        return {'status': 'success', 'msg': 'Project removed from likes successfully'};
      } else {
        // Handle error
        print('Failed to remove project from likes. Status code: ${response.statusCode}');
        return {'status': 'error', 'msg': 'Failed to remove project from likes'};
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      return {'status': 'error', 'msg': 'An error occurred'};
    }
  }
  final ScreenshotController screenshotController = ScreenshotController();

  void refreshProjects() {
    futureProjects = fetchUserProfile(widget.userId);
  }
  Future<void> initializeProjects() async {
    try {
      // Initialize futureProjects in initState or wherever appropriate
      futureProjects = fetchUserProfile(widget.userId);
      refreshProjects();

    } catch (e) {
      // Handle exceptions if any
      print('Error initializing projects: $e');
    }
  }

  Future<void> handleLikeAction(Item item) async {
    try {
      if (item.isLiked == "true") {
        // If liked, remove like
        final response = await removeProjectFromLikes(item.projectId.toString());

        if (response['status'] == 'success') {
          // If successfully removed from likes
          print('Project removed from likes');
        } else {
          // Handle the case where the project is not removed from likes
          print('Error: ${response['msg']}');
        }
      } else {
        // If not liked, add like
        final response = await addProjectToLikes(item.projectId.toString());

        if (response['status'] == 'success') {
          // If successfully added to likes, fetch updated data for the project
          print('Project added to likes');
        } else if (response['msg'] == 'This Project is Already in Likes !') {
          // If the project is already liked, switch to Icons.favorite_border
          print('Project is already liked');
        } else {
          // Handle the case where the project is not added to likes
          print('Error: ${response['msg']}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Future<Item> fetchUpdatedProject(int projectId) async {
  //   // Fetch updated data for the specific project
  //   // You may need to adjust the API endpoint and request parameters
  //   final updatedProjects = await fetchUserProfile(widget.userId);
  //   return updatedProjects.firstWhere((project) => project.projectId == projectId);
  // }



  List<Item> filteredItems = [];
  List<InlineSpan> _buildTextSpans(String text, String query) {
    final spans = <InlineSpan>[];
    final matches = RegExp(query, caseSensitive: false).allMatches(text.toLowerCase());

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }

    int currentIndex = 0;
    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  void _navigateToNextPage(BuildContext context) async {
    Uint8List? imageBytes = await screenshotController.capture();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportScreen(screenshotImageBytes: imageBytes ,unique: unique),
      ),
    );
  }


  Future<void> _getusertype() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/get_user_type';
        print(userToken);

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer $userToken'},
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('user_type')) {
            String userType = responseData['user_type'];

            // Navigate based on user type
            if (userType == 'client') {
              usertype= 'client';
            } else if (userType == 'worker') {
              usertype= 'worker';

            } else {
              print('Error: Unknown user type.');
              throw Exception('Failed to load profile information');
            }
          } else {
            print('Error: Response data does not contain user_type.');
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

  int _currentIndex = 0;
  @override
  void initState() {
  super.initState();
  initializeProjects();
  likedProjectsMap= {};
  super.initState();
  _getusertype();
  _getUserProfile();
  numberofprojects();
  get_review();
  }

  String firstname = '';
  String secondname = '';
  String email = '';
  String profile_pic = '';
  String phone = '';
  String language = '';
  String jobtype = '';
  String usertype = '';
  int projectnumber = 0;
  dynamic stars_5 = 0;
  dynamic stars_4 = 0;
  dynamic stars_3 = 0;
  dynamic stars_2 = 0;
  dynamic stars_1 = 0;
  double avg_rating = 0.0;

  Future<void> get_review() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      if (userToken.isNotEmpty) {
        // Replace the API endpoint with your actual endpoint
        final String apiUrl = 'https://workdonecorp.com/api/rating_details';
        print(userToken);

        final response = await http.post(
          Uri.parse('https://workdonecorp.com/api/rating_details'),
          headers: {
            'Authorization': 'Bearer $userToken',
            'Content-Type': 'application/json', // Add this line
          },
          body: json.encode({
            'user_id': "${widget.userId}",
          }),
        );
        print('userid ww' + widget.userId);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('data')) {
            Map<String, dynamic> data = responseData['data'];
            setState(() {
              stars_1 = data['stars_1'] ?? 0;
              stars_2 = data['stars_2'] ?? 0;
              stars_3 = data['stars_3'] ?? 0;
              stars_4 = data['stars_4'] ?? 0;
              stars_5 = data['stars_5'] ?? 0;
              avg_rating = double.parse(data['avg_rating']);
            });

            print('Response: $responseData');
            print('average: $avg_rating');
            print('average: $avg_rating');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          if (response.statusCode == 500) {
            throw Exception('Internal server error');
          } else {
            throw Exception('Failed to load profile information');
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
      if (error is Exception && error == 'Failed to load data from API: null') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load user profile')));
      } else if (error is Exception && error == 'Internal server error') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Internal server error')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
      }
    }
  }



  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_others_profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'user_id': userId.toString(),
          'filter': "completed",

        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          return UserProfile.fromJson(responseData);
        } else {
          throw Exception('Failed to load data from API: ${responseData['msg']}');
        }
      } else {
        throw Exception('Failed to load data from API: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('user id ${widget.userId}');
      throw Exception('Error retrieving user profile: $e');
    }
  }
  Future<RatingInfo> rating(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userToken = prefs.getString('user_token') ?? '';
      int userIdInt = int.parse(userId);

      final response = await http.post(
        Uri.parse('https://www.workdonecorp.com/api/rating_details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'user_id': userId,
        }),
      );

      print('User data id: $userId');
      print('Variable: $userIdInt');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          print(RatingInfo.fromJson(responseData));
          return RatingInfo.fromJson(responseData);
        } else {
          throw Exception('Failed to load data from API: ${responseData['msg']}');
        }
      } else {
        throw Exception('Failed to load data from API: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error retrieving user rating profile: $e');
    }
  }

  Future<void> numberofprojects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_others_profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'user_id': widget.userId.toString(),
        }),
      );
      print(widget.userId.toString(),);
      if (response.statusCode == 200) {
        Map<dynamic, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('project_count')) {
          int numberproject = responseData['project_count'];

          setState(() {
            projectnumber = numberproject;

          });

          print('Response: $numberproject');
        } else {
          print(
              'Error: Response data does not contain the expected structure.');
          throw Exception('Failed to load profile information');
        }
      } else {
        // Handle error response
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
        throw Exception('Failed to load profile information');
      }


    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }

  Future<void> _getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_token') ?? '';
      print(userToken);

      final response = await http.post(
        Uri.parse('https://workdonecorp.com/api/get_others_profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'user_id': widget.userId.toString(),
        }),
      );
print(widget.userId.toString(),);
        if (response.statusCode == 200) {
          Map<dynamic, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('user_data')) {
            Map<dynamic, dynamic> profileData = responseData['user_data'];
            String languageString;
            String jobtypeString;
            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
              phone = profileData['phone'] ?? '';
              language = profileData['language'] ?? '';
              List<dynamic> jobtypes = profileData['job_type'] ?? [];
              List<String> jobtypeNames = jobtypes.map<String>((jobtype) => jobtype['name']).toList();
              jobtypeString = jobtypeNames.join(', ');
              jobtype =jobtypeString;
              List<dynamic> languages = profileData['language'] ?? [];
              List<String> languageNames = languages.map<String>((language) => language['name']).toList();
              languageString = languageNames.join(', ');
              language = languageString;
            });

            print('Response: $profileData');
            print('profile pic: $profile_pic');
          } else {
            print(
                'Error: Response data does not contain the expected structure.');
            throw Exception('Failed to load profile information');
          }
        } else {
          // Handle error response
          print('Error: ${response.statusCode}, ${response.reasonPhrase}');
          throw Exception('Failed to load profile information');
        }


    } catch (error) {
      // Handle errors
      print('Error getting profile information: $error');
    }
  }


  String unique= 'WorkerView' ;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton:
      FloatingActionButton(    heroTag: 'workdone_${unique}',



        onPressed: () {
          _navigateToNextPage(context);

        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
child: Icon(Icons.help ,color: Colors.white,), // Use the support icon        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("$firstname Profile", style: TextStyle(color: Colors.black),),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.black,),

      ),
      body:
      Screenshot(
        controller:screenshotController ,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      Center(
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 5),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.transparent,
                            backgroundImage: profile_pic == '' || profile_pic.isEmpty
                                || profile_pic == "https://workdonecorp.com/storage/" ||
                                !(profile_pic.toLowerCase().endsWith('.jpg') || profile_pic.toLowerCase().endsWith('.png'))

                                ? AssetImage('assets/images/default.png') as ImageProvider
                                : NetworkImage(profile_pic?? 'assets/images/default.png'),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                       Text("$firstname", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                      SizedBox(height: 10,),
                       Text("Worker", style: TextStyle(color: Colors.grey, fontSize: 16),),
                      SizedBox(height: 16,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star,color: Colors.yellow,size: 30,),SizedBox(width: 8,),
                              Text('${avg_rating}',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: HexColor('454545'),
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),),
                            ],
                          ),
SizedBox(height: 10,),

                      RatingBar.builder(
                        ignoreGestures: true, // Set to true to make it unchoosable

                        initialRating: avg_rating,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 40,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      SizedBox(height: 10,),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                       backgroundColor: Color(0xFF4D8D6E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(

                              title: Text('Rating Bar'),
                              content:        Container(
                                height: 260,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('5'),
                                        SizedBox(width: 8,),
                                        Stack(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                            Container(
                                              width: barwidth *(stars_5/100),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 9,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('4'),
                                        SizedBox(width: 8,),
                                        Stack(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                            Container(
                                              width: barwidth *(stars_4/100),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 9,),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('3'),
                                        SizedBox(width: 8,),
                                        Stack(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                            Container(
                                              width: barwidth *(stars_3/100),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 9,),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('2'),
                                        SizedBox(width: 8,),
                                        Stack(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                            Container(
                                              width: barwidth *(stars_2/100),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 9,),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('1'),
                                        SizedBox(width: 8,),
                                        Stack(
                                          children: [
                                            Container(
                                              width: 150,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                            Container(
                                              width: barwidth *(stars_1/100),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.transparent), // Set border color to transparent
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),

                                  ],
                                ),
                              )    ,

                                actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Rating bar' ,style: TextStyle(color: Colors.white),),
                    ),
                  ),
                      SizedBox(height: 10,),

                      FutureBuilder<UserProfile>(
                        future: futureProjects,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data != null) {
                            UserProfile userProfile = snapshot.data!;

                            return                                                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('license ',style: TextStyle(color: Colors.black45,fontSize: 18),),
                                Container(
                                  child: userProfile.userData.license_pic != '' &&
                                      userProfile.userData.license_pic.isNotEmpty &&
                                      userProfile.userData.license_pic != "https://workdonecorp.com/images/"
                                      ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24.0,
                                  )
                                      : Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.grey,
                                    size: 24.0,
                                  ),
                                ),
                              ],
                            );

                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: SvgPicture.asset(
                                    'assets/images/nothing.svg',
                                    width: 100.0,
                                    height: 100.0,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'No Projects yet',
                                  style: GoogleFonts.encodeSans(
                                    textStyle: TextStyle(
                                      color: HexColor('BBC3CE'),
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                                          SizedBox(height: 20),

                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(

                                  children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,

                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                           backgroundColor: Color(0xFF4D8D6E),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              enableDrag: true,

                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(20),
                                                      topRight: Radius.circular(20),
                                                    ),
                                                    color: HexColor('#F9F9F9'),
                                                  ),
                                                  child: FutureBuilder<UserProfile>(
                                                    future: futureProjects,
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(
                                                          child: CircularProgressIndicator(),
                                                        );
                                                      } else if (snapshot.hasError) {
                                                        return Text('Error: ${snapshot.error}');
                                                      } else if (snapshot.data != null) {
                                                        UserProfile userProfile = snapshot.data!;
                                                        String languageString;

                                                        List <dynamic> languagelist = userProfile.userData.languages;
                                                        List<String> languageNames = languagelist.map<String>((language) => language['name']).toList();
                                                        languageString = languageNames.join(', ');


                                                        return                                       Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    'Worker Info'.toUpperCase(),
                                                                    style: TextStyle(
                                                                        color: HexColor('#022C43'),
                                                                        fontSize: 20,
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),

                                                                SizedBox(height: 10,),
                                                                Container(
                                                                    height: 50,
                                                                    width: double.infinity,
                                                                    decoration: BoxDecoration(
                                                                      border: Border(
                                                                        bottom: BorderSide(
                                                                          color: HexColor('#707070').withOpacity(0.1),
                                                                          width: 1,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    child: SingleChildScrollView(
                                                                      scrollDirection: Axis.horizontal, // Set scroll direction to horizontal

                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,


                                                                        children: [
                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                                                            child: Text(
                                                                              'Language Spoken:',
                                                                              style: TextStyle(
                                                                                color: HexColor('#4D8D6E'),
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 17,
                                                                              ),
                                                                              textAlign: TextAlign.start,
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: ScreenUtil.sizeboxwidth3),
                                                                          Text(

                                                                            '${language}',
                                                                            style: TextStyle(
                                                                                color: HexColor('#404040'), fontSize: 15),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )),
                                                                Container(
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      bottom: BorderSide(
                                                                        color: HexColor('#707070').withOpacity(0.1),
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,

                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                                                        child: Text(
                                                                          'Experience:',
                                                                          style: TextStyle(
                                                                              color: HexColor('#4D8D6E'),
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 17),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: ScreenUtil.sizeboxwidth3,
                                                                      ),
                                                                      Text(
                                                                        '${userProfile.userData.experience} Years of Experience   ',
                                                                        style: TextStyle(
                                                                            color: HexColor('#404040'), fontSize: 15),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      bottom: BorderSide(
                                                                        color: HexColor('#707070').withOpacity(0.1),
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: SingleChildScrollView(
                                                                    scrollDirection: Axis.horizontal, // Set scroll direction to horizontal

                                                                    child: Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                                                          child: Text(
                                                                            'Job Type: ',
                                                                            style: TextStyle(
                                                                                color: HexColor('#4D8D6E'),
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 17),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width: ScreenUtil.sizeboxwidth3,
                                                                        ),
                                                                        Text(
                                                                          '${jobtype}  ',
                                                                          style: TextStyle(
                                                                              color: HexColor('#404040'), fontSize: 15),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),

                                                                                                                  SizedBox(height: 20,),
                                                                Center(
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop(); // Close the bottom sheet
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                     backgroundColor: HexColor('#4D8D6E'), // Background color
                                                                    ),
                                                                    child: Text('Close',style: TextStyle(color: Colors.white),),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                            // Container(
                                                            //   height: 50,
                                                            //   decoration: BoxDecoration(
                                                            //     border: Border(
                                                            //       bottom: BorderSide(
                                                            //         color: HexColor('#707070').withOpacity(0.1),
                                                            //         width: 1,
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            //   child: Row(
                                                            //     children: [
                                                            //       Padding(
                                                            //         padding: EdgeInsets.symmetric(horizontal: 12),
                                                            //         child: Text(
                                                            //           'experience:',
                                                            //           style: TextStyle(
                                                            //               color: HexColor('#4D8D6E'),
                                                            //               fontWeight: FontWeight.w400,
                                                            //               fontSize: 17),
                                                            //         ),
                                                            //       ),
                                                            //       SizedBox(
                                                            //         width: ScreenUtil.sizeboxwidth3,
                                                            //       ),
                                                            //       Text(
                                                            //         '${experience.toString()}    ',
                                                            //         style: TextStyle(
                                                            //             color: HexColor('#404040'), fontSize: 15),
                                                            //       )
                                                            //     ],
                                                            //   ),
                                                            // ),

                                                            SizedBox(
                                                              height: 17,
                                                            ),

                                                          ],
                                                        );

                                                      } else {
                                                        return Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                              child: SvgPicture.asset(
                                                                'assets/images/nothing.svg',
                                                                width: 100.0,
                                                                height: 100.0,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Text(
                                                              'No Projects yet',
                                                              style: GoogleFonts.encodeSans(
                                                                textStyle: TextStyle(
                                                                  color: HexColor('BBC3CE'),
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.normal,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            );

                                          },
                                          child: Text('Worker Details' ,style: TextStyle(color: Colors.white),),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 12,),

                                    Text("${projectnumber.toString()}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                    SizedBox(height: 5,),
                                    Text("Projects", style: TextStyle(color: Colors.grey,),),



                                  ],
                                ),

                              ]
                          )
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Expanded(child: Container(
                            color: Colors.black45,
                            height: 2,
                          )),
                        ],
                      ),
                      SizedBox(height: 8,)
                      ,Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Completed Projects',
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: HexColor('#4D8D6E'), // Hex color
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 4, // Spread radius
                              blurRadius: 9, // Blur radius
                              offset: Offset(6, 5), // Offset in the x and y direction
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8,)
,
                      Row(
                        children: [
                          Expanded(child: Container(
                            color: Colors.black45,
                            height: 2,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ];
          },
          body:                     SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<UserProfile>(
                  future: futureProjects,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.data != null) {
                      UserProfile userProfile = snapshot.data!;
                      if (userProfile.projects.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: SvgPicture.asset(
                                'assets/images/nothing.svg',
                                width: 100.0, // Set the width you want
                                height: 100.0, // Set the height you want
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'No Projects yet',
                              style: GoogleFonts.encodeSans(
                                textStyle: TextStyle(
                                    color: HexColor('BBC3CE'),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Animate(
                          effects: [SlideEffect(duration: Duration(milliseconds: 800),),],
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: userProfile.projects.length,
                            itemBuilder: (context, index) {
                              return buildProjectItem(userProfile.projects[index]);
                            },
                          ),
                        );
                      }
                    } else {
                      return Container(); // or return any other widget you want to show when the data is null
                    }
                  },
                ),
                SizedBox(height: 50,)
              ],
            ),
          )

        ),
      ),



    );

  }

  Widget buildProjectItem(Project project) {
    String ratingOnWorker = project.reviews.ratingOnWorker.toString() ?? 'No rate yet';

    return GestureDetector(
      onTap: () {
        Get.to(
              () =>  usertype=='client'?
              bidDetailsClient(projectId: project.projectId):
              bidDetailsWorker(projectId: project.projectId),


        );    },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 11.0, horizontal: 16),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 170.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: PageView.builder(
                      pageSnapping: true
                      ,

                      itemCount: project.images.length, // The count of total images
                      controller: PageController(viewportFraction: 1), // PageController for full-page scrolling
                      itemBuilder: (_, index) {
                        return Image.network(
                          project.images[index], // Access each image by index
                          fit: BoxFit.cover, // Cover the entire area of the container
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Spacer(), // Pushes the container to the right
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 5),
                              child: Text(
                                "${project.numbersOfLikes}",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                likedProjectsMap[project.projectId] ?? project.liked == "true"
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: likedProjectsMap[project.projectId] ?? project.liked == "true"
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                try {
                                  if (likedProjectsMap[project.projectId] ?? project.liked == "true") {
                                    // If liked, remove like
                                    final response = await removeProjectFromLikes(project.projectId.toString());

                                    if (response['status'] == 'success') {
                                      // If successfully removed from likes
                                      setState(() {
                                        likedProjectsMap[project.projectId] = false;
                                        project.numbersOfLikes = (project.numbersOfLikes ?? 0) - 1;
                                      });
                                      print('Project removed from likes');
                                    } else {
                                      // Handle the case where the project is not removed from likes
                                      print('Error: ${response['msg']}');
                                    }
                                  } else {
                                    // If not liked, add like
                                    final response = await addProjectToLikes(project.projectId.toString());

                                    if (response['status'] == 'success') {
                                      // If successfully added to likes
                                      setState(() {
                                        likedProjectsMap[project.projectId] = true;
                                        project.numbersOfLikes = (project.numbersOfLikes ?? 0) + 1;
                                      });
                                      print('Project added to likes');
                                    } else if (response['msg'] == 'This Project is Already in Likes !') {
                                      // If the project is already liked, switch to Icons.favorite_border
                                      setState(() {
                                        likedProjectsMap[project.projectId] = false;
                                      });
                                      print('Project is already liked');
                                    } else {
                                      // Handle the case where the project is not added to likes
                                      print('Error: ${response['msg']}');
                                    }
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                }
                              },
                            ),
                          ],
                        ),

                      ),
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        project.title.length > 16
                            ? project.title.substring(0, 16) + '...' // Display first 14 letters and add ellipsis
                            : project.title,
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('131330'),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Spacer(),
                      Text(
                        'By',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(width: 4,),
                      Container(
                        height: 33,
                        width: 60,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                            onPressed: () {
                              Get.to(Workerprofileother(userId:project.clientId.toString(),
                              ),
                                transition: Transition.fadeIn, // You can choose a different transition
                                duration: Duration(milliseconds: 700), // Set the duration of the transition

                              );
                            },
                            style: TextButton.styleFrom(
                              fixedSize: Size(50, 30), // Adjust the size as needed
                              padding: EdgeInsets.zero,
                            ),
                            child:
                            Text(
                              "${project.clientFirstname}",

                              maxLines: 1,
                              overflow: TextOverflow.visible, // Use the client name from the fetched data
                              style: TextStyle(
                                color: HexColor('4D8D6E'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: _buildTextSpans(project.desc, searchController.text),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              color: HexColor('393B3E'),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 7,),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star,color: Colors.yellow,),
                              Text(
                                '${ratingOnWorker}',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('393B3E'),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
SizedBox(height: 3,),
                          Text(
                            'lowest bid',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'), // Adjust color as needed
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 6,),
                          project.lowestBid != 'No Bids'
                              ? Text('\$ '+
                              project.lowestBid.toString() , // Use 'N/A' or any preferred default text
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('393B3E'),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                              : Text(
                            'No Bids Yet',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  ,
                  SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: HexColor('777778'),
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        project.postedFrom, // Use the posted time from the fetched data
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('777778'),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(width: 2),
                      Spacer(),
                      Container(
                        width: 93,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor('4D8D6E'),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(
                                  () =>  usertype=='client'?
                                  bidDetailsClient(projectId: project.projectId):
                                  bidDetailsWorker(projectId: project.projectId),


                            );
                            // Handle button press
                          },
                          child: Text('Details',style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.transparent,
                            elevation: 0,
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );

  }

}


class UserProfile {
  final String status;
  final String msg;
  final UserData userData;
  final List<Project> projects;
  final int projectCount;

  UserProfile({
    required this.status,
    required this.msg,
    required this.userData,
    required this.projects,
    required this.projectCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      status: json['status'],
      msg: json['msg'],
      userData: UserData.fromJson(json['user_data']),
      projects: List<Project>.from(json['projects'].map((project) => Project.fromJson(project))),
      projectCount: json['project_count'],
    );
  }
}

class UserData {
  final String firstname;
  final String lastname;
  final String email;
  final String profilePic;
  final dynamic experience;
  final dynamic phone;
  List<dynamic> languages;
  final String license_number;
  final String license_pic;
  List<dynamic> job_type;

  UserData({
    required this.firstname,
    required this.license_number,
    required this.job_type,
    required this.license_pic,
    required this.experience,
    required this.lastname,
    required this.email,
    required this.profilePic,
    required this.phone,
    required this.languages,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {

    return UserData(
      firstname: json['firstname']??'',
      lastname: json['lastname']??'',
      email: json['email']??'',
      profilePic: json['profile_pic']??'',
      job_type: json['job_type']??'',
      phone: json['phone']??'',
      license_number: json['license_number']??'',
      license_pic: json['license_pic']??'',
      languages: json['language']?? [],
      experience: json['experience']??0,

    );

  }
}

class Project {
  final int projectId;
  final int clientId;
  final String clientFirstname;
  final String projectTypeId;
  final String title;
  final String desc;
  final String timeframeStart;
  final String timeframeEnd;
  final List<String> images;
  final String? video;
  final String postedFrom;
  final String liked;
   int? numbersOfLikes;
  final dynamic lowestBid;
  final Reviews reviews;

  Project({
    required this.projectId,
    required this.clientId,
    required this.clientFirstname,
    required this.projectTypeId,
    required this.title,
    required this.desc,
    required this.timeframeStart,
    required this.timeframeEnd,
    required this.images,
    required this.video,
    required this.postedFrom,
    required this.liked,
    required this.numbersOfLikes,
    required this.lowestBid,
    required this.reviews,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'],
      clientId: json['client_id'],
      clientFirstname: json['client_firstname'],
      projectTypeId: json['project_type_id'],
      title: json['title'],
      desc: json['desc'],
      timeframeStart: json['timeframe_start'],
      timeframeEnd: json['timeframe_end'],
      images: List<String>.from(json['images'].map((image) => image)),
      video: json['video'],
      postedFrom: json['posted_from'],
      liked: json['liked'],
      numbersOfLikes: json['numbers_of_likes'],
      lowestBid: json['lowest_bid'],
      reviews: Reviews.fromJson(json['reviews']),
    );
  }
}

class Reviews {
  final String? reviewOnWorker;
  final int? ratingOnWorker;
  final String? reviewOnClient;
  final int? ratingOnClient;

  Reviews({
    required this.reviewOnWorker,
    required this.ratingOnWorker,
    required this.reviewOnClient,
    required this.ratingOnClient,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      reviewOnWorker: json['review_on_worker'],
      ratingOnWorker: json['rating_on_worker']??0,
      reviewOnClient: json['review_on_client'],
      ratingOnClient: json['rating_on_client']??0,
    );
  }
}


class RatingInfo {
  final String avgRating;
  final int stars5;
  final int stars4;
  final int stars3;
  final int stars2;
  final int stars1;

  RatingInfo({
    required this.avgRating,
    required this.stars5,
    required this.stars4,
    required this.stars3,
    required this.stars2,
    required this.stars1,
  });

  factory RatingInfo.fromJson(Map<String, dynamic> json) {
    return RatingInfo(
      avgRating: json['avg_rating'],
      stars5: json['stars_5'],
      stars4: json['stars_4'],
      stars3: json['stars_3'],
      stars2: json['stars_2'],
      stars1: json['stars_1'],
    );
  }
}
