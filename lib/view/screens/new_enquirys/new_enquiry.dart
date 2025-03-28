import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
        print(response.body);
        print(response.statusCode);
        if (data['message']['success']) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(
              (data['message']['message'] as List).map(
                    (item) => {
                  "name": item["categories"],
                  "imagePath": item["cate_image"] != null
                      ? "http://demo.zaron.in:8181/${item["cate_image"]}"
                      : "assets/aluminum.png",
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
            return _buildCategoryCard(
              category["name"],
              category["imagePath"],
            );
          },
        ),
      ),
    );
  }


  Widget _buildCategoryCard(String name, String imagePath) {
    return GestureDetector(
      onTap: () => Get.toNamed('/$name'),
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



