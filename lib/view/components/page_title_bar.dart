import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class PageTitleBar extends StatelessWidget {
  const PageTitleBar({ Key? key,required this.title }) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 260.0),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 4,
        decoration:  BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top:16.0),
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Color(0xfff575861)
            ),
          ),
        ),
      ),
    );
  }
}