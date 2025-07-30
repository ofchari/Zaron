import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/dashboard/new_enquiry_list/CutToLengthSheet.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/accessories.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/aluminum.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/decking_sheets.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/gl_gutter.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/gl_stiffner.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/iron_steels.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/polycarbonate.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/profile_arch.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/purlin.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/roll_sheets.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/screw.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/screw_acessories.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/tile_sheets.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/upvc_accessories.dart';
import 'package:zaron/view/screens/dashboard/new_enquiry_list/upvc_tiles.dart';
import 'package:zaron/view/widgets/buttons.dart';

import '../../../universal_api/api&key.dart';
import '../../../widgets/text.dart';
import '../../global_user/global_oredrID.dart';
import 'linear_sheets.dart';

class NewEnquiry extends StatefulWidget {
  const NewEnquiry({super.key});

  @override
  State<NewEnquiry> createState() => _NewEnquiryState();
}

class _NewEnquiryState extends State<NewEnquiry> {
  List<Map<String, dynamic>> categories = [];
  bool isGridView = false; // Track current view mode

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('$apiUrl/allcategories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(response.body);
        print(response.statusCode);

        if (data['message']['success']) {
          // ✅ Extract and store new_order_id from the parent "message" object
          final message = data['message'];
          if (message["new_order_id"] != null) {
            int? parsed = int.tryParse(message["new_order_id"].toString());
            if (parsed != null) {
              GlobalOrderSession().setNewOrderId(parsed);
              print("✅ Stored new_order_id globally: $parsed");
            }
          }

          // 🧩 Now process the categories list
          final List filtered = (message['message'] as List)
              .where((item) =>
                  item["id"] != null &&
                  item["categories"] != null &&
                  item["cate_image"] != null)
              .toList();

          setState(() {
            categories = List<Map<String, dynamic>>.from(
              filtered.map(
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
      print('❌ Error fetching categories: $e');
    }
  }

  Future<void> handleCategoryTap(
      BuildContext context, String id, String categoryName) async {
    final url = Uri.parse('$apiUrl/showlables/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("[SUCCESS] Response Data: $responseData");

        // Route to the correct page based on category name
        Widget nextPage = getCategoryPage(categoryName, responseData);
        Get.to(() => nextPage);
      } else {
        print(" [ERROR] Status Code: ${response.statusCode}");
        _showErrorDialog(context, 'Failed to load labels.');
      }
    } catch (e) {
      print(" [ERROR] Exception: $e");
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  Widget getCategoryPage(String categoryName, Map<String, dynamic> data) {
    switch (categoryName) {
      case 'Accessories':
        return Accessories(data: data);
      case 'Iron And Steel Corrugated Sheet':
        return IronSteel(data: data);
      case 'Aluminium':
        return Aluminum(data: data);
      case 'Cut To Length Sheets':
        return CutToLengthSheet(data: data);
      case 'Decking sheet':
        return DeckingSheets(data: data);
      case 'Liner Sheets':
        return LinerSheetPage(data: data);
      case 'Polycarbonate':
        return Polycarbonate(data: data);
      case 'Profile ridge & Arch':
        return ProfileRidgeAndArch(data: data);
      case 'Purlin':
        return Purlin(data: data);
      case 'Roll Sheet':
        return RollSheet(data: data);
      case 'Screw':
        return Screw(data: data);
      case 'Screw accessories':
        return ScrewAccessories(data: data);
      case 'Tile sheet':
        return TileSheetPage(data: data);
      case 'UPVC Accessories':
        return UpvcAccessories(data: data);
      case 'UPVC Tile':
        return UpvcTiles(data: data);
      case 'GI GUTTER':
        return GIGlutter(data: data);
      case 'GI Stiffner':
        return GIStiffner(data: data);

      default:
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.white, title: Text("Unknown Category")),
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

  // Build filter toggle at the top
  Widget _buildViewToggleFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isGridView = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isGridView
                      ? const Color(0xFF4F46E5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list,
                      color:
                          !isGridView ? Colors.white : const Color(0xFF6B7280),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'List View',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: !isGridView
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isGridView = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isGridView ? const Color(0xFF4F46E5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view,
                      color:
                          isGridView ? Colors.white : const Color(0xFF6B7280),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grid View',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isGridView ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build grid view
  Widget _buildGridView() {
    return GridView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryGridItem(
          category["id"],
          category["name"],
          category["imagePath"],
        );
      },
    );
  }

  // Build list view
  Widget _buildListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryListItem(
          category["id"],
          category["name"],
          category["imagePath"],
        );
      },
    );
  }

  late double height;
  late double width;
  Widget _buildCategoryGridItem(String id, String name, String imagePath) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Container(
      height: height / 10.h,
      // margin: const EdgeInsets.only(bottom: 16), // Add margin to avoid clipping
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: imagePath != "assets/aluminum.png"
                      ? NetworkImage(imagePath)
                      : const AssetImage("assets/aluminum.png")
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensure the column takes only necessary space
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Name
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                        height: 3), // Spacing between text and button
                    // Button
                    GestureDetector(
                        onTap: () => handleCategoryTap(context, id, name),
                        child: Buttons(
                          text: "View",
                          weight: FontWeight.w500,
                          color: Colors.blueAccent,
                          height: height / 27.h,
                          width: width / 2.9.w,
                          radius: BorderRadius.circular(5),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem(String id, String name, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Image Section
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: DecorationImage(
                  image: imagePath != "assets/aluminum.png"
                      ? NetworkImage(imagePath)
                      : const AssetImage("assets/aluminum.png")
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Text Section
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D3748),
                  letterSpacing: -0.2,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Button Section
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => handleCategoryTap(context, id, name),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      'Click Here',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF4F46E5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: MyText(
              text: "New Enquiry Dashboard",
              weight: FontWeight.w600,
              color: Colors.white),
        ),
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter toggle at the top
                _buildViewToggleFilter(),

                // Content based on selected view
                Expanded(
                  child: isGridView ? _buildGridView() : _buildListView(),
                ),
              ],
            ),
    );
  }
}
