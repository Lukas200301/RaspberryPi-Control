import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/home/views/home_view.dart';
import '../features/home/bindings/home_binding.dart';

/// App Pages - GetX route configuration
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
