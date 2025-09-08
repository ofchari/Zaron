import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/Get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:zaron/view/screens/controller/acessories_get_controller.dart';
import 'package:zaron/view/screens/controller/aluminum_get_controller.dart';
import 'package:zaron/view/screens/controller/cuttolength_controller.dart';
import 'package:zaron/view/screens/controller/decking_get_controller.dart';
import 'package:zaron/view/screens/controller/ironsteel_get_controller.dart';
import 'package:zaron/view/screens/controller/linear_sheet_get_controller.dart';
import 'package:zaron/view/screens/controller/polycarbonate_get_controller.dart';
import 'package:zaron/view/screens/controller/profile_ridge_get_controller.dart';
import 'package:zaron/view/screens/controller/purlin_get_controller.dart';
import 'package:zaron/view/screens/controller/roll_sheet_get_controller.dart';
import 'package:zaron/view/screens/controller/screw_get_controller.dart';
import 'package:zaron/view/screens/controller/tilesheet_get_controller.dart';
import 'package:zaron/view/screens/controller/upvc_accessories_get_controller.dart';
import 'package:zaron/view/screens/controller/upvc_get_controller.dart';
import 'package:zaron/view/screens/entry.dart';

void main() async {
  Get.put(ScrewController());
  Get.put(PolycarbonateController());
  Get.put(UpvcTilesController());
  Get.put(IronSteelController());
  Get.put(CutToLengthSheetController());
  Get.put(DeckingSheetsController());
  Get.put(AluminumController());
  Get.put(TileSheetController());
  Get.put(LinerSheetController());
  Get.put(PurlinController());
  Get.put(AccessoriesController());
  Get.put(UpvcAccessoriesController());
  Get.put(ProfileRidgeAndArchController());
  Get.put(RollSheetController());
  await Hive.initFlutter();
  await Hive.openBox('accessories_products'); // Open a box without model
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
          home: AnimatedSplashScreen(
              splash: Image.asset("assets/login.png"),
              splashTransition: SplashTransition.fadeTransition,
              splashIconSize: 200,
              duration: 2000,
              nextScreen: Entry()),
        );
      },
    );
  }
}
