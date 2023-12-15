import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Bid Details/Bid details Worker.dart';
import '../Support Screen/Helper.dart';
import '../homescreen/home screenClient.dart';



class ProfilePageClient extends StatefulWidget {
  final String userId;
  ProfilePageClient( {required this.userId,});
  @override
  _ProfilePageClientState createState() => _ProfilePageClientState();
}

class _ProfilePageClientState extends State<ProfilePageClient> {

  List<reviewsitems> reviewsitems2 = [
    reviewsitems(
      imagePath: 'assets/images/testimage.jpg',
      itemName: 'Wall Painting',
      description: 'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
      by: 'John',
      timeAgo: '22 min',
      bidAmount: '5',
    ),
    reviewsitems(
      imagePath: 'assets/images/pluming.jpg',
      itemName: 'Plumbing',
      description: 'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
      by: 'Yousef',
      timeAgo: '30 min',
      bidAmount: '7',
    ),
    // Add more data items as needed
  ];

  late Future<List<Projects>> futureProjects;



  String firstname = '';
  String secondname = '';
  String email = '';
  String profile_pic = '';
  String phone = '';
  String language = '';
  String usertype = '';
  int projectnumber = 0;
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

  Future<List<Projects>> fetchProject() async {
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

        if (response.statusCode == 200) {
          final dynamic responseData = json.decode(response.body);

          if (responseData['status'] == 'success') {
            final List<dynamic> projectsJson = responseData['projects'];

            List<Projects> projects = projectsJson.map((json) {
              return Projects(
                project_id: json['project_id'],
                title: json['title'],
                desc: json['desc'],
                images: json['images'] != null ? json['images'] : 'https://eod-grss-ieee.com/uploads/science/1655561736_noimg_-_Copy.png',
                posted_from: json['posted_from'],
                client_firstname: json['client_firstname'],
                timeframe_start: json['timeframe_start'],
                liked: json['liked'],
                numbers_of_likes: json['numbers_of_likes'],
                project_type_id: json['project_type_id'],
                timeframe_end: json['timeframe_end'],
              );
            }).toList();

            print(projectsJson);
            print(projects);
            return projects;
          } else {
            throw Exception('Failed to load data from API: ${responseData['msg']}');
          }
        } else {
          throw Exception('Failed to load data from API');
        }

    } catch (e) {
      throw Exception('Error: $e');
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

            setState(() {
              firstname = profileData['firstname'] ?? '';
              secondname = profileData['lastname'] ?? '';
              email = profileData['email'] ?? '';
              profile_pic = profileData['profile_pic'] ?? '';
              phone = profileData['phone'] ?? '';
              language = profileData['language'] ?? '';
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
  @override
  void initState() {
    super.initState();
    _getusertype();
    _getUserProfile();
    numberofprojects();
    fetchProject();
    futureProjects = fetchProject() ;

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          NavigationHelper.navigateToNextPage(context, screenshotController);
        },
        backgroundColor: Color(0xFF4D8D6E), // Use the color 4D8D6E
        child: Icon(Icons.question_mark ,color: Colors.white,), // Use the support icon
        shape: CircleBorder(), // Make the button circular
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("$firstname Profile", style: TextStyle(color: Colors.black),),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.black,),

      ),
      body: NestedScrollView(
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
                            border: Border.all(color: Colors.grey.shade300, width: 5)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(300),
                          child: Image.asset('assets/images/profile.jpg'),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                     Text("$firstname", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                    SizedBox(height: 10,),
                     Text("$usertype", style: TextStyle(color: Colors.grey, fontSize: 16),),
                    SizedBox(height: 40),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text("${projectnumber.toString()}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Text("Projects", style: TextStyle(color: Colors.grey,),),
                                ],
                              ),
                               Column(
                                children: [
                                  Text("5", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  SizedBox(height: 5,),
                                  Text("Reviews", style: TextStyle(color: Colors.grey,),),
                                ],
                              ),

                            ]
                        )
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            )
          ];
        },
        body: DefaultTabController(
          length: 2,
          child: Column(
              children: [
                 Container(
                    child: TabBar(
                        labelColor: HexColor('4D8D6E'),
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: HexColor('4D8D6E'),
                        tabs: [
                          Tab(icon: Icon(Icons.task_alt_outlined,),),
                          Tab(icon: Icon(Icons.reviews_outlined,),),
                        ]
                    )
                ),
                Expanded(
                    child:  Container(
                        padding: EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                        child: TabBarView(
                            children: [
                        FutureBuilder<List<Projects>>(
                        future: futureProjects,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Column(
                                children: [
                                  SizedBox(height: 80,),       Center(child: CircularProgressIndicator()),SizedBox(height: 80,)
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                              // If projects list is empty, reset current page to 0 and refresh

                              return Text('No projects found.');
                            } else {
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return buildListproject( snapshot.data![index]);
                                },
                              );
                            }
                          },
                        ),

                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: reviewsitems2.length,
                                itemBuilder: (context, index) {
                                  return buildListReviews( reviewsitems2[index]);
                                },
                              ),
                            ]
                        )
                    ))

              ]
          ),
        ),
      ),



    );

  }
  Widget buildListproject(Projects project) {
    return GestureDetector(
      // onTap: (){Get.to(bidDetailsWorker());},
      child: Container(
        height: 330, // Adjust the height as needed
        width: 280,  // Adjust the width as needed
        margin: EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 13.0,vertical: 16),
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
            Container(
              width: 260,  // Adjust the width of the image container as needed
              height: 160.0, // Adjust the height of the image container as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: NetworkImage(project.images ?? 'assets/image/plumber.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        project.title != null ? project.title!.substring(0, project.title!.length < 12 ? project.title!.length : 12) : 'No Name',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(overflow: TextOverflow.ellipsis,
                            color: HexColor('131330'),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Spacer(),
                      Text(
                        'Current Bid :',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),SizedBox(width: 9,),
                      Text(
                        '30',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('4D8D6E'),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 4,),

                  Container(
                    child: Text(
                      project.desc ?? 'no description',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('#706F6F'),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  ,

                  SizedBox(height: 12,),
                  Row(
                    children: [
                      Text(
                        'By',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                      ),
                       Text(
                            ' ${project.client_firstname ?? 'Unknown'}',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('43745C'),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),


                      ),
Spacer(),
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                      ),
                      Text(
                        '${project.posted_from ?? 'N/A'} ',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListReviews(reviewsitems reviewsitems) {
    return GestureDetector(
      // onTap: (){Get.to(bidDetailsWorker());},
      child: Container(
        height: 330, // Adjust the height as needed
        width: 280,  // Adjust the width as needed
        margin: EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 13.0,vertical: 16),
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
            Container(
              width: 260,  // Adjust the width of the image container as needed
              height: 160.0, // Adjust the height of the image container as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: AssetImage(reviewsitems.imagePath ?? 'assets/image/plumber.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reviewsitems.itemName ?? 'No Name',
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
                        'Reviews :',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),SizedBox(width: 9,),
                      Text(
                        '${reviewsitems.bidAmount ?? 'N/A'}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.yellow[900],
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 4,),

                  Container(
                    child: Text(
                      reviewsitems.description ?? 'no description',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('#706F6F'),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  ,

                  SizedBox(height: 12,),
                  Row(
                    children: [
                      Text(
                        'By',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                      ),
                      Text(
                        ' ${reviewsitems.by ?? 'Unknown'}',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('43745C'),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),


                      ),
                      Spacer(),
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                      ),
                      Text(
                        '${reviewsitems.timeAgo ?? 'N/A'} ago',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('393B3E'),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),],
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


class items {
  final String imagePath;
  final String itemName;
  final String description;
  final String by;
  final String timeAgo;
  final String bidAmount;

  items({
    required this.imagePath,
    required this.itemName,
    required this.description,
    required this.by,
    required this.timeAgo,
    required this.bidAmount,
  });
}

class reviewsitems {
  final String imagePath;
  final String itemName;
  final String description;
  final String by;
  final String timeAgo;
  final String bidAmount;

  reviewsitems({
    required this.imagePath,
    required this.itemName,
    required this.description,
    required this.by,
    required this.timeAgo,
    required this.bidAmount,
  });
}
class Access {
  int user;
  String owner;
  String projectStatus;

  Access({
    required this.user,
    required this.owner,
    required this.projectStatus,
  });

  factory Access.fromJson(Map<String, dynamic> json) {
    return Access(
      user: json['user'],
      owner: json['owner'].toString(),
      projectStatus: json['project_status'],
    );
  }
}

class ClientData {
  int clientId;
  String firstname;
  String lastname;
  String profileImage;

  ClientData({
    required this.clientId,
    required this.firstname,
    required this.lastname,
    required this.profileImage,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      clientId: json['client_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      profileImage: json['profle_image'] ??
          'http://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
    );
  }
}

class ProjectData {
  final String firstname;
  final String lastname;
  final String email;
  final String profile_pic;
  final String phone;
  final String language;


  // Include the client data

  ProjectData({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.profile_pic,
    required this.language,
    r
  });


}
class Projects {
  final int project_id;
  final int numbers_of_likes;
  final String client_firstname;
  final String project_type_id;
  final String desc;
  final String timeframe_start;
  final String timeframe_end;
  final String posted_from;
  final String title;
  final String images;
  final String liked;


  Projects({
    required this.project_id,
    required this.numbers_of_likes,
    required this.client_firstname,
    required this.project_type_id,
    required this.desc,
    required this.timeframe_start,
    required this.title,
    required this.timeframe_end,
    required this.posted_from,
    required this.images,
    required this.liked,
  });

}
