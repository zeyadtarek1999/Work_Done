import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'components/colorsys.dart';

class portofolio extends StatefulWidget {
  final User ='zeyad';

  portofolio({Key? key}) : super(key: key);

  @override
  portofolioState createState() => portofolioState();
}

class portofolioState extends State<portofolio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorsys.lightGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colorsys.grey,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz, size: 25, color: Colorsys.grey,), onPressed: () {  },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                  color: Colors.white
              ),
              child: Column(
                children: <Widget>[
                  Hero(
                    transitionOnUserGestures: true,
                    tag: 'ahmed',
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jgp'),
                      maxRadius: 58,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text('Ahmed', style: TextStyle(
                      fontSize: 30,
                      color: Colorsys.black,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 5,),
                  Text('plumber', style: TextStyle(
                      fontSize: 15,
                      color: Colorsys.grey
                  ),),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: makeFollowWidgets(
                            count: 4,
                            name: "jobs"
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
            SizedBox(height: 16,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: Colors.grey,
                        ))
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Colletion", style: TextStyle(
                                color: Colorsys.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),),
                            Container(
                              width: 50,
                              padding: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(
                                      color: Colorsys.orange,
                                      width: 3
                                  ))
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  makeColloction()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeColloction() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20),
            height: 320,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                return AspectRatio(
                  aspectRatio: 1.2/1,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            margin: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/images/plumber.jpg'),
                                    fit: BoxFit.cover
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.orange
                            ),
                            child: Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                          height: 90,
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('water flow'.toUpperCase(), style: TextStyle(
                                                  color: HexColor('#022C43'),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 19
                                              ),),
                                              SizedBox(height: 5,),
                                              Text('"Expertly resolved plumbing issues, ensuring smooth water flow and leak-free systems. Satisfied clients, hassle-free homes', style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w300
                                              ),)
                                            ],
                                          )
                                      ),
                                    ),
                                  ),
                                ]
                            )
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Container(
                      //   height: 32,
                      //   margin: EdgeInsets.only(right: 20),
                      //   child: ListView.builder(
                      //     scrollDirection: Axis.horizontal,
                      //     itemCount: 2,
                      //     itemBuilder: (context, tagIndex) => Container(
                      //       margin: EdgeInsets.only(right: 10),
                      //       padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      //       decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(5),
                      //           color: Colorsys.grey300
                      //       ),
                      //       child: Center(
                      //         child: Text('2', style: TextStyle(
                      //         ),),
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget makeFollowWidgets({count, name}) {
    return Row(
      children: <Widget>[
        Text(count.toString(),
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: HexColor('#022C43')
          ),
        ),
        SizedBox(width: 5,),
        Text(name,
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: HexColor('#022C43')
          ),
        ),
      ],
    );
  }

  // Widget makeActionButtons() {
  //   return Transform.translate(
  //     offset: Offset(0, 20),
  //     child: Container(
  //       height: 65,
  //       padding: EdgeInsets.all(10),
  //       margin: EdgeInsets.symmetric(horizontal: 50),
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(5),
  //           color: Colors.white,
  //           boxShadow: [
  //             BoxShadow(
  //                 blurRadius: 20,
  //                 offset: Offset(0, 10)
  //             )
  //           ]
  //       ),
  //       child: Row(
  //         children: <Widget>[
  //           Expanded(
  //             child: MaterialButton(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(5.0),
  //                 ),
  //                 height: double.infinity,
  //                 elevation: 0,
  //                 onPressed: () {
  //                 },
  //                 color: Colorsys.orange,
  //                 child: Text("Message", style: TextStyle(
  //                   color: Colors.white,
  //                 ),)
  //             ),
  //           ),
  //           Expanded(
  //             child: MaterialButton(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(5.0),
  //                 ),
  //                 height: double.infinity,
  //                 elevation: 0,
  //                 onPressed: () {
  //                 },
  //                 color: Colors.transparent,
  //                 child: Text("Message", style: TextStyle(
  //                     color: Colorsys.black,
  //                     fontWeight: FontWeight.w400
  //                 ),)
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}