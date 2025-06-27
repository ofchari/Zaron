import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaron/view/screens/dashboard.dart';

import '../universal_api/api&key.dart';
import 'global_user/global_user.dart';

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
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
    final url = '$apiUrl/login';
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
        "password": passwordController.text,
      };

      final url = '$apiUrl/validcustomer';
      final body = jsonEncode(message);

      try {
        final response = await ioClient.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          UserSession().userId = userController.text;
          await saveUserId(userController.text);
          Get.offAll(() => Dashboard(userid: userController.text));
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

  /// Validate login to check the user and password return success //
  Future<void> validateLogin(BuildContext context) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final Map<String, dynamic> message = {
      "user_id": userController.text.trim(),
      "password": passwordController.text.trim(),
    };

    final String url = '$apiUrl/validlogin';
    final String body = jsonEncode(message);

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
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
          UserSession().userId = userController.text;
          Get.offAll(() => Dashboard(userid: userController.text));
        } else {
          showErrorDialog(
            context,
            messageData?["message"] ?? "Invalid credentials",
          );
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
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[100]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            width: width.w,
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Container(
                  height: height / 3.5.h,
                  width: width / 1.8.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/login.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 30.h,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: userController,
                        decoration: InputDecoration(
                          labelText: "User Id",
                          labelStyle: GoogleFonts.figtree(
                            textStyle: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.blueGrey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(color: Colors.blueGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.blueGrey.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      if (showOtpField) ...[
                        SizedBox(height: 15.h),
                        TextFormField(
                          controller: otpController,
                          decoration: InputDecoration(
                            labelText: "Enter OTP",
                            labelStyle: GoogleFonts.figtree(
                              textStyle: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_clock_outlined,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                        ),
                      ],
                      if (showPasswordField) ...[
                        SizedBox(height: 15.h),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "New Password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 15.h),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ],
                      if (showLoginPasswordField) ...[
                        SizedBox(height: 15.h),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ],
                      SizedBox(height: 25.h),
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
                        child: Container(
                          height: height / 15.h,
                          width: width / 2.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange[600]!,
                                Colors.orange[300]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Submit",
                              style: GoogleFonts.figtree(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
