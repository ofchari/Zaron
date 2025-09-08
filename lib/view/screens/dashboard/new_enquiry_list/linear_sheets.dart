import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../getx/summary_screen.dart';
import '../../../widgets/subhead.dart';
import '../../controller/linear_sheet_get_controller.dart';

class LinerSheetPage extends GetView<LinerSheetController> {
  const LinerSheetPage({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(LinerSheetController(), permanent: true);

    return Scaffold(
      // appBar: AppBar(
      //   title: Subhead(
      //     text: 'Liner Sheet',
      //     weight: FontWeight.w500,
      //     color: Colors.black,
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.view_list, color: Colors.black87),
      //       onPressed: () => Get.to(() => SummaryScreen()),
      //     ),
      //   ],
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
                            SizedBox(height: 16),
                            Obx(() => _buildAnimatedDropdown(
                                  controller.productList,
                                  controller.selectedProduct.value.isNotEmpty
                                      ? controller.selectedProduct.value
                                      : null,
                                  (value) {
                                    controller.selectedProduct.value =
                                        value ?? '';
                                  },
                                  label: "Product Name",
                                  icon: Icons.category_outlined,
                                )),
                            Obx(() => _buildAnimatedDropdown(
                                  controller.brandandList,
                                  controller.selectedBrands.value.isNotEmpty
                                      ? controller.selectedBrands.value
                                      : null,
                                  (value) {
                                    controller.selectedBrands.value = value ?? '';
                                    controller.selectedColors.value = '';
                                    controller.selectedThickness.value = '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.colorandList.clear();
                                    controller.thickAndList.clear();
                                    controller.coatingAndList.clear();
                                    controller.fetchColorData();
                                  },
                                  enabled: controller.brandandList.isNotEmpty,
                                  label: "Brand",
                                  icon: Icons.brightness_auto_outlined,
                                )),
                            Obx(() => _buildAnimatedDropdown(
                                  controller.colorandList,
                                  controller.selectedColors.value.isNotEmpty
                                      ? controller.selectedColors.value
                                      : null,
                                  (value) {
                                    controller.selectedColors.value = value ?? '';
                                    controller.selectedThickness.value = '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.thickAndList.clear();
                                    controller.coatingAndList.clear();
                                    controller.fetchThicknessData();
                                  },
                                  enabled: controller.colorandList.isNotEmpty,
                                  label: "Color",
                                  icon: Icons.color_lens_outlined,
                                )),
                            Obx(() => _buildAnimatedDropdown(
                                  controller.thickAndList,
                                  controller.selectedThickness.value.isNotEmpty
                                      ? controller.selectedThickness.value
                                      : null,
                                  (value) {
                                    controller.selectedThickness.value =
                                        value ?? '';
                                    controller.selectedCoatingMass.value = '';
                                    controller.coatingAndList.clear();
                                    controller.fetchCoatingMassData();
                                  },
                                  enabled: controller.thickAndList.isNotEmpty,
                                  label: "Thickness",
                                  icon: Icons.straighten_outlined,
                                )),
                            Obx(() => _buildAnimatedDropdown(
                                  controller.coatingAndList,
                                  controller.selectedCoatingMass.value.isNotEmpty
                                      ? controller.selectedCoatingMass.value
                                      : null,
                                  (value) {
                                    controller.selectedCoatingMass.value =
                                        value ?? '';
                                  },
                                  enabled: controller.coatingAndList.isNotEmpty,
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
                                  if (controller.selectedProduct.value.isEmpty ||
                                      controller.selectedBrands.value.isEmpty ||
                                      controller.selectedColors.value.isEmpty ||
                                      controller
                                          .selectedThickness.value.isEmpty ||
                                      controller
                                          .selectedCoatingMass.value.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Incomplete Form'),
                                        content: Text(
                                          'Please fill all required fields to add a product.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
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
                                    Icon(
                                      Icons.add_shopping_cart_outlined,
                                      color: Colors.white,
                                    ),
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
                            SizedBox(height: 16),
                            // AnimatedContainer(
                            //   duration: Duration(milliseconds: 300),
                            //   width: double.infinity,
                            //   height: 54.h,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       controller.resetSelections();
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: Colors.grey[30
                            //       0],
                            //       foregroundColor: Colors.black,
                            //       elevation: 0,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //     ),
                            //     child: Text(
                            //       "Reset Form",
                            //       style: GoogleFonts.poppins(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                                      border:
                                          Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Liner Sheets",
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
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildSubmittedDataList(),
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

  Widget _buildSubmittedDataList() {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40.h,
                        width: 210.w,
                        child: Text(
                          "  ${index + 1}.  ${data["Products"] ?? ""}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "ID: ${data['id']}",
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
                        height: 40.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.deepPurple[50],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: Subhead(
                                  text: "Are you Sure to Delete This Item ?",
                                  weight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      controller
                                          .deleteCard(data["id"].toString());
                                      Get.back();
                                    },
                                    child: Text("Yes"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(),
                                    child: Text("No"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                _buildProductDetailInRows(data),
                Gap(5),
              ],
            ),
          );
        }).toList(),
      );
    });
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
                      offset: Offset(0, 2))
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

  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: buildDetailItem("UOM", controller.uomDropdown(data)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: buildDetailItem(
                  "Length",
                  controller.lengthDropdown(data),
                ),
              ),
              SizedBox(width: 10),
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
        ),
        Gap(5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
              SizedBox(width: 10),
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
              SizedBox(width: 10),
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
        ),
        Gap(5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
              SizedBox(width: 10),
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
        ),
        Gap(5.h),
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
}
