import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../camera_upload/roll_sheets_uploads/roll_sheet_attachment.dart';
import '../../controller/roll_sheet_get_controller.dart';

class RollSheet extends GetView<RollSheetController> {
  const RollSheet({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RollSheetController>()) {
      Get.put(RollSheetController());
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
                      padding: EdgeInsets.all(16),
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
                            SizedBox(height: 16),
                            Obx(() => buildAnimatedDropdown(
                                  controller.productList,
                                  controller.selectedProduct.value.isNotEmpty
                                      ? controller.selectedProduct.value
                                      : null,
                                  (value) {
                                    controller.selectedProduct.value =
                                        value ?? '';
                                    controller.selectedBrand.value = '';
                                    controller.selectedColor.value = '';
                                    controller.selectedThickness.value = '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.colorsList.clear();
                                    controller.thicknessList.clear();
                                    controller.coatingMassList.clear();
                                  },
                                  label: "Product Name",
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
                                    controller.selectedThickness.value = '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.colorsList.clear();
                                    controller.thicknessList.clear();
                                    controller.coatingMassList.clear();
                                    controller.fetchColors();
                                  },
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
                                    controller.selectedThickness.value = '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.thicknessList.clear();
                                    controller.coatingMassList.clear();
                                    controller.fetchThickness();
                                  },
                                  enabled: controller.colorsList.isNotEmpty,
                                  label: "Color",
                                  icon: Icons.color_lens_outlined,
                                )),
                            Obx(() => buildAnimatedDropdown(
                                  controller.thicknessList,
                                  controller.selectedThickness.value.isNotEmpty
                                      ? controller.selectedThickness.value
                                      : null,
                                  (value) {
                                    controller.selectedThickness.value =
                                        value ?? '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.coatingMassList.clear();
                                    controller.fetchCoatingMass();
                                  },
                                  enabled: controller.thicknessList.isNotEmpty,
                                  label: "Thickness",
                                  icon: Icons.straighten_outlined,
                                )),
                            Obx(() => buildAnimatedDropdown(
                                  controller.coatingMassList,
                                  controller
                                          .selectedCoatingMass.value.isNotEmpty
                                      ? controller.selectedCoatingMass.value
                                      : null,
                                  (value) {
                                    controller.selectedCoatingMass.value =
                                        value ?? '';
                                  },
                                  enabled:
                                      controller.coatingMassList.isNotEmpty,
                                  label: "Coating Mass",
                                  icon: Icons.layers_outlined,
                                )),
                            SizedBox(height: 16),
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
                                  if (controller
                                          .selectedProduct.value.isEmpty ||
                                      controller.selectedBrand.value.isEmpty ||
                                      controller.selectedColor.value.isEmpty ||
                                      controller
                                          .selectedThickness.value.isEmpty ||
                                      controller
                                          .selectedCoatingMass.value.isEmpty) {
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
                                        Text(
                                          "Roll Sheets",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
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
          Map<String, dynamic> data = Map<String, dynamic>.from(entry.value);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 65.h,
                          width: 200.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}. ${data["Products"] ?? ""}",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.figtree(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            "ID: ${data['id']}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                buildProductDetailInRows(data),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget buildProductDetailInRows(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildDetailItem("UOM", controller.uomDropdown(data)),
              ),
              Gap(10),
              Expanded(
                child: buildDetailItem(
                  "Profile",
                  controller.editableTextField(
                    data,
                    "Profile",
                    (v) => controller.debounceCalculation(data),
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
              ),
              Gap(10),
              Expanded(
                child: buildDetailItem(
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
          Gap(5),
          Row(
            children: [
              Expanded(
                child: buildDetailItem(
                  "Basic Rate",
                  controller.editableTextField(
                    data,
                    "Basic Rate",
                    (v) => controller.debounceCalculation(data),
                    readOnly: true,
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
              ),
              Gap(10),
              Expanded(
                child: buildDetailItem(
                  "SQMtr",
                  controller.editableTextField(
                    data,
                    "SQMtr",
                    (v) => controller.debounceCalculation(data),
                    readOnly: true,
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
              ),
              Gap(10),
              Expanded(
                child: buildDetailItem(
                  "Amount",
                  controller.editableTextField(
                    data,
                    "Amount",
                    (v) => controller.debounceCalculation(data),
                    readOnly: true,
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
              ),
            ],
          ),
          Gap(5.h),
          Row(
            children: [
              Expanded(
                child: buildDetailItem(
                  "CGST",
                  controller.editableTextField(
                    data,
                    "cgst",
                    (v) => controller.debounceCalculation(data),
                    readOnly: true,
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
              ),
              Gap(10),
              Expanded(
                child: buildDetailItem(
                  "SGST",
                  controller.editableTextField(
                    data,
                    "sgst",
                    (v) => controller.debounceCalculation(data),
                    readOnly: true,
                    fieldControllers: controller.fieldControllers,
                  ),
                ),
              ),
            ],
          ),
          Gap(5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildBaseProductSearchField(data),
              Container(
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green[100]!),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green[50],
                ),
                child: IconButton(
                  icon: Icon(Icons.attach_file,
                      color: Colors.green[600], size: 20),
                  onPressed: () {
                    Get.to(
                      RollAttachment(
                        productId: data['id'].toString(),
                        mainProductId: controller.currentMainProductId.value,
                      ),
                    );
                  },
                ),
              ),
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
                      content:
                          Text("Are you sure you want to delete this item?"),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Get.back(), child: Text("Cancel")),
                        ElevatedButton(
                          onPressed: () {
                            controller.deleteCard(data["id"].toString());
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
        ],
      ),
    );
  }

  Widget buildBaseProductSearchField(Map<String, dynamic> data) {
    String productId = data["id"].toString();

    // Initialize if not exists
    if (!controller.baseProductControllers.containsKey(productId)) {
      controller.baseProductControllers[productId] = TextEditingController();
      controller.baseProductResults[productId] = [];
      controller.selectedBaseProducts[productId] = null;
      controller.isSearchingBaseProducts[productId] = false;
      controller.showUpdateButton[productId] =
          false; // Initialize button visibility
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Base Product",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        Gap(5),
        Container(
          height: 40.h,
          width: 200.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller.baseProductControllers[productId],
            decoration: InputDecoration(
              hintText: "Search base product...",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              suffixIcon: Obx(() {
                if (controller.isSearchingBaseProducts[productId] == true) {
                  return Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ),
            onChanged: (value) {
              controller.searchBaseProducts(value, productId);
              // Show button when user starts typing
              if (value.isNotEmpty) {
                controller.showUpdateButton[productId] = true;
              }
            },
          ),
        ),
        Obx(() => controller.baseProductResults[productId]?.isNotEmpty == true
            ? Container(
                width: 200.w,
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Search Results:",
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...controller.baseProductResults[productId]!.map((product) {
                      return GestureDetector(
                        onTap: () {
                          controller.selectedBaseProducts[productId] =
                              product.toString();
                          controller.baseProductControllers[productId]!.text =
                              controller.selectedBaseProducts[productId]!;
                          controller.baseProductResults[productId] = [];
                          controller.showUpdateButton[productId] =
                              true; // Show button on selection
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          margin: EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2,
                                  size: 16, color: Colors.blue),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  product.toString(),
                                  style: GoogleFonts.figtree(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )
            : SizedBox.shrink()),
        Obx(() => controller.selectedBaseProducts[productId] != null
            ? Container(
                width: 200.w,
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Selected: ${controller.selectedBaseProducts[productId]}",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.selectedBaseProducts[productId] = null;
                        controller.baseProductControllers[productId]!.clear();
                        controller.baseProductResults[productId] = [];
                        controller.showUpdateButton[productId] = false;
                      },
                      child:
                          Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink()),
        Obx(() => controller.showUpdateButton[productId] == true &&
                controller.selectedBaseProducts[productId] != null
            ? Container(
                margin: EdgeInsets.only(top: 8),
                width: 200.w,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.selectedBaseProducts[productId] != null &&
                        controller
                            .selectedBaseProducts[productId]!.isNotEmpty) {
                      controller.updateBaseProduct(productId,
                          controller.selectedBaseProducts[productId]!);
                    } else {
                      Get.snackbar(
                        "Error",
                        "Please select a base product first.",
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Update Base Product",
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink()),
      ],
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
