import 'package:get/get.dart';

class AppController extends GetxController {
  var currentIndex = 0.obs; // Observable to keep track of the current index

  void changePage(int index) {
    currentIndex.value = index;
  }
}
