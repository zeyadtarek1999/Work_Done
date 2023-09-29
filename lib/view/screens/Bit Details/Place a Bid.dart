import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

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
            height: 240, // Set the height as needed
            decoration: BoxDecoration(
              color: HexColor('4D8D6E'), // Color
              borderRadius: BorderRadius.circular(30.0), // Circular radius
            ),child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text('You are about to place a bid for ',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: HexColor('FFFFFF'),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text('Design Mania ',style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    color: HexColor('FFFFFF'),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),
                    SizedBox(width: 4,),
                    Text('by @antonio',style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('FFFFFF'),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ),
                  ],


                ),
                SizedBox(height: 18,),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [

                      Text('You will receive ',style: GoogleFonts.openSans(
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






              ],
            )),
          ),
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0), // Bottom left radius
                    bottomRight: Radius.circular(12.0), // Bottom right radius
                  ),
                  color: Colors.white, // Container background color

                ),
                child: Row(
                  children: [
                    Text('Total',style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: HexColor('#454545'),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                    Spacer(),
                Text(  '$total',style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    color: HexColor('#454545'),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),),
                    SizedBox(width: 5,),
                    Icon(Icons.attach_money,size: 17,color: Colors.black,),

                  ],
                ),
              ),
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
