import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../model/mediaquery.dart';
import '../Bid Details/Bid details ClientPost.dart';
import '../view profile screens/Client profile view.dart';

class projectsClient extends StatefulWidget {
  projectsClient({super.key});

  @override
  State<projectsClient> createState() => _projectsClientState();
}

class _projectsClientState extends State<projectsClient> {
   List<String> filteredItems = [];
   List<String> items = [
     'Wall Paint',
     'Wall Paint',
     'Item 3',
     'Item 4',
   ];
   void filterItems(String query) {
     setState(() {
       // Filter items based on the query
       filteredItems = items.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
     });
   }
   TextEditingController _searchController = TextEditingController();

   @override
   void initState() {
     super.initState();

     // Initialize the filtered items with all items initially
     filteredItems = List.from(items);
   }
   @override
   void dispose() {
     _searchController.dispose();
     super.dispose();
   }

@override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Change this color to the desired one
      statusBarIconBrightness: Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: HexColor('EAEAEE'),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(170.0), // Adjust the height as needed
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Adjust the offset for desired shadow direction
              ),
            ],
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 125, // Height for the "Project" container
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        'Projects',
                        style: GoogleFonts.encodeSans(
                          textStyle: TextStyle(color: HexColor('070821'), fontSize: 22,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 330,

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: HexColor('E4E3F3'),
                      width: 1// Set the border color here
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30)
                    ),
                    color: Colors.white,
                  ),
                  child: TabBar(
                    tabs: [
                      Tab(
                        text: 'Current',
                      ),
                      Tab(
                        text: 'Past',
                      )
                    ],
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: HexColor('#4D8D6E'), // Hex color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 3, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset: Offset(4, 5), // Offset in the x and y direction
                        ),
                      ],
                    ),

                    labelStyle: GoogleFonts.encodeSans(
                      textStyle: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w600),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
        Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(30), // Circular border radius
          ),
          child: TextField(
            controller: _searchController,

            decoration: InputDecoration(
              hintText: 'Search', // Hint text
              border: InputBorder.none, // Remove underline
              prefixIcon: Icon(Icons.search), // Search icon
            ),
            onChanged: filterItems, // Call filterItems when the text changes

          ),),
        ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    // Replace with the actual length of your data list
                    itemBuilder: (context, index) {
                      return buildListItem(filteredItems[index]);
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SvgPicture.asset(
                    'assets/images/nothing.svg',
                    width: 100.0, // Set the width you want
                    height: 100.0, // Set the height you want
                  ),
                ),SizedBox(height: 20,),
                  Text('No Projects yet',style: GoogleFonts.encodeSans(
                    textStyle: TextStyle(color: HexColor('BBC3CE'), fontSize: 18,fontWeight: FontWeight.normal),
                  ),),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Container(
                      width: ScreenUtil.buttonscreenwidth,
                      height: 45,
                      margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 1.0),
                      child: ElevatedButton(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#4D8D6E'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            // Adjust the value to change the corner radius
                            side: BorderSide(
                                width:
                                130 // Adjust the value to change the width of the narrow edge
                            ),
                          ),
                        ),
                        child: Text(
                          'Find a Project',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

              ],),
            )
            ,
          ],
        ),

      ),
    );
  }  Widget buildListItem(String itemName) {
     return Container(
       margin: EdgeInsets.all(16.0),
       padding: EdgeInsets.all(25.0),
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
             width: double.infinity,
             height: 170.0,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(20.0),
               image: DecorationImage(
                 image: AssetImage('assets/images/testimage.jpg'), // Replace with your image URL
                 fit: BoxFit.cover,
               ),
             ),
           ),
           SizedBox(height: 10.0),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 7.0),
             child: Column(
               children: [
                 Row(
                   children: [
                     Text(
                       itemName,
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
                       'Start Bid',
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
                 SizedBox(height: 6),
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
                     SizedBox(width: 5),
                     Container(
                       height: 20,
                       width: 50,
                       padding: EdgeInsets.zero,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(6),
                       ),
                       child: TextButton(
                         onPressed: () {
                           Get.to(ProfilePageClient());
                         },
                         style: TextButton.styleFrom(
                           fixedSize: Size(50, 30), // Adjust the size as needed
                           padding: EdgeInsets.zero,
                         ),
                         child: Text(
                           'John',
                           style: TextStyle(
                             color: HexColor('4D8D6E'),
                             fontSize: 15,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     ),
                     Spacer(),
                     Text(
                       '50\$',
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
                 SizedBox(height: 6),
                 Row(
                   children: [
                     Icon(
                       Icons.access_time_rounded,
                       size: 18,
                     ),
                     SizedBox(width: 5),
                     Text(
                       '22 min',
                       style: GoogleFonts.openSans(
                         textStyle: TextStyle(
                           color: HexColor('393B3E'),
                           fontSize: 14,
                           fontWeight: FontWeight.w400,
                         ),
                       ),
                     ),
                     SizedBox(width: 2),
                     Text(
                       'ago',
                       style: GoogleFonts.openSans(
                         textStyle: TextStyle(
                           color: HexColor('393B3E'),
                           fontSize: 14,
                           fontWeight: FontWeight.w400,
                         ),
                       ),
                     ),
                     Spacer(),
                     Container(
                       width: 80,
                       height: 36,
                       decoration: BoxDecoration(
                         color: HexColor('4D8D6E'),
                         borderRadius: BorderRadius.circular(11),
                       ),
                       child: ElevatedButton(
                         onPressed: () {Get.to( bidDetailsClientPost());},
                         child: Text('Details'),
                         style: ElevatedButton.styleFrom(
                           primary: Colors.transparent, // Make the button background transparent
                           elevation: 0, // Remove button elevation
                           textStyle: TextStyle(color: Colors.white), // Set text color to white
                         ),
                       ),
                     )
                   ],
                 ),
               ],
             ),
           ),
         ],
       ),
     );
   }
}