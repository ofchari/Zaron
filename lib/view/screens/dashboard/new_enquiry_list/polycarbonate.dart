import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../getx/summary_screen.dart';
import '../../controller/polycarbonate_get_controller.dart';

// Polycarbonate Controller (similar reduction)

// Polycarbonate Screen
class Polycarbonate extends GetView<PolycarbonateController> {
  const Polycarbonate({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    Get.put(PolycarbonateController());
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Polycarbonate',
      //       style: GoogleFonts.poppins(
      //           fontSize: 20,
      //           fontWeight: FontWeight.w600,
      //           color: Colors.black87)),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   leading: IconButton(
      //       icon: Icon(Icons.arrow_back, color: Colors.black87),
      //       onPressed: () => Navigator.pop(context)),
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
                  colors: [Colors.white, Colors.grey.shade50])),
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
                              offset: Offset(0, 5))
                        ]),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Obx(() => Form(
                            key: GlobalKey<FormState>(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add New Product",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                                Gap(16),
                                buildAnimatedDropdown(controller.brandsList,
                                    controller.selectedBrand.value, (v) {
                                  controller.selectedBrand.value = v ?? '';
                                  controller.selectedColor.value = '';
                                  controller.selectedThickness.value = '';
                                  controller.colorsList.clear();
                                  controller.thicknessList.clear();
                                  controller.fetchColors();
                                },
                                    label: "Brand",
                                    icon: Icons.brightness_auto_outlined),
                                buildAnimatedDropdown(controller.colorsList,
                                    controller.selectedColor.value, (v) {
                                  controller.selectedColor.value = v ?? '';
                                  controller.selectedThickness.value = '';
                                  controller.thicknessList.clear();
                                  controller.fetchThickness();
                                },
                                    enabled: controller.colorsList.isNotEmpty,
                                    label: "Color",
                                    icon: Icons.color_lens_outlined),
                                buildAnimatedDropdown(controller.thicknessList,
                                    controller.selectedThickness.value, (v) {
                                  controller.selectedThickness.value = v ?? '';
                                },
                                    enabled:
                                        controller.thicknessList.isNotEmpty,
                                    label: "Thickness",
                                    icon: Icons.straighten_outlined),
                                Gap(16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.deepPurple[400]!,
                                          width: 1.5)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Selected Product Details",
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepPurple[400])),
                                      Gap(8),
                                      Text(
                                        [
                                          if (controller
                                              .selectedBrand.value.isNotEmpty)
                                            "Brand: ${controller.selectedBrand.value}",
                                          if (controller
                                              .selectedColor.value.isNotEmpty)
                                            "Color: ${controller.selectedColor.value}",
                                          if (controller.selectedThickness.value
                                              .isNotEmpty)
                                            "Thickness: ${controller.selectedThickness.value}",
                                        ].join(", "),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            color: Colors.black,
                                            height: 1.5),
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
                                    onPressed: controller.postPolycarbonateData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple[400],
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                          )),
                    ),
                  ),
                  Gap(24),
                  Obx(() => controller.responseProducts.isEmpty
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 60, color: Colors.grey[400]),
                              Gap(16),
                              Text("No products added yet.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : Column(
                          children: controller.responseProducts
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(
                                              "${index + 1}. ${data["Products"] ?? 'N/A'}",
                                              style: GoogleFonts.figtree(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87))),
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(
                                              "ID: ${data['id'] ?? 'N/A'}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[700],
                                                  fontWeight:
                                                      FontWeight.w500))),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Delete Item"),
                                            content: Text(
                                                "Are you sure you want to delete this item?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("Cancel")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    controller.deleteCard(
                                                        data["id"].toString());
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Delete")),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Row(children: [
                                          Expanded(
                                              child: buildDetailItem(
                                                  "UOM",
                                                  controller
                                                      .uomDropdown(data))),
                                          Gap(10),
                                          Expanded(
                                              child: buildDetailItem(
                                                  "Length",
                                                  editableTextField(
                                                      data, "Length", (v) {
                                                    data["Length"] = v;
                                                    controller
                                                        .debounceCalculation(
                                                            data);
                                                  },
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                          Gap(10),
                                          Expanded(
                                              child: buildDetailItem(
                                                  "Nos",
                                                  editableTextField(data, "Nos",
                                                      (v) {
                                                    data["Nos"] = v;
                                                    controller
                                                        .debounceCalculation(
                                                            data);
                                                  },
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                        ]),
                                        Gap(5),
                                        Row(children: [
                                          Expanded(
                                              child: buildDetailItem(
                                                  "Basic Rate",
                                                  editableTextField(
                                                      data, "Basic Rate", (v) {
                                                    data["Basic Rate"] = v;
                                                    controller
                                                        .debounceCalculation(
                                                            data);
                                                  },
                                                      readOnly: true,
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                          Gap(10),
                                          Expanded(
                                              child: buildDetailItem(
                                                  "SQMtr",
                                                  editableTextField(
                                                      data, "SQMtr", (v) {},
                                                      readOnly: true,
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                          Gap(10),
                                          Expanded(
                                              child: buildDetailItem(
                                                  "Amount",
                                                  editableTextField(
                                                      data, "Amount", (v) {},
                                                      readOnly: true,
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                        ]),
                                        Gap(5),
                                        Row(children: [
                                          Expanded(
                                              child: buildDetailItem(
                                                  "CGST",
                                                  editableTextField(
                                                      data, "cgst", (v) {},
                                                      readOnly: true,
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                          Gap(10),
                                          Expanded(
                                              child: buildDetailItem(
                                                  "SGST",
                                                  editableTextField(
                                                      data, "sgst", (v) {},
                                                      readOnly: true,
                                                      fieldControllers: controller
                                                          .fieldControllers))),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
