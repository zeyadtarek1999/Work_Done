import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class YourShimmerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            SizedBox(height: 8.0),
            Container(
              width: 150.0,
              height: 13.0,
              color: Colors.white,
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              height: 30.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
