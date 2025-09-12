// upvc_accessories_screen.dart
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../controller/upvc_accessories_get_controller.dart';

class UpvcAccessories extends GetView<UpvcAccessoriesController> {
  const UpvcAccessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UpvcAccessoriesController>()) {
      Get.put(UpvcAccessoriesController());
    }

    return Scaffold(
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
              child: Column(
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
                      child: Form(
                        key: GlobalKey<FormState>(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Subhead(
                              text: "Add New Product",
                              weight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            SizedBox(height: 24),
                            Obx(() => buildAnimatedDropdown(
                                  controller.productList,
                                  controller.selectedProductNameBase.value
                                          .isNotEmpty
                                      ? controller.selectedProductNameBase.value
                                      : null,
                                  (value) {
                                    controller.selectedProductNameBase.value =
                                        value ?? '';
                                    controller.selectedBrand.value = '';
                                    controller.selectedColor.value = '';
                                    controller.selectedSize.value = '';
                                    controller.brandsList.clear();
                                    controller.colorsList.clear();
                                    controller.sizeList.clear();
                                  },
                                  label: "Product Name Base",
                                  icon: Icons.category_outlined,
                                )),
                            Obx(() => buildAnimatedDropdown(
                                  controller.brandsList,
                                  controller.selectedBrand.value.isNotEmpty
                                      ? controller.selectedBrand.value
                                      : null,
                                  (value) {
                                    controller.selectedBrand.value =
                                        value ?? '';
                                    controller.selectedColor.value = '';
                                    controller.selectedSize.value = '';
                                    controller.colorsList.clear();
                                    controller.sizeList.clear();
                                    controller.fetchColor();
                                  },
                                  enabled: controller.brandsList.isNotEmpty,
                                  label: "Brand",
                                  icon: Icons.brightness_auto_outlined,
                                )),
                            Obx(() => buildAnimatedDropdown(
                                  controller.colorsList,
                                  controller.selectedColor.value.isNotEmpty
                                      ? controller.selectedColor.value
                                      : null,
                                  (value) {
                                    controller.selectedColor.value =
                                        value ?? '';
                                    controller.selectedSize.value = '';
                                    controller.sizeList.clear();
                                    controller.fetchSize();
                                  },
                                  enabled: controller.colorsList.isNotEmpty,
                                  label: "Color",
                                  icon: Icons.color_lens_outlined,
                                )),
                            Obx(() => buildAnimatedDropdown(
                                  controller.sizeList,
                                  controller.selectedSize.value.isNotEmpty
                                      ? controller.selectedSize.value
                                      : null,
                                  (value) {
                                    controller.selectedSize.value = value ?? '';
                                  },
                                  enabled: controller.sizeList.isNotEmpty,
                                  label: "Size",
                                  icon: Icons.format_size_sharp,
                                )),
                            SizedBox(height: 24),
                            Obx(() => Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.deepPurple[400]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        controller.selectedItems(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          color: Colors.black,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            SizedBox(height: 24),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 54.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (controller.selectedProductNameBase.value
                                          .isEmpty ||
                                      controller.selectedBrand.value.isEmpty ||
                                      controller.selectedColor.value.isEmpty ||
                                      controller.selectedSize.value.isEmpty) {
                                    Get.snackbar(
                                      "Error",
                                      "Please fill all required fields",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  controller.postAllData();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple[400],
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(() => controller.responseProducts.isNotEmpty
                      ? Column(
                          children: [
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
                                border: Border.all(
                                    color: Colors.deepPurple.shade100),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.deepPurple.shade700,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Added Products",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white60,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Subhead(
                                          text: "UPVC Accessories",
                                          weight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                        Container(
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
                                              Icon(
                                                Icons.receipt_outlined,
                                                size: 14,
                                                color: Colors.blue.shade700,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "ID: ${controller.orderNO.value}",
                                                style: GoogleFonts.figtree(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
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
                                                  "₹${controller.billamt.value.toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  buildSubmittedDataList(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubmittedDataList() {
    return Obx(() {
      if (controller.responseProducts.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 60, color: Colors.grey[400]),
              SizedBox(height: 16),
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
          int index = entry.key;
          Map<String, dynamic> product = Map<String, dynamic>.from(entry.value);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SizedBox(
                              height: 40.h,
                              width: 210.w,
                              child: Text(
                                "${index + 1}. ${data["Products"] ?? 'N/A'}",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.figtree(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        Gap(4.w),
                        Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red[200]!),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red[50],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.redAccent, size: 20),
                            onPressed: () => Get.dialog(
                              AlertDialog(
                                title: Text("Delete Item"),
                                content: Text(
                                    "Are you sure you want to delete this item?"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () => Get.back(),
                                      child: Text("Cancel")),
                                  ElevatedButton(
                                    onPressed: () {
                                      controller
                                          .deleteCard(data["id"].toString());
                                      Get.back();
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  buildApiProductDetailInRows(product),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget buildApiProductDetailInRows(Map<String, dynamic> product) {
    return Column(
      children: [
        // Row 1: Basic Rate, Nos, Amount
        Row(
          children: [
            Expanded(
              child: buildDetailItem(
                "Basic Rate",
                buildReadOnlyField(product, "Basic Rate"),
              ),
            ),
            Gap(10),
            Expanded(
              child: buildDetailItem(
                "Nos",
                controller.editableTextField(
                  product,
                  "Nos",
                  (v) => controller.debounceCalculation(product),
                  fieldControllers: controller.fieldControllers,
                ),
              ),
            ),
            Gap(10),
            Expanded(
              child: buildDetailItem(
                "Amount",
                buildReadOnlyField(product, "Amount"),
              ),
            ),
          ],
        ),
        Gap(10),
        Row(
          children: [
            Expanded(
              child: buildDetailItem(
                "CGST",
                buildReadOnlyField(product, "cgst"),
              ),
            ),
            Gap(10),
            Expanded(
              child: buildDetailItem(
                "SGST",
                buildReadOnlyField(product, "sgst"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildReadOnlyField(Map<String, dynamic> product, String key) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[100],
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        product[key]?.toString() ?? "0",
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Widget buildDetailItem(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget buildAnimatedDropdown(
    RxList<String> items,
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
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
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
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.deepPurple : Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            constraints: BoxConstraints(maxHeight: 300),
          ),
        ),
      ),
    );
  }
}
