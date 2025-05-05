import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaron/view/screens/dashboard.dart';
import 'package:zaron/view/widgets/buttons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double height;
  late double width;
  final userController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showOtpField = false;
  bool showPasswordField = false;
  bool showLoginPasswordField = false;
  String? savedUserId;

  @override
  void initState() {
    super.initState();
    checkSavedUser();
  }

  Future<void> checkSavedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUserId = prefs.getString("user_id");

    if (savedUserId != null) {
      setState(() {
        userController.text = savedUserId!;
        showLoginPasswordField = true;
      });
    }
  }

  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_id", userId);
  }

  Future<void> checkUserStatus(BuildContext context) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final message = {"user_id": userController.text};
    final url = 'https://demo.zaron.in:8181/ci4/api/login';
    final body = jsonEncode(message);

    try {
      final response = await ioClient.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        setState(() {
          showOtpField = true;
        });
      } else {
        setState(() {
          showLoginPasswordField = true;
        });
      }
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  /// Otp method
  Future<void> verifyOtp(BuildContext context) async {
    setState(() {
      showOtpField = false;
      showPasswordField = true;
    });
  }

  /// User can set the Password and post that to db  //
  Future<void> resetPassword(BuildContext context) async {
    if (passwordController.text == confirmPasswordController.text) {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      IOClient ioClient = IOClient(client);

      final message = {
        "user_id": userController.text,
        "password": passwordController.text
      };

      final url = 'https://demo.zaron.in:8181/ci4/api/validcustomer';
      final body = jsonEncode(message);

      try {
        final response = await ioClient.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          await saveUserId(userController.text);
          Get.offAll(() => Dashboard());
        } else {
          showErrorDialog(context, "Failed to reset password");
        }
      } catch (e) {
        showErrorDialog(context, e.toString());
      }
    } else {
      showErrorDialog(context, "Passwords do not match");
    }
  }

  /// Validate login to check the user and password retun success //
  Future<void> validateLogin(BuildContext context) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final Map<String, dynamic> message = {
      "user_id": userController.text.trim(),
      "password": passwordController.text.trim()
    };

    final String url = 'https://demo.zaron.in:8181/ci4/api/validlogin';
    final String body = jsonEncode(message);

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: body,
      );

      print("Request Sent: $body");
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Extracting the actual message object
        final Map<String, dynamic>? messageData = jsonResponse["message"];

        if (messageData != null && messageData["success"] == true) {
          Get.offAll(() => Dashboard());
        } else {
          showErrorDialog(
              context, messageData?["message"] ?? "Invalid credentials");
        }
      } else {
        showErrorDialog(context, "Failed to login. Please try again.");
      }
    } catch (e) {
      showErrorDialog(context, "Error: $e");
    }
  }

  /// Clear the Shared prefernees //
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if (width <= 450) {
        return _smallBuildLayout();
      } else {
        return Text("Please make sure your device is in portrait view");
      }
    });
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            SizedBox(height: 30.h),
            Container(
              height: height / 4.h,
              width: width / 2.w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/login.png"),
                      fit: BoxFit.cover)),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 15.1.w, right: 15.1.w),
              child: TextFormField(
                  controller: userController,
                  decoration: InputDecoration(
                      labelText: "User Id",
                      labelStyle: GoogleFonts.figtree(
                          textStyle: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey)),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10))))),
            ),
            SizedBox(
              height: 10.h,
            ),
            if (showOtpField)
              Padding(
                padding: EdgeInsets.only(left: 15.1.w, right: 15.1.w),
                child: TextFormField(
                  controller: otpController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: "Enter OTP",
                      labelStyle: GoogleFonts.figtree(
                          textStyle: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey))),
                ),
              ),
            if (showPasswordField)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.1.w, right: 15.1.w),
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          labelText: "New Password"),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.1.w, right: 15.1.w),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          labelText: "Confirm Password"),
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            if (showLoginPasswordField)
              Padding(
                padding: EdgeInsets.only(left: 15.1.w, right: 15.1.w),
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: "Password",
                  ),
                  obscureText: true,
                ),
              ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () {
                if (showLoginPasswordField) {
                  validateLogin(context);
                } else if (showPasswordField) {
                  resetPassword(context);
                } else if (showOtpField) {
                  verifyOtp(context);
                } else {
                  checkUserStatus(context);
                }
              },
              child: Buttons(
                text: "Submit",
                weight: FontWeight.w500,
                color: Colors.blueGrey,
                height: height / 18.h,
                width: width / 2.5.w,
                radius: BorderRadius.circular(10.r),
              ),
            ),

            // ElevatedButton(onPressed: () {
            //   clearSharedPreferences();
            // }, child: Text("Clear"))
          ],
        ),
      ),
    );
  }
}
