import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../rive/presentatosn/tree_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Timer(Duration(seconds: 2), (){
      Get.offAll(()=>PlantScreen());
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
           body: Container(
             height: double.infinity,
              width: double.infinity,
             decoration: BoxDecoration(
               image: DecorationImage(image: AssetImage('assets/image/FucasImage.png'),
                 fit: BoxFit.cover,
               )
             ),
           ),
    );
  }
}
