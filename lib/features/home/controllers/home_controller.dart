import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  void navigateTo(int index) => currentIndex.value = index;
}
