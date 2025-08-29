import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:rive/rive.dart'; // Import Rive package

import 'package:rive_animation/splash_screen/splash_screen.dart'; // Fixed typo in path

void main() async {
  // Ensure widgets are initialized and Rive is set up
  WidgetsFlutterBinding.ensureInitialized();
  await RiveFile.initialize(); // Initialize Rive runtime
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:   SplashScreen(),
    );
  }
}