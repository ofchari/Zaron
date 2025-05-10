import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:zaron/view/screens/new_enquirys/gl_gutter.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 844),
      builder: (context, child) {
        return GetMaterialApp(
            title: 'Zaron',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: GIGlutter(data: {})

            // AnimatedSplashScreen(
            //     splash: Image.asset("assets/login.png"),
            //     splashTransition: SplashTransition.fadeTransition,
            //     splashIconSize: 200,
            //     duration: 2000,
            //     nextScreen: Entry()),
            );
      },
    );
  }
}
