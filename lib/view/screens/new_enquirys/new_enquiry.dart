import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/screens/new_enquirys/accessories.dart';
import 'package:zaron/view/screens/new_enquirys/iron_steels.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';


class NewEnquiry extends StatefulWidget {
  const NewEnquiry({super.key});

  @override
  State<NewEnquiry> createState() => _NewEnquiryState();
}

class _NewEnquiryState extends State<NewEnquiry> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('http://demo.zaron.in:8181/ci4/api/allcategories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Full Response: $data");

        if (data['message']['success']) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(
              (data['message']['message'] as List)
                  .where((item) => item["id"] != null && item["categories"] != null && item["cate_image"] != null)
                  .map(
                    (item) => {
                  "id": item["id"].toString(),
                  "name": item["categories"],
                  "imagePath": "http://demo.zaron.in:8181/${item["cate_image"]}",
                },
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }


  Future<void> mobiledocument(BuildContext context, String id, String categoryName) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final Data = {
      "values" : '',
      "id": id,
      "inputname": 'accessories_name',
      "product_value" : [],
      "category_value" : [],
    };

    final url = 'http://demo.zaron.in:8181/index.php/order/first_check_select_base_product';
    final body = jsonEncode(Data);

    print("🔵 [DEBUG] Sending POST request...");
    print("🔵 URL: $url");
    print("🔵 Headers: {\"Content-Type\": \"application/json\"}");
    print("🔵 Body: $body");

    try {
      final stopwatch = Stopwatch()..start(); // Start measuring response time
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      stopwatch.stop(); // Stop measuring

      print("🟢 [DEBUG] Response received in ${stopwatch.elapsedMilliseconds}ms");
      print("🟢 Status Code: ${response.statusCode}");

      if (response.body.isNotEmpty) {
        print("🟢 Response Body: ${response.body}");
      } else {
        print("🟡 [WARNING] Empty response body!");
      }

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print("✅ [SUCCESS] Parsed Response: $responseData");

          // Route based on the category name
          Widget nextPage = getCategoryPage(categoryName, responseData);
          Get.to(() => nextPage);
        } catch (decodeError) {
          print("❌ [ERROR] Failed to parse JSON: $decodeError");
        }
      } else {
        String message = '❌ [ERROR] Request failed with status: ${response.statusCode}';

        if (response.statusCode == 417) {
          try {
            final serverMessages = jsonDecode(response.body)['_server_messages'];
            message = serverMessages ?? message;
          } catch (decodeError) {
            print("❌ [ERROR] Failed to parse error message: $decodeError");
          }
        }

        print(message);
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
      print("❌ [ERROR] Exception: $e");

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






  Widget getCategoryPage(String categoryName, Map<String, dynamic> data) {
    switch (categoryName.toLowerCase()) {
      case 'accessories':
        return Accessories(data: data);
      case 'iron & steel':
        return IronSteel(data: data);
    }
    return Scaffold(
      appBar: AppBar(title: Text("Unknown Category")),
      body: Center(child: Text("No page found for: $categoryName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Subhead(text: "New Enquiry", weight: FontWeight.w500, color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category["id"], category["name"], category["imagePath"]);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String id, String name, String imagePath) {
    return GestureDetector(
      onTap: () => mobiledocument(context, id, name),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imagePath != "assets/aluminum.png"
                        ? NetworkImage(imagePath)
                        : const AssetImage("assets/aluminum.png") as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: MyText(text: name, weight: FontWeight.w500, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
