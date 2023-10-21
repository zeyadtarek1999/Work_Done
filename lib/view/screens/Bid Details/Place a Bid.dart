import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../view profile screens/Client profile view.dart';

class Placebid extends StatefulWidget {
  const Placebid({super.key});

  @override
  State<Placebid> createState() => _PlacebidState();
}

class _PlacebidState extends State<Placebid> {
  TextEditingController receive = TextEditingController();
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    receive.addListener(updateTotal);
  }

  void updateTotal() {
    double value1 = double.tryParse(receive.text) ?? 0.0;
    double value2 = 10.0; // You can change this value as needed
    setState(() {
      total = value1 + value2;
    });
  }
  @override
  void dispose() {
    receive.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Place A Bid',style: GoogleFonts.roboto(
          textStyle: TextStyle(
            color: HexColor('454545'),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),),
        centerTitle: true,
        leading: IconButton(onPressed: (){Get.back();},icon: Icon(Icons.arrow_back_sharp ,color: Colors.black,size: 24,),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

          Padding(
            padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
            child: Container(
            width: double.infinity,
            height: 260, // Set the height as needed
            decoration: BoxDecoration(
              color: HexColor('4D8D6E'), // Color
              borderRadius: BorderRadius.circular(30.0), // Circular radius
            ),child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You are about to place a bid for ',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: HexColor('FFFFFF'),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Wall Painting ',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: HexColor('FFFFFF'),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Row(
                            children: [
                              Text(
                                'by',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: HexColor('FFFFFF'),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                height: 30,
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
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
                  child: Text('Enter your bid',style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('FFFFFF'),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ),
                SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // White background color
                      borderRadius: BorderRadius.circular(12.0), // Circular radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
                      child: TextFormField(
                        controller: receive,
                        keyboardType: TextInputType.number,

                        decoration: InputDecoration(

                          hintText: '1', // Hint text
                          hintStyle: TextStyle(color: Colors.grey), // Hint text color
                          suffixIcon: Icon(Icons.attach_money), // Suffix icon (Dollar sign)
                          border: InputBorder.none, // Remove underline
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 8),
                  child: Row(
                    children: [

                      Text('Service fee ',style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('FFFFFF'),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      ),
                      Container(
                        width: 20, // Set the desired width
                        height: 30, // Set the desired height
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Make the container circular
                          color: HexColor('4D8D6E'), // Set the background color
                        ),
                        child: IconButton(
                          iconSize: 17, // Set the desired icon size
                          icon: Icon(Icons.info_outline, color: Colors.white), // Use the 'info' icon
                          onPressed: () {
                            // Show the dialog when the icon is pressed
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Information'),
                                  content: Text('information.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: HexColor('4D8D6E'), // Set the 'Close' button color
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
,
                      Spacer(),
                  Text('10',style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('FFFFFF'),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                    Icon(Icons.attach_money,size: 17,color: Colors.white,),

                    ],

                  ),
                )
,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [

                      Text('Total ',style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('FFFFFF'),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      ),
                      Spacer(),
                      Text('3',style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          color: HexColor('FFFFFF'),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ),

                      Icon(Icons.attach_money,size: 17,color: Colors.white,),

                    ],

                  ),
                ),





              ],
            )),
          ),
      SizedBox(height: 10,),
      Center(
        child: Text('(What you will recieve) ',style: GoogleFonts.openSans(
          textStyle: TextStyle(
            color: HexColor('9A9D9C'),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),),
      ),

            Padding(
              padding: const EdgeInsets.only(top: 150,left: 25,right: 25),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HexColor('4D8D6E'),
                  borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                ),
                child: InkWell(
                  onTap: () {
                    Get.back();
                    // Handle button tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'Add Bid',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )

          ]),
      ),


    );
  }
}
