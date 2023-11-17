import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../Bid Details/Bid details Worker.dart';



class ProfilePageClient extends StatefulWidget {
  const ProfilePageClient({ Key? key }) : super(key: key);

  @override
  _ProfilePageClientState createState() => _ProfilePageClientState();
}

class _ProfilePageClientState extends State<ProfilePageClient> {

  List<String> posts = [
    'assets/images/plumber.jpg',
    'assets/images/testimage.jpg',
    ];
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

  List<items> Newprojectitems = [
    items(
      imagePath: 'assets/images/testimage.jpg',
      itemName: 'Wall Painting',
      description: 'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
      by: 'John',
      timeAgo: '22 min',
      bidAmount: '50\$',
    ),
    items(
      imagePath: 'assets/images/pluming.jpg',
      itemName: 'Plumbing',
      description: 'Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.',
      by: 'Yousef',
      timeAgo: '30 min',
      bidAmount: '60\$',
    ),
    // Add more data items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("John's Profile", style: TextStyle(color: Colors.black),),
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
                     Text("John", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                    SizedBox(height: 10,),
                     Text("Client", style: TextStyle(color: Colors.grey, fontSize: 16),),
                    SizedBox(height: 40),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text("8", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: Newprojectitems.length,
                                itemBuilder: (context, index) {
                                  return buildListproject( Newprojectitems[index]);
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
  Widget buildListproject(items item) {
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
                  image: AssetImage(item.imagePath ?? 'assets/image/plumber.jpg'),
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
                        item.itemName ?? 'No Name',
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
                        '${item.bidAmount ?? 'N/A'}',
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
                      item.description ?? 'no description',
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
                            ' ${item.by ?? 'Unknown'}',
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
                        '${item.timeAgo ?? 'N/A'} ago',
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