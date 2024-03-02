import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:workdone/view/screens/Screens_layout/layoutWorker.dart';
import 'package:workdone/view/screens/Screens_layout/layoutclient.dart';

class showcaseWorker extends StatelessWidget {
  const showcaseWorker({super.key});

  @override
  Widget build(BuildContext context) {

    return ShowCaseWidget(
      autoPlay: true,
      autoPlayDelay: Duration(seconds:3),
      builder: Builder(
          builder : (context)=> layoutworker(showCase: true,)
      ),
    );
  }
}
