import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../../getx/summary_screen.dart';
import '../../camera_upload/acessories_uploads/accessories_attahment.dart';
import '../../controller/acessories_get_controller.dart';

class Accessories extends GetView<AccessoriesController> {
  const Accessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Accessories',
      //     style: GoogleFonts.poppins(
      //         fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   leading: IconButton(
      //       icon: Icon(Icons.arrow_back, color: Colors.black87),
      //       onPressed: () => Navigator.pop(context)),
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
                colors: [Colors.white, Colors.grey.shade50]),
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
                                offset: Offset(0, 5))
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
                                    color: Colors.black87),
                              ),
                              SizedBox(height: 24),
                              buildAnimatedDropdown(
                                controller.accessoriesList,
                                controller.selectedAccessories.value,
                                (value) => controller
                                    .selectedAccessories.value = value,
                                label: "Accessories Name",
                                icon: Icons.category_outlined,
                              ),
                              buildAnimatedDropdown(
                                controller.brandandList,
                                controller.selectedBrands.value,
                                (value) {
                                  controller.selectedBrands.value = value;
                                  controller.selectedColors.value = null;
                                  controller.selectedThickness.value = null;
                                  controller.selectedCoatingMass.value = null;
                                  controller.colorandList.clear();
                                  controller.thickAndList.clear();
                                  controller.coatingAndList.clear();
                                  controller.fetchColorData();
                                },
                                label: "Brand",
                                icon: Icons.brightness_auto_outlined,
                              ),
                              buildAnimatedDropdown(
                                controller.colorandList,
                                controller.selectedColors.value,
                                (value) {
                                  controller.selectedColors.value = value;
                                  controller.selectedThickness.value = null;
                                  controller.selectedCoatingMass.value = null;
                                  controller.thickAndList.clear();
                                  controller.coatingAndList.clear();
                                  controller.fetchThicknessData();
                                },
                                enabled: controller.colorandList.isNotEmpty,
                                label: "Color",
                                icon: Icons.color_lens_outlined,
                              ),
                              buildAnimatedDropdown(
                                controller.thickAndList,
                                controller.selectedThickness.value,
                                (value) {
                                  controller.selectedThickness.value = value;
                                  controller.selectedCoatingMass.value = null;
                                  controller.coatingAndList.clear();
                                  controller.fetchCoatingMassData();
                                },
                                enabled: controller.thickAndList.isNotEmpty,
                                label: "Thickness",
                                icon: Icons.straighten_outlined,
                              ),
                              buildAnimatedDropdown(
                                controller.coatingAndList,
                                controller.selectedCoatingMass.value,
                                (value) => controller
                                    .selectedCoatingMass.value = value,
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
                                          color: Colors.deepPurple[400]),
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
                                  onPressed: controller.postAllData,
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
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.deepPurple.shade100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
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
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Subhead(
                                            text: controller
                                                    .categoryyName.value ??
                                                "Accessories",
                                            weight: FontWeight.w600,
                                            color: Colors.grey.shade700),
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
                                              Icon(Icons.receipt_outlined,
                                                  size: 14,
                                                  color: Colors.blue.shade700),
                                              SizedBox(width: 4),
                                              Text(
                                                "ID: ${controller.orderNoo.value}",
                                                style: GoogleFonts.figtree(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.blue.shade700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
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
      if (controller.selectedAccessories.value != null)
        "Product: ${controller.selectedAccessories.value}",
      if (controller.selectedBrands.value != null)
        "Brand: ${controller.selectedBrands.value}",
      if (controller.selectedColors.value != null)
        "Color: ${controller.selectedColors.value}",
      if (controller.selectedThickness.value != null)
        "Thickness: ${controller.selectedThickness.value}",
      if (controller.selectedCoatingMass.value != null)
        "CoatingMass: ${controller.selectedCoatingMass.value}",
    ];
    return value.isEmpty ? "No selection yet" : value.join(",  ");
  }

  Widget _buildSubmittedDataList() {
    if (controller.responseProducts.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text("No products added yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Obx(() => Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.deepPurple.shade500,
                  Colors.deepPurple.shade200
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOTAL AMOUNT",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "₹${controller.billamt.value}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
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
            _buildGridView(),
          ],
        ));
  }

  Widget _buildGridView() {
    return Obx(() => Column(
          children: controller.responseProducts.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> data = Map<String, dynamic>.from(entry.value);

            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 14),
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
                    Gap(5),
                    _buildProductDetailInRows(data),
                    Gap(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        controller.buildBaseProductSearchField(data),
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
                              Get.to(AttachmentScreen(
                                productId: data['id'].toString(),
                                mainProductId:
                                    controller.currentMainProductId.value ??
                                        "Unknown ID",
                              ));
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
                    Gap(10),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: buildDetailItem("UOM", controller.uomDropdown(data))),
            SizedBox(width: 10),
            Expanded(
                child: buildDetailItem(
                    "Length",
                    controller.editableTextField(data, "Profile",
                        (v) => controller.debounceCalculation(data),
                        fieldControllers: controller.fieldControllers))),
            SizedBox(width: 10),
            Expanded(
                child: buildDetailItem(
                    "Nos",
                    controller.editableTextField(data, "Nos",
                        (v) => controller.debounceCalculation(data),
                        fieldControllers: controller.fieldControllers))),
          ],
        ),
        Gap(5),
        Row(
          children: [
            Expanded(
                child: buildDetailItem(
                    "Basic Rate",
                    controller.editableTextField(data, "Basic Rate", (v) {},
                        readOnly: true,
                        fieldControllers: controller.fieldControllers))),
            SizedBox(width: 10),
            Expanded(
                child: buildDetailItem(
                    "R.Ft",
                    controller.editableTextField(data, "R.Ft", (v) {},
                        readOnly: true,
                        fieldControllers: controller.fieldControllers))),
            SizedBox(width: 10),
            Expanded(
                child: buildDetailItem(
                    "Amount",
                    controller.editableTextField(data, "Amount", (v) {},
                        readOnly: true,
                        fieldControllers: controller.fieldControllers))),
          ],
        ),
        Gap(5),
        Row(
          children: [
            Expanded(
                child: buildDetailItem(
                    "CGST",
                    controller.editableTextField(data, "cgst", (v) {},
                        readOnly: true,
                        fieldControllers: controller.fieldControllers))),
            SizedBox(width: 12),
            Expanded(
                child: buildDetailItem(
                    "SGST",
                    controller.editableTextField(data, "sgst", (v) {},
                        readOnly: true,
                        fieldControllers: controller.fieldControllers))),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 12)),
        SizedBox(height: 4),
        SizedBox(height: 32, child: field),
      ],
    );
  }

