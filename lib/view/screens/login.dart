import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/screens/dashboard.dart';
import 'dart:convert';
import 'package:zaron/view/widgets/buttons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double height;
  late double width;
  String idValue = "Loading...";
  final userController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiUrl = 'http://demo.zaron.in:8181/ci4/api';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          idValue = jsonResponse.isNotEmpty ? jsonResponse[0]['id'].toString() : "No Data";
        });
        print(response.body);
        print(response.statusCode);
      } else {
        setState(() {
          idValue = "Failed to load data";
        });
      }
    } catch (e) {
      setState(() {
        idValue = "Error: $e";
      });
    }
  }

                /// Post method for login ///
  Future<void> addMaterial(BuildContext context) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    // final headers = {
    //   'Authorization': 'Basic ${base64Encode(utf8.encode(apiKey))}',
    //   'Content-Type': 'application/json',
    // };

    final message = {
        "user_id" : userController.text
    };
    print(message);

    final url = 'http://demo.zaron.in:8181/ci4/api/login';
    final body = jsonEncode(message);
    try {
      final response = await ioClient.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Material added",
          "Successfully",
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.to(Dashboard());
        // fetchMaterials();
      } else {
        String message = 'Request failed with status: ${response.statusCode}';
        if (response.statusCode == 417) {
          final serverMessages = json.decode(response.body)['_server_messages'];
          message = serverMessages ?? message;
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(response.statusCode == 417 ? 'Message' : 'Error'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
                  image: DecorationImage(image: AssetImage("assets/login.png"), fit: BoxFit.cover)),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 15.1.w, right: 15.1.w),
              child: TextFormField(
                controller: userController,
                  decoration: InputDecoration(
                      labelText: "User Id",
                      labelStyle: GoogleFonts.figtree(
                          textStyle:
                          TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w500, color: Colors.grey)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))))),
            ),
            SizedBox(height: 10.h),
            Text("ID: $idValue", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: (){
                addMaterial(context);
              },
              child: Buttons(
                  text: "Submit",
                  weight: FontWeight.w500,
                  color: Colors.blueGrey,
                  height: height / 18,
                  width: width / 2.5,
                  radius: BorderRadius.circular(15.r)),
            )
          ],
        ),
      ),
    );
  }
}
