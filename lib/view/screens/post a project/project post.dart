import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';

import '../../widgets/rounded_button.dart';

class projectPost extends StatefulWidget {
   projectPost({super.key});

  @override
  State<projectPost> createState() => _projectPostState();
}

class _projectPostState extends State<projectPost> {
  double _startValue = 0;
  double _endValue = 10;
  List<String> buttonLabels = [
    '1-2',
    '1-4',
    '1-6',
    '1-7',
    '1-10',
    '1-15',
    '1-20',
    '1-25',
    '1-30',

  ];
  String selectedButtonText = '0-1';

  double _sliderValue = 1;



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('ECECEC'),
      // Change this color to the desired one
      statusBarIconBrightness:
      Brightness.dark, // Change the status bar icons' color (dark or light)
    ));
    return Scaffold(
      backgroundColor: HexColor('ECECEC'),
      appBar: AppBar(
        backgroundColor: HexColor('ECECEC'),
        leading: IconButton(onPressed: (){
          Get.back();

        },icon: Icon(Ionicons.arrow_back,size: 30,          color: HexColor('1A1D1E'),
        ),

        ),
        title: Text(
          'Post New Project',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: HexColor('1A1D1E'),
                fontSize: 22,
                fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0,left: 10,right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Upload Photo', style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  ),
                  SizedBox(width: 6,),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline, // "i" icon
                      color: Colors.red,
                      size: 22,// Red color
                    ),
                    onPressed: () {
                      // Show a Snackbar with the required text
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Upload photo is Required',
                            style: TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 7,
              ),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), color: Colors.white),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Upload Here', style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: HexColor('4D8D6E'),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    ),Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                      child: Center(
                        child: Text('Please upload clear photos of the project (from all sides, if applicable) to help the worker place an accurate bid!', style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: HexColor('888C8A'),
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(
                      Icons.file_upload,
                      color: HexColor('4D8D6E'),
                      size: 30,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14,),
              Row(
                children: [
                  Text('Title of Project', style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  ),
                  SizedBox(width: 6,),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline, // "i" icon
                      color: Colors.red,
                      size: 22,// Red color
                    ),
                    onPressed: () {
                      // Show a Snackbar with the required text
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Title is Required',
                            style: TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),

                ],
              ),
              SizedBox(height: 8,),
              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Write a Project Title',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                    border: InputBorder.none, // Remove the underline
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0), // Adjust padding
                  ),
                ),
              ),
              SizedBox(height: 14,),
              Text('Project Type', style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    color: HexColor('1A1D1E'),
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
              ),
              SizedBox(height: 8,),

              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Select Project Type',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                          ),
                      ),
                      Spacer(),
                      DropdownButton<String>(
                        underline: SizedBox(), // Remove the underline
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: <String>[
                          'Option 1',
                          'Option 2',
                          'Option 3',
                          // Add your job types here
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Handle dropdown value change
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14,),

              Row(
                children: [
                  Text('Preferred Time Frame', style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  ),
                  SizedBox(width: 6,),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline, // "i" icon
                      color: Colors.red,
                      size: 22,// Red color
                    ),
                    onPressed: () {
                      // Show a Snackbar with the required text
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Time frame is Required',
                            style: TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),

                ],
              ),
          // RowScrollFastor(  children:
          // List.generate(
          //   buttonLabels.length,
          //       (index) {
          //     return Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 7), // Adjust the value for the desired space
          //       child: ElevatedButton(
          //         onPressed: () {
          //           setState(() {
          //             selectedButtonText = buttonLabels[index];
          //           });
          //         },
          //         style: ElevatedButton.styleFrom(
          //           primary: selectedButtonText == buttonLabels[index]
          //               ? HexColor('4D8D6E')
          //               : Colors.white,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(30.0),
          //           ),
          //         ),
          //         child: Text(
          //           buttonLabels[index],
          //           style: TextStyle(color:selectedButtonText == buttonLabels[index]? Colors.white : Colors.grey[700],
          //           ),
          //         ),
          //       ),
          //     );
          //
          //   },
          //
          // ),
          // ),
          //     SizedBox(height: 6),
          //     Row(
          //       children: [
          //         Text(  'Project period (Range): ', style: GoogleFonts.poppins(
          //           textStyle: TextStyle(
          //               color: HexColor('605E5E'),
          //               fontSize: 15,
          //               fontWeight: FontWeight.w500),
          //         ),
          //         ),
          //         Text(   '${selectedButtonText } days', style: GoogleFonts.poppins(
          //           textStyle: TextStyle(
          //               color: HexColor('4D8D6E'),
          //               fontSize: 16,
          //               fontWeight: FontWeight.w500),
          //         ),
          //         ),
          //
          //       ],
          //     ),
          //     SizedBox(height: 14,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RangeSlider(
                    values: RangeValues(_startValue, _endValue),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _startValue = values.start;
                        _endValue = values.end;
                      });
                    },
                    min: 0,
                    max: 100,
                    divisions: 100, // Divisions set to 1 for two thumbs
                    labels: RangeLabels(
                      _startValue.toInt().toString(),
                      _endValue.toInt().toString()
                    ),
                    activeColor: Color(0xFF4D8D6E),
                    inactiveColor: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Project period (Range): ',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_startValue.toInt()} - ${_endValue.toInt()} days',
                        style: TextStyle(
                          color: Color(0xFF4D8D6E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          SizedBox(height: 20),
              Row(
                children: [
                  Text('Job Description', style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: HexColor('1A1D1E'),
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),

                  ),
                  SizedBox(width: 6,),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline, // "i" icon
                      color: Colors.red,
                      size: 22,// Red color
                    ),
                    onPressed: () {
                      // Show a Snackbar with the required text
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(

                            'Job Description is Required',
                            style: TextStyle(color: Colors.white), // Red text color
                          ),
                        ),
                      );
                    },
                  ),

                ],
              ),
              SizedBox(height: 8,),

              Container(
                height: 100,
                width: double.infinity, // Set the desired width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0,),
                  child: TextFormField(
                    maxLines: null, // Allows the text to take up multiple lines
                    decoration: InputDecoration(
                      hintText: 'Please write a detailed description to help the worker place an accurate bid!',
                      border: InputBorder.none,
                      hintMaxLines: 3, // Allows the hint text to take up multiple lines
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              )
,
              SizedBox(height: 14,),
              Center(
                child: RoundedButton(
                  text: 'Done',
                  press: ()  {

                  },
                ),
              ),

              SizedBox(height: 14,),



            ]),
        ),







        ),

    );
  }
}
