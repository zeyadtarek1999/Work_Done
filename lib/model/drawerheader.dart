import 'package:flutter/material.dart';

class myheaderdrawer extends StatefulWidget {
  const myheaderdrawer({super.key});

  @override
  State<myheaderdrawer> createState() => _myheaderdrawerState();
}

class _myheaderdrawerState extends State<myheaderdrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[700],
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 20),
      child:
      Column(
        children: [

          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle
                  ,
              image: DecorationImage(
                image: AssetImage('assets/icon/profile.svg')
              )
            ),
          ),
          Text('zeyadtarek', style: TextStyle(color:Colors.white,fontSize: 20 ),),
          Text('email'),
        ],
      ),
    );
  }
}
