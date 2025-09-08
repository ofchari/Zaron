import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart%20';
import 'package:zaron/view/widgets/subhead.dart';

import '../../camera_upload/profile_uploads/profile_attchement.dart';
import '../../controller/profile_ridge_get_controller.dart';

class ProfileRidgeAndArch extends GetView<ProfileRidgeAndArchController> {
  const ProfileRidgeAndArch({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Subhead(
      //     text: 'Profile Ridge & Arch',
      //     weight: FontWeight.w500,
      //     color: Colors.black,
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.black87),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: Icon(Icons.view_list, color: Colors.black87),
      //   //     onPressed: () => Get.to(() => SummaryScreen()),
      //   //   ),
      //   // ],
      // ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add New Product",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 24),
                              _buildAnimatedDropdown(
                                controller.materialList,
                                controller.selectedMaterial,
                                (value) {
                                  controller.selectedMaterial = value;
                                  controller.update();
                                },
                                label: "Material Type",
                                icon: Icons.difference_outlined,
                              ),
                              _buildAnimatedDropdown(
                                controller.brandandList,
                                controller.selectedBrands,
                                (value) {
                                  controller.selectedBrands = value;
                                  controller.selectedColors = null;
                                  controller.selectedThickness = null;
                                  controller.selectedCoatingMass = null;
                                  controller.colorandList.clear();
                                  controller.thickAndList.clear();
                                  controller.coatingAndList.clear();
                                  controller.fetchColorData();
                                },
                                enabled: controller.brandandList.isNotEmpty,
                                label: "Brand",
                                icon: Icons.brightness_auto_outlined,
                              ),
                              _buildAnimatedDropdown(
                                controller.colorandList,
                                controller.selectedColors,
                                (value) {
                                  controller.selectedColors = value;
                                  controller.selectedThickness = null;
                                  controller.selectedCoatingMass = null;
                                  controller.thickAndList.clear();
                                  controller.coatingAndList.clear();
                                  controller.fetchThicknessData();
                                },
                                enabled: controller.colorandList.isNotEmpty,
                                label: "Color",
                                icon: Icons.color_lens_outlined,
                              ),
                              _buildAnimatedDropdown(
                                controller.thickAndList,
                                controller.selectedThickness,
                                (value) {
                                  controller.selectedThickness = value;
                                  controller.selectedCoatingMass = null;
                                  controller.coatingAndList.clear();
                                  controller.fetchCoatingMassData();
                                },
                                enabled: controller.thickAndList.isNotEmpty,
                                label: "Thickness",
                                icon: Icons.straighten_outlined,
                              ),
                              _buildAnimatedDropdown(
                                controller.coatingAndList,
                                controller.selectedCoatingMass,
                                (value) {
                                  controller.selectedCoatingMass = value;
                                  controller.update();
                                },
                                enabled: controller.coatingAndList.isNotEmpty,
                                label: "Coating Mass",
                                icon: Icons.layers_outlined,
                              ),
                              SizedBox(height: 24),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.deepPurple[400]!,
                                      width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Selected Product Details",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple[400],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      _selectedItems(),
                                      style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          color: Colors.black,
                                          height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: double.infinity,
                                height: 54.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (controller.selectedMaterial == null ||
                                        controller.selectedBrands == null ||
                                        controller.selectedColors == null ||
                                        controller.selectedThickness == null) {
                                      Get.snackbar("Error",
                                          "Please fill all required fields",
                                          backgroundColor: Colors.red);
                                      return;
                                    }
                                    controller.postAllData();
                                    controller.clearSelection();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple[400],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_shopping_cart_outlined,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        "Add Product",
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.responseProducts.isNotEmpty) ...[
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade100,
                                Colors.blue.shade50
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.deepPurple.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade100
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.shopping_bag_outlined,
                                        color: Colors.deepPurple.shade700,
                                        size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Added Products",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Subhead(
                                        text: controller
                                                .categoryMeta["categories"] ??
                                            "Profile Ridge & Arch",
                                        weight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.blue.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.receipt_outlined,
                                                size: 10,
                                                color: Colors.blue.shade700),
                                            // SizedBox(width: 4),
                                            Text(
                                              "ID: ${controller.orderNO ?? 'N/A'}",
                                              style: GoogleFonts.figtree(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple.shade500,
                                      Colors.deepPurple.shade200
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "TOTAL AMOUNT",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "₹${controller.billamt.value}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildSubmittedDataList(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  String _selectedItems() {
    List<String> value = [
      if (controller.selectedMaterial != null)
        "Material Type: ${controller.selectedMaterial}",
      if (controller.selectedBrands != null)
        "Brand: ${controller.selectedBrands}",
      if (controller.selectedColors != null)
        "Color: ${controller.selectedColors}",
      if (controller.selectedThickness != null)
        "Thickness: ${controller.selectedThickness}",
      if (controller.selectedCoatingMass != null)
        "CoatingMass: ${controller.selectedCoatingMass}",
    ];
    return value.isEmpty ? "No selection yet" : value.join(",  ");
  }

  Widget _buildSubmittedDataList() {
    if (controller.responseProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No products added yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: controller.responseProducts.asMap().entries.map((entry) {
        final index = entry.key;
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(entry.value);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              /// Header Row with Product Name, ID, and Delete Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 12),
                      child: Text(
                        "${index + 1}. ${data["Products"] ?? 'N/A'}",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "ID: ${data['id'] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () => showDialog(
                          context: context as BuildContext,
                          builder: (context) => AlertDialog(
                            title: Text(
                                "Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("No"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  controller.deleteCard(data["id"].toString());
                                  Navigator.pop(context);
                                },
                                child: Text("Yes"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// Product Detail Fields
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    /// Row 1: UOM, Crimp, Nos
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            "UOM",
                            controller.uomDropdown(data),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailItem(
                            "Crimp",
                            controller.editableTextField(
                              data,
                              "height",
                              (v) => controller.debounceCalculation(data),
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailItem(
                            "Nos",
                            controller.editableTextField(
                              data,
                              "Nos",
                              (v) => controller.debounceCalculation(data),
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Row 2: Basic Rate, SQMtr, Amount
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            "Basic Rate",
                            controller.editableTextField(
                              data,
                              "Basic Rate",
                              (v) {},
                              readOnly: true,
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailItem(
                            "SQMtr",
                            controller.editableTextField(
                              data,
                              "SQMtr",
                              (v) {},
                              readOnly: true,
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailItem(
                            "Amount",
                            controller.editableTextField(
                              data,
                              "Amount",
                              (v) {},
                              readOnly: true,
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Row 3: CGST, SGST, Empty
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            "CGST",
                            controller.editableTextField(
                              data,
                              "cgst",
                              (v) {},
                              readOnly: true,
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailItem(
                            "SGST",
                            controller.editableTextField(
                              data,
                              "sgst",
                              (v) {},
                              readOnly: true,
                              fieldControllers: controller.fieldControllers,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(), // Empty space for alignment
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Row 4: Base Product Search and Attachment Button
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: controller.buildBaseProductSearchField(data),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.attach_file,
                                color: Colors.green[600], size: 20),
                            onPressed: () {
                              Navigator.push(
                                context as BuildContext,
                                MaterialPageRoute(
                                  builder: (context) => ProfileAttachment(
                                    productId: data['id'].toString(),
                                    mainProductId:
                                        controller.currentMainProductId ??
                                            "Unknown ID",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailItem(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: field,
        ),
      ],
    );
  }

  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      // margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Row 1
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDetailItem("UOM", controller.uomDropdown(data)),
                ),
                _buildDetailItem(
                  "Crimp",
                  controller.editableTextField(
                    data,
                    "height",
                    (v) => controller.debounceCalculation(data),
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDetailItem(
                    "Nos",
                    controller.editableTextField(
                      data,
                      "Nos",
                      (v) => controller.debounceCalculation(data),
                      fieldControllers: controller.fieldControllers,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Row 2
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDetailItem(
                    "Basic Rate",
                    controller.editableTextField(
                      data,
                      "Basic Rate",
                      (v) {},
                      readOnly: true,
                      fieldControllers: controller.fieldControllers,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDetailItem(
                    "SQMtr",
                    controller.editableTextField(
                      data,
                      "SQMtr",
                      (v) {},
                      readOnly: true,
                      fieldControllers: controller.fieldControllers,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDetailItem(
                    "Amount",
                    controller.editableTextField(
                      data,
                      "Amount",
                      (v) {},
                      readOnly: true,
                      fieldControllers: controller.fieldControllers,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Row 3 - Tax Section
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDetailItem(
                    "CGST",
                    controller.editableTextField(
                      data,
                      "cgst",
                      (v) {},
                      readOnly: true,
                      fieldControllers: controller.fieldControllers,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDetailItem(
                    "SGST",
                    controller.editableTextField(
                      data,
                      "sgst",
                      (v) {},
                      readOnly: true,
                      fieldControllers: controller.fieldControllers,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(), // Empty container to maintain alignment
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown(
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: enabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade200),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: DropdownSearch<String>(
          items: items,
          selectedItem: selectedValue,
          onChanged: enabled ? onChanged : null,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: label,
              prefixIcon:
                  Icon(icon, color: enabled ? Colors.deepPurple : Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            constraints: BoxConstraints(maxHeight: 300),
          ),
        ),
      ),
    );
  }
}
