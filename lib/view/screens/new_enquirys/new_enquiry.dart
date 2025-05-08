import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/new_enquirys/accessories.dart';
import 'package:zaron/view/screens/new_enquirys/aluminum.dart';
import 'package:zaron/view/screens/new_enquirys/decking_sheets.dart';
import 'package:zaron/view/screens/new_enquirys/iron_steels.dart';
import 'package:zaron/view/screens/new_enquirys/length_sheets.dart';
import 'package:zaron/view/screens/new_enquirys/polycarbonate.dart';
import 'package:zaron/view/screens/new_enquirys/profile_arch.dart';
import 'package:zaron/view/screens/new_enquirys/purlin.dart';
import 'package:zaron/view/screens/new_enquirys/roll_sheets.dart';
import 'package:zaron/view/screens/new_enquirys/screw.dart';
import 'package:zaron/view/screens/new_enquirys/tile_sheets.dart';
import 'package:zaron/view/screens/new_enquirys/upvc_accessories.dart';
import 'package:zaron/view/screens/new_enquirys/upvc_tiles.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

import 'linear_sheets.dart';

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
    // print("check user id ${widget.userid}");
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('https://demo.zaron.in:8181/ci4/api/allcategories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);
        print(response.statusCode);
        if (data['message']['success']) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(
              (data['message']['message'] as List)
                  .where((item) =>
                      item["id"] != null &&
                      item["categories"] != null &&
                      item["cate_image"] != null)
                  .map(
                    (item) => {
                      "id": item["id"].toString(),
                      "name": item["categories"],
                      "imagePath":
                          "https://demo.zaron.in:8181/${item["cate_image"]}",
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

  Future<void> handleCategoryTap(
      BuildContext context, String id, String categoryName) async {
    final url = Uri.parse('https://demo.zaron.in:8181/ci4/api/showlables/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("✅ [SUCCESS] Response Data: $responseData");

        // Route to the correct page based on category name
        Widget nextPage = getCategoryPage(categoryName, responseData);
        Get.to(() => nextPage);
      } else {
        print("❌ [ERROR] Status Code: ${response.statusCode}");
        _showErrorDialog(context, 'Failed to load labels.');
      }
    } catch (e) {
      print("❌ [ERROR] Exception: $e");
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  Widget getCategoryPage(String categoryName, Map<String, dynamic> data) {
    switch (categoryName.toLowerCase()) {
      case 'accessories':
        return Accessories(data: data);
      case 'iron & steel':
        return IronSteel(data: data);
      case 'aluminum':
        return Aluminum(data: data);
      case 'cut to length sheets':
        return CutToLengthSheet(data: data);
      case 'decking sheet':
        return DeckingSheets(data: data);
      case 'liner sheets':
        return LinerSheetPage(data: data);
      case 'polycarbonate':
        return Polycarbonate(data: data);
      case 'profile ridge & arch':
        return ProfileRidgeAndArch(data: data);
      case 'purlin':
        return Purlin(data: data);
      case 'roll sheets':
        return RollSheet(data: data);
      case 'screw':
        return Screw(data: data);
      case 'tile sheet':
        return TileSheetPage(data: data);
      case 'upvc accessories':
        return UpvcAccessories(data: data);
      case 'upvc tile':
        return UpvcTiles(data: data);

      default:
        return Scaffold(
          appBar: AppBar(title: Text("Unknown Category")),
          body: Center(child: Text("No page found for: $categoryName")),
        );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Subhead(
            text: "New Enquiry", weight: FontWeight.w500, color: Colors.black),
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
                  return _buildCategoryCard(
                      category["id"], category["name"], category["imagePath"]);
                },
              ),
      ),
    );
  }

  Widget _buildCategoryCard(String id, String name, String imagePath) {
    return GestureDetector(
      onTap: () => handleCategoryTap(context, id, name),
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
                        : const AssetImage("assets/aluminum.png")
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: MyText(
                  text: name, weight: FontWeight.w500, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
