import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';

class showcaseClient extends StatelessWidget {
  const showcaseClient({super.key});

  @override
  Widget build(BuildContext context) {

    return ShowCaseWidget(
      autoPlay: true,
      autoPlayDelay: Duration(seconds:3),
      builder: Builder(
          builder : (context)=> layoutclient(showCase: true,)
      ),
    );
  }
}
