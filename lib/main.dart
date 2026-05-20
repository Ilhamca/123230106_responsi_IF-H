// ============================================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/detail/blog_detail_screen.dart';
import 'services/controllers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6FED)),
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          transition: Transition.rightToLeft,
        ),

        GetPage(
          name: '/main',
          page: () => const MainScreen(),
          binding: MainBinding(),
          transition: Transition.fadeIn,
        ),

        GetPage(
          name: '/detail',
          page: () => const BlogDetailScreen(),
          binding: DetailBinding(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainNavController>(MainNavController(), permanent: true);

    Get.lazyPut<StoreController>(() => StoreController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(() => DetailController(), fenix: true);
  }
}