// Widget _buildProductDetailInRows(Map<String, dynamic> data) {
//   return Column(
//     children: [
//       Row(
//         children: [
//           Expanded(
//               child: buildDetailItem("UOM", controller.uomDropdown(data))),
//           SizedBox(width: 10),
//           Expanded(
//               child: buildDetailItem(
//                   "Length",
//                   controller.editableTextField(data, "Profile",
//                       (v) => controller.debounceCalculation(data),
//                       fieldControllers: {}))),
//           SizedBox(width: 10),
//           Expanded(
//               child: buildDetailItem(
//                   "Nos",
//                   controller.editableTextField(data, "Nos",
//                       (v) => controller.debounceCalculation(data),
//                       fieldControllers: {}))),
//         ],
//       ),
//       Gap(5),
//       Row(
//         children: [
//           Expanded(
//               child: buildDetailItem(
//                   "Basic Rate",
//                   controller.editableTextField(data, "Basic Rate", (v) {},
//                       readOnly: true, fieldControllers: {}))),
//           SizedBox(width: 10),
//           Expanded(
//               child: buildDetailItem(
//                   "R.Ft",
//                   controller.editableTextField(data, "R.Ft", (v) {},
//                       readOnly: true, fieldControllers: {}))),
//           SizedBox(width: 10),
//           Expanded(
//               child: buildDetailItem(
//                   "Amount",
//                   controller.editableTextField(data, "Amount", (v) {},
//                       readOnly: true, fieldControllers: {}))),
//         ],
//       ),
//       Gap(5),
//       Row(
//         children: [
//           Expanded(
//               child: buildDetailItem(
//                   "CGST",
//                   controller.editableTextField(data, "cgst", (v) {},
//                       readOnly: true, fieldControllers: {}))),
//           SizedBox(width: 12),
//           Expanded(
//               child: buildDetailItem(
//                   "SGST",
//                   controller.editableTextField(data, "sgst", (v) {},
//                       readOnly: true, fieldControllers: {}))),
//         ],
//       ),
//     ],
//   );
// }
}
