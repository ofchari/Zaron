//// upvc tiles
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../getx/summary_screen.dart';
import '../../controller/upvc_get_controller.dart';

class UpvcTiles extends GetView<UpvcTilesController> {
  const UpvcTiles({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    Get.put(UpvcTilesController());
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'UPVC Tiles',
      //     style: GoogleFonts.poppins(
      //       fontSize: 20,
      //       fontWeight: FontWeight.w600,
      //       color: Colors.black87,
      //     ),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.black87),
      //     onPressed: () => Navigator.pop(context),
      //   ),
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
                      child: Obx(() => Form(
                            key: GlobalKey<FormState>(),
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
                                Gap(24),
                                buildAnimatedDropdown(
                                  controller.materialList,
                                  controller.selectMaterial.value,
                                  (value) {
                                    controller.selectMaterial.value =
                                        value ?? '';
                                    controller.selectedColor.value = '';
                                    controller.selectThickness.value = '';
                                    controller.colorsList.clear();
                                    controller.thicknessList.clear();
                                    controller.fetchColors();
                                  },
                                  label: "Material Type",
                                  icon: Icons.category_outlined,
                                ),
                                buildAnimatedDropdown(
                                  controller.colorsList,
                                  controller.selectedColor.value,
                                  (value) {
                                    controller.selectedColor.value =
                                        value ?? '';
                                    controller.selectThickness.value = '';
                                    controller.thicknessList.clear();
                                    controller.fetchThickness();
                                  },
                                  enabled: controller.colorsList.isNotEmpty,
                                  label: "Color",
                                  icon: Icons.color_lens_outlined,
                                ),
                                buildAnimatedDropdown(
                                  controller.thicknessList,
                                  controller.selectThickness.value,
                                  (value) {
                                    controller.selectThickness.value =
                                        value ?? '';
                                  },
                                  enabled: controller.thicknessList.isNotEmpty,
                                  label: "Thickness",
                                  icon: Icons.straighten_outlined,
                                ),
                                Gap(24),
                                Container(
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
                                      Gap(8),
                                      Text(
                                        [
                                          if (controller
                                              .selectMaterial.value.isNotEmpty)
                                            "Material Type: ${controller.selectMaterial.value}",
                                          if (controller
                                              .selectedColor.value.isNotEmpty)
                                            "Color: ${controller.selectedColor.value}",
                                          if (controller
                                              .selectThickness.value.isNotEmpty)
                                            "Thickness: ${controller.selectThickness.value}",
                                        ].join(", "),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          color: Colors.black,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Gap(24),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 54.h,
                                  child: ElevatedButton(
                                    onPressed: controller.postUpvcData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple[400],
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_shopping_cart_outlined,
                                            color: Colors.white),
                                        Gap(10),
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
                          )),
                    ),
                  ),
                  Obx(() {
                    if (controller.responseProducts.isEmpty) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 60, color: Colors.grey[400]),
                            Gap(16),
                            Text(
                              "No products added yet.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Gap(24),
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
                                  Gap(12),
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
                              Gap(16),
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
                                      "UPVC Tiles",
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
                                        borderRadius: BorderRadius.circular(20),
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
                                          Gap(4),
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
                              Gap(16),
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
                                            Gap(4),
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
                              ...controller.responseProducts
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final data = entry.value;
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15),
                                                child: SizedBox(
                                                  height: 40.h,
                                                  width: 210.w,
                                                  child: Text(
                                                    "${index + 1}. ${data["Products"] ?? 'N/A'}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.figtree(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
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
                                                border: Border.all(
                                                    color: Colors.red[200]!),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.red[50],
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                    size: 20),
                                                onPressed: () => Get.dialog(
                                                  AlertDialog(
                                                    title: Text("Delete Item"),
                                                    content: Text(
                                                        "Are you sure you want to delete this item?"),
                                                    actions: [
                                                      ElevatedButton(
                                                          onPressed: () =>
                                                              Get.back(),
                                                          child:
                                                              Text("Cancel")),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          controller.deleteCard(
                                                              data["id"]
                                                                  .toString());
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
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "UOM",
                                                        controller.uomDropdown(
                                                            data))),
                                                Gap(10),
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "Length",
                                                        editableTextField(
                                                            data, "Length",
                                                            (v) {
                                                          data["Length"] = v;
                                                          controller
                                                              .debounceCalculation(
                                                                  data);
                                                        },
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                                Gap(10),
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "Nos",
                                                        editableTextField(
                                                            data, "Nos", (v) {
                                                          data["Nos"] = v;
                                                          controller
                                                              .debounceCalculation(
                                                                  data);
                                                        },
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                              ],
                                            ),
                                            Gap(12),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "Basic Rate",
                                                        editableTextField(
                                                            data, "Basic Rate",
                                                            (v) {
                                                          data["Basic Rate"] =
                                                              v;
                                                          controller
                                                              .debounceCalculation(
                                                                  data);
                                                        },
                                                            readOnly: true,
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                                Gap(10),
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "Sq.Mtr",
                                                        editableTextField(data,
                                                            "Sq.Mtr", (v) {},
                                                            readOnly: true,
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                                Gap(10),
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "Amount",
                                                        editableTextField(data,
                                                            "Amount", (v) {},
                                                            readOnly: true,
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                              ],
                                            ),
                                            Gap(12),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "CGST",
                                                        editableTextField(data,
                                                            "cgst", (v) {},
                                                            readOnly: true,
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                                Gap(10),
                                                Expanded(
                                                    child: buildDetailItem(
                                                        "SGST",
                                                        editableTextField(data,
                                                            "sgst", (v) {},
                                                            readOnly: true,
                                                            fieldControllers:
                                                                controller
                                                                    .fieldControllers))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
