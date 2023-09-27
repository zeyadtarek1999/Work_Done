import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../model/mediaquery.dart';

class MyDrawerworker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(width: 250,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(height: 240,
            child: DrawerHeader(
              decoration: BoxDecoration(

                color: HexColor('#4D8D6E'),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HexColor('#FFFFFF'),
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profileimage.png',
                          // Replace with the image URL
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: HexColor('#EFCE4A'),
                        size: 28,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '4.2',
                        style: TextStyle(
                            color: HexColor('#FFFFFF'),
                            fontSize: 18),
                      )
                    ],
                  ),SizedBox(height: 3,),
                  Text(
                    'My Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Add your logic here for when the first item is tapped
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Add your logic here for when the second item is tapped
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}