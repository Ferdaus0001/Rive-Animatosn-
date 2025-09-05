import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:rive/rive.dart'; // Rive package
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ScreenUtil import
import 'package:rive_animation/splash_screen/splash_screen.dart'; // Fixed typo in path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveFile.initialize(); // Initialize Rive runtime
  runApp(
       const MyApp()
  //   DevicePreview(
  //   enabled: true,
  //   builder: (context) => const MyApp(),
  // ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Design screen size (width x height)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Responsive Rive App',
          home: SplashScreen(),
        );
      },
    );
  }
}
