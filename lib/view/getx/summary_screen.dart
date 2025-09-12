import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/screens/controller/billingamount_get_controller.dart';
import 'package:zaron/view/screens/controller/screw_get_controller.dart';
import 'package:zaron/view/screens/controller/tilesheet_get_controller.dart';

import '../screens/camera_upload/profile_uploads/profile_attchement.dart';
import '../screens/camera_upload/roll_sheets_uploads/roll_sheet_attachment.dart';
import '../screens/controller/acessories_get_controller.dart';
import '../screens/controller/aluminum_get_controller.dart';
import '../screens/controller/cuttolength_controller.dart';
import '../screens/controller/decking_get_controller.dart';
import '../screens/controller/gi_stiffner_get_controller.dart';
import '../screens/controller/ironsteel_get_controller.dart';
import '../screens/controller/linear_sheet_get_controller.dart';
import '../screens/controller/polycarbonate_get_controller.dart';
import '../screens/controller/profile_ridge_get_controller.dart';
import '../screens/controller/purlin_get_controller.dart';
import '../screens/controller/roll_sheet_get_controller.dart';
import '../screens/controller/screw_acesssories_get_controller.dart';
import '../screens/controller/upvc_accessories_get_controller.dart';
import '../screens/controller/upvc_get_controller.dart';
import '../widgets/subhead.dart';

// Common UI Components
Widget buildAnimatedDropdown(
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      Gap(6),
      field,
    ],
  );
}

Widget editableTextField(
  Map<String, dynamic> data,
  String key,
  Function(String) onChanged, {
  bool readOnly = false,
  required Map<String, Map<String, TextEditingController>> fieldControllers,
}) {
  String productId = data["id"].toString();
  fieldControllers.putIfAbsent(productId, () => {});
  if (!fieldControllers[productId]!.containsKey(key)) {
    String initialValue = (data[key] != null &&
            data[key].toString() != "0" &&
            data[key].toString() != "null")
        ? data[key].toString()
        : "";
    fieldControllers[productId]![key] =
        TextEditingController(text: initialValue);
    debugPrint("Created controller for [$key] with value: '$initialValue'");
  }
  final controller = fieldControllers[productId]![key]!;
  if (controller.text.isEmpty &&
      data[key] != null &&
      data[key].toString() != "0" &&
      data[key].toString() != "null") {
    controller.text = data[key].toString();
    debugPrint("Synced controller for [$key] to: '${data[key]}'");
  }

  return SizedBox(
    height: 38.h,
    child: TextField(
      readOnly: readOnly,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    ),
  );
}

/// For Rolles Sheet Base product //
// In SummaryScreen class - Add this complete private method
Widget _buildRollSheetBaseProductSearchField(
    RollSheetController controller, Map<String, dynamic> data) {
  String productId = data["id"].toString();

  // Initialize if not exists
  if (!controller.baseProductControllers.containsKey(productId)) {
    controller.baseProductControllers[productId] = TextEditingController();
    controller.baseProductResults[productId] = [];
    controller.selectedBaseProducts[productId] = null;
    controller.isSearchingBaseProducts[productId] = false;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            "Base Product",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ),

        // Search TextField
        Container(
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller.baseProductControllers[productId],
            decoration: InputDecoration(
              hintText: "Search base product...",
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ),
            onChanged: (value) {
              controller.searchBaseProducts(value, productId);
            },
            onTap: () {
              if (controller
                  .baseProductControllers[productId]!.text.isNotEmpty) {
                controller.searchBaseProducts(
                    controller.baseProductControllers[productId]!.text,
                    productId);
              }
            },
          ),
        ),

        // Search Results
        Obx(() => controller.baseProductResults[productId]?.isNotEmpty == true
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
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
                                  overflow: TextOverflow.ellipsis,
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
                    }).toList(),
                  ],
                ),
              )
            : SizedBox.shrink()),

        // Selected Product Display
        Obx(() => controller.selectedBaseProducts[productId] != null
            ? Container(
                width: double.infinity,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.selectedBaseProducts[productId] = null;
                        controller.baseProductControllers[productId]!.clear();
                        controller.baseProductResults[productId] = [];
                      },
                      child:
                          Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink()),

        // Update Button
        Obx(() => controller.selectedBaseProducts[productId] != null
            ? Container(
                margin: EdgeInsets.only(top: 8),
                width: double.infinity,
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
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.update, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Update Base Product",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink()),
      ],
    ),
  );
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billController = Get.put(BillAmountController());
    final screwController = Get.find<ScrewController>();
    final polyController = Get.find<PolycarbonateController>();
    final upvcController = Get.find<UpvcTilesController>();
    final ironSteelController = Get.find<IronSteelController>();
    final cutToLengthController = Get.find<CutToLengthSheetController>();
    final deckingSheetsController = Get.find<DeckingSheetsController>();
    final aluminumController = Get.find<AluminumController>();

    final tileSheetController = Get.find<TileSheetController>();
    final linerSheetController = Get.isRegistered<LinerSheetController>()
        ? Get.find<LinerSheetController>()
        : Get.put(LinerSheetController(), permanent: true);
    final purlinController = Get.isRegistered<PurlinController>()
        ? Get.find<PurlinController>()
        : Get.put(PurlinController(), permanent: true);
    final accessoriesController = Get.isRegistered<AccessoriesController>()
        ? Get.find<AccessoriesController>()
        : Get.put(AccessoriesController(), permanent: true);
    final profileRidgeAndArchController =
        Get.isRegistered<ProfileRidgeAndArchController>()
            ? Get.find<ProfileRidgeAndArchController>()
            : Get.put(ProfileRidgeAndArchController(), permanent: true);
    final upvcAccessoriesController = Get.find<UpvcAccessoriesController>();
    final rollSheetController = Get.find<RollSheetController>(); // Add this
    final giStiffnerController = Get.find<GIStiffnerController>();
    final screwAcesssController = Get.find<ScrewAccessoriesController>();

    double calculateTotalBill() {
      double total = 0.0;
      for (var p in aluminumController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in tileSheetController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in screwController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in polyController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in upvcController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in ironSteelController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in cutToLengthController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in deckingSheetsController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in linerSheetController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      // ... (existing sums)
      for (var p in purlinController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0);
        (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
        // Add cgst/sgst if present in Purlin calc
      }
      for (var p in accessoriesController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in profileRidgeAndArchController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in upvcAccessoriesController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      // Roll Sheet products
      for (var p in rollSheetController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in giStiffnerController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      for (var p in screwAcesssController.responseProducts) {
        total += (double.tryParse(p["Amount"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["cgst"]?.toString() ?? "0") ?? 0) +
            (double.tryParse(p["sgst"]?.toString() ?? "0") ?? 0);
      }
      return total;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Subhead(
          text: 'Summary View',
          weight: FontWeight.w600,
          color: Colors.black87,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
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
              child: Obx(() {
                final totalBill = calculateTotalBill();
                final hasData =
                    aluminumController.responseProducts.isNotEmpty ||
                        screwController.responseProducts.isNotEmpty ||
                        polyController.responseProducts.isNotEmpty ||
                        upvcController.responseProducts.isNotEmpty ||
                        ironSteelController.responseProducts.isNotEmpty ||
                        cutToLengthController.responseProducts.isNotEmpty ||
                        deckingSheetsController.responseProducts.isNotEmpty ||
                        tileSheetController.responseProducts.isNotEmpty ||
                        linerSheetController.responseProducts.isNotEmpty;
                purlinController.responseProducts.isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Obx(() {
                                  final billTotal =
                                      billController.billOrderData['order_list']
                                          ?['bill_total'];
                                  return Text(
                                    billTotal != null
                                        ? "₹${billTotal.toString()}"
                                        : "Loading...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(24),

                    /// Show Nothing if the product is empty //
                    // if (!hasData)
                    //   Container(
                    //     padding: EdgeInsets.symmetric(vertical: 40),
                    //     alignment: Alignment.center,
                    //     child: Column(
                    //       children: [
                    //         Icon(
                    //           Icons.inventory_2_outlined,
                    //           size: 60,
                    //           color: Colors.grey[400],
                    //         ),
                    //         Gap(16),
                    //         Text(
                    //           "No products added yet.",
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             color: Colors.grey[600],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    if (aluminumController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Aluminum Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(5),
                      ...aluminumController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "  ${index + 1}. ${data["Products"] ?? 'N/A'}",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.figtree(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              aluminumController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            aluminumController
                                                .uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Billing Option",
                                            aluminumController
                                                .billingDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(
                                              data,
                                              "Length",
                                              (v) {
                                                data["Length"] = v;
                                                aluminumController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
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
                                            "Crimp",
                                            editableTextField(
                                              data,
                                              "Crimp",
                                              (v) {
                                                data["Crimp"] = v;
                                                aluminumController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                aluminumController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Basic Rate",
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                aluminumController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
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
                                            "SQMtr",
                                            editableTextField(
                                              data,
                                              "SQMtr",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
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
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  aluminumController
                                                      .fieldControllers,
                                            ),
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
                      }),
                    ],
                    if (screwController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Screw Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...screwController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
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
                                  children: [
                                    Expanded(
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
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
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
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      onPressed: () => Get.dialog(
                                        AlertDialog(
                                          title: Text("Delete Item"),
                                          content: Text(
                                              "Are you sure you want to delete this item?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                screwController.deleteCard(
                                                    data["id"].toString());
                                                Get.back();
                                              },
                                              child: Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildDetailItem(
                                        "Basic Rate",
                                        editableTextField(
                                          data,
                                          "Basic Rate",
                                          (v) {
                                            data["Basic Rate"] = v;
                                            screwController
                                                .debounceCalculation(data);
                                          },
                                          readOnly: true,
                                          fieldControllers:
                                              screwController.fieldControllers,
                                        ),
                                      ),
                                    ),
                                    Gap(5),
                                    Expanded(
                                      child: buildDetailItem(
                                        "Nos",
                                        editableTextField(
                                          data,
                                          "Nos",
                                          (v) {
                                            data["Nos"] = v;
                                            screwController
                                                .debounceCalculation(data);
                                          },
                                          fieldControllers:
                                              screwController.fieldControllers,
                                        ),
                                      ),
                                    ),
                                    Gap(5),
                                    Expanded(
                                      child: buildDetailItem(
                                        "Amount",
                                        editableTextField(
                                          data,
                                          "Amount",
                                          (v) {},
                                          readOnly: true,
                                          fieldControllers:
                                              screwController.fieldControllers,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildDetailItem(
                                        "CGST",
                                        editableTextField(
                                          data,
                                          "Cgst",
                                          (v) {},
                                          readOnly: true,
                                          fieldControllers:
                                              screwController.fieldControllers,
                                        ),
                                      ),
                                    ),
                                    Gap(10),
                                    Expanded(
                                      child: buildDetailItem(
                                        "SGST",
                                        editableTextField(
                                          data,
                                          "Sgst",
                                          (v) {},
                                          readOnly: true,
                                          fieldControllers:
                                              screwController.fieldControllers,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    if (polyController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Polycarbonate Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...polyController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "  ${index + 1}. ${data["Products"] ?? 'N/A'}",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.figtree(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              polyController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            polyController.uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(
                                              data,
                                              "Length",
                                              (v) {
                                                data["Length"] = v;
                                                polyController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers: polyController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                polyController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers: polyController
                                                  .fieldControllers,
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
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                polyController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers: polyController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SQMtr",
                                            editableTextField(
                                              data,
                                              "SQMtr",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: polyController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: polyController
                                                  .fieldControllers,
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
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: polyController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: polyController
                                                  .fieldControllers,
                                            ),
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
                      }),
                    ],
                    if (upvcController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "UPVC Tiles Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...upvcController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              upvcController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            upvcController.uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(
                                              data,
                                              "Length",
                                              (v) {
                                                data["Length"] = v;
                                                upvcController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers: upvcController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                upvcController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers: upvcController
                                                  .fieldControllers,
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
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                upvcController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers: upvcController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SQMtr",
                                            editableTextField(
                                              data,
                                              "Sq.Mtr",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: upvcController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: upvcController
                                                  .fieldControllers,
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
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: upvcController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: upvcController
                                                  .fieldControllers,
                                            ),
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
                      }),
                    ],
                    if (ironSteelController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Iron and Steel Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...ironSteelController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "  ${index + 1}. ${data["Products"] ?? 'N/A'}",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.figtree(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              ironSteelController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            ironSteelController
                                                .uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(
                                              data,
                                              "Length",
                                              (v) {
                                                data["Length"] = v;
                                                ironSteelController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Crimp",
                                            editableTextField(
                                              data,
                                              "height",
                                              (v) {
                                                data["height"] = v;
                                                ironSteelController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
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
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                ironSteelController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Basic Rate",
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                ironSteelController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SQMtr",
                                            editableTextField(
                                              data,
                                              "SQMtr",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
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
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "Cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "Sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  ironSteelController
                                                      .fieldControllers,
                                            ),
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
                      }),
                    ],
                    if (cutToLengthController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Cut To Length Sheets Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...cutToLengthController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "  ${index + 1}. ${data["Products"] ?? 'N/A'}",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.figtree(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              cutToLengthController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            cutToLengthController
                                                .uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Billing Option",
                                            cutToLengthController
                                                .billingDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(
                                              data,
                                              "Length",
                                              (v) {
                                                data["Length"] = v;
                                                cutToLengthController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
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
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                cutToLengthController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Basic Rate",
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                cutToLengthController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Qty",
                                            editableTextField(
                                              data,
                                              "qty",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
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
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  cutToLengthController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Gap(5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: buildDetailItem(
                                        "",
                                        cutToLengthController
                                            .buildBaseProductSearchField(data),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (deckingSheetsController
                        .responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Decking Sheets Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...deckingSheetsController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "  ${index + 1}. ${data["Products"] ?? 'N/A'}",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.figtree(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "ID: ${data['id'] ?? 'N/A'}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              deckingSheetsController
                                                  .deleteCard(
                                                      data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            deckingSheetsController
                                                .uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Billing Option",
                                            deckingSheetsController
                                                .billingDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(
                                              data,
                                              "Length",
                                              (v) {
                                                data["Length"] = v;
                                                deckingSheetsController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
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
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                deckingSheetsController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Basic Rate",
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                deckingSheetsController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Qty",
                                            editableTextField(
                                              data,
                                              "qty",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
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
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  deckingSheetsController
                                                      .fieldControllers,
                                            ),
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
                      }),
                    ],
                    // Add Tile Sheet section after Roll Sheet section:
                    if (tileSheetController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Tile Sheet Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...tileSheetController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              tileSheetController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            tileSheetController
                                                .uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            tileSheetController
                                                .lengthDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                tileSheetController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  tileSheetController
                                                      .fieldControllers,
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
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                tileSheetController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers:
                                                  tileSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SQMtr",
                                            editableTextField(
                                              data,
                                              "SQMtr",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  tileSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  tileSheetController
                                                      .fieldControllers,
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
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  tileSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  tileSheetController
                                                      .fieldControllers,
                                            ),
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
                    ],
                    if (linerSheetController.responseProducts.isNotEmpty ??
                        false) ...[
                      Gap(24),
                      Text(
                        "Liner Sheet Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...(linerSheetController.responseProducts
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final data =
                                Map<String, dynamic>.from(entry.value ?? {});
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "  ${index + 1}. ${data["Products"] ?? 'N/A'}",
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.figtree(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
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
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () => Get.dialog(
                                          AlertDialog(
                                            title: Text("Delete Item"),
                                            content: Text(
                                                "Are you sure you want to delete this item?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  linerSheetController
                                                      .deleteCard(data["id"]
                                                          .toString());
                                                  Get.back();
                                                },
                                                child: Text("Delete"),
                                              ),
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildDetailItem(
                                                "UOM",
                                                linerSheetController
                                                    .uomDropdown(data),
                                              ),
                                            ),
                                            // Gap(10),
                                            // Expanded(
                                            //   child: buildDetailItem(
                                            //     "Billing Option",
                                            //     linerSheetController
                                            //         .billingDropdown(data),
                                            //   ),
                                            // ),
                                            Gap(10),
                                            Expanded(
                                              child: buildDetailItem(
                                                "Length",
                                                editableTextField(
                                                  data,
                                                  "Length",
                                                  (v) {
                                                    data["Length"] = v;
                                                    linerSheetController
                                                        .debounceCalculation(
                                                            data);
                                                  },
                                                  fieldControllers:
                                                      linerSheetController
                                                          .fieldControllers,
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //   child: buildDetailItem(
                                            //     "Length",
                                            //     linerSheetController.lengthDropdown(data),
                                            //   ),
                                            // ),
                                            Gap(10),
                                            Expanded(
                                              child: buildDetailItem(
                                                "Nos",
                                                editableTextField(
                                                  data,
                                                  "Nos",
                                                  (v) {
                                                    data["Nos"] = v;
                                                    linerSheetController
                                                        .debounceCalculation(
                                                            data);
                                                  },
                                                  fieldControllers:
                                                      linerSheetController
                                                          .fieldControllers,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Gap(5),
                                        Row(children: [
                                          Expanded(
                                            child: buildDetailItem(
                                              "Basic Rate",
                                              editableTextField(
                                                data,
                                                "Basic Rate",
                                                (v) {
                                                  data["Basic Rate"] = v;
                                                  linerSheetController
                                                      .debounceCalculation(
                                                          data);
                                                },
                                                readOnly: true,
                                                fieldControllers:
                                                    linerSheetController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          Gap(10),
                                          Expanded(
                                            child: buildDetailItem(
                                              "SQMtr",
                                              editableTextField(
                                                data,
                                                "SQMtr",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    linerSheetController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          Gap(10),
                                          Expanded(
                                            child: buildDetailItem(
                                              "Amount",
                                              editableTextField(
                                                data,
                                                "Amount",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    linerSheetController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                        ]),
                                        Gap(5),
                                        Row(
                                          children: [
                                            Gap(10),
                                            Expanded(
                                              child: buildDetailItem(
                                                "CGST",
                                                editableTextField(
                                                  data,
                                                  "cgst",
                                                  (v) {},
                                                  readOnly: true,
                                                  fieldControllers:
                                                      linerSheetController
                                                          .fieldControllers,
                                                ),
                                              ),
                                            ),
                                            Gap(10),
                                            Expanded(
                                              child: buildDetailItem(
                                                "SGST",
                                                editableTextField(
                                                  data,
                                                  "sgst",
                                                  (v) {},
                                                  readOnly: true,
                                                  fieldControllers:
                                                      linerSheetController
                                                          .fieldControllers,
                                                ),
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
                          }) ??
                          []),
                    ],
                    Gap(10),
                    if (purlinController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Purlin Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(16),
                      ...purlinController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              purlinController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            purlinController.uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            purlinController.editableTextField(
                                              data,
                                              "Profile",
                                              (v) {
                                                data["Profile"] = v;
                                                purlinController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers: purlinController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            purlinController.editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                purlinController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers: purlinController
                                                  .fieldControllers,
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
                                            purlinController.editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: purlinController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Kg",
                                            purlinController.editableTextField(
                                              data,
                                              "kg",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: purlinController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            purlinController.editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: purlinController
                                                  .fieldControllers,
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
                                            "CGST",
                                            purlinController.editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: purlinController
                                                  .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            purlinController.editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers: purlinController
                                                  .fieldControllers,
                                            ),
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
                      }),
                    ],
                    Gap(10),
                    if (accessoriesController.responseProducts.isNotEmpty) ...[
                      Gap(24),
                      Text(
                        "Accessories Products",
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      Gap(16),
                      ...accessoriesController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
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
                                          color: Colors.black87),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      "ID: ${data['id'] ?? 'N/A'}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
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
                                              accessoriesController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            child: Text("Delete"),
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                            child: buildDetailItem(
                                                "UOM",
                                                accessoriesController
                                                    .uomDropdown(data))),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Length",
                                            editableTextField(data, "Profile",
                                                (v) {
                                              data["Profile"] = v;
                                              accessoriesController
                                                  .debounceCalculation(data);
                                            },
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            editableTextField(data, "Nos", (v) {
                                              data["Nos"] = v;
                                              accessoriesController
                                                  .debounceCalculation(data);
                                            },
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
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
                                            editableTextField(
                                                data, "Basic Rate", (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "R.Ft",
                                            editableTextField(
                                                data, "R.Ft", (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            editableTextField(
                                                data, "Amount", (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "CGST",
                                            editableTextField(
                                                data, "cgst", (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                                data, "sgst", (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    accessoriesController
                                                        .fieldControllers),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(child: Container()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (profileRidgeAndArchController
                        .responseProducts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        "Profile Ridge & Arch Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Product List as Cards (not Grid)
                      Column(
                        children: profileRidgeAndArchController.responseProducts
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final Map<String, dynamic> data =
                              Map<String, dynamic>.from(entry.value);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Header Row with Product, ID, Delete
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15, left: 12),
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
                                      margin: const EdgeInsets.only(top: 15),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.red[50],
                                          border: Border.all(
                                              color: Colors.red[200]!),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20),
                                          onPressed: () => Get.dialog(
                                            AlertDialog(
                                              title: const Text("Delete Item"),
                                              content: const Text(
                                                  "Are you sure you want to delete this item?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Get.back(),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    profileRidgeAndArchController
                                                        .deleteCard(data["id"]
                                                            .toString());
                                                    Get.back();
                                                  },
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                /// Detail Rows
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      /// Row 1: UOM, Crimp, Nos
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildDetailItem(
                                              "UOM",
                                              profileRidgeAndArchController
                                                  .uomDropdown(data),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: buildDetailItem(
                                              "Crimp",
                                              editableTextField(
                                                data,
                                                "height",
                                                (v) {
                                                  data["height"] = v;
                                                  profileRidgeAndArchController
                                                      .debounceCalculation(
                                                          data);
                                                },
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: buildDetailItem(
                                              "Nos",
                                              editableTextField(
                                                data,
                                                "Nos",
                                                (v) {
                                                  data["Nos"] = v;
                                                  profileRidgeAndArchController
                                                      .debounceCalculation(
                                                          data);
                                                },
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
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
                                            child: buildDetailItem(
                                              "Basic Rate",
                                              editableTextField(
                                                data,
                                                "Basic Rate",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: buildDetailItem(
                                              "SQMtr",
                                              editableTextField(
                                                data,
                                                "SQMtr",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: buildDetailItem(
                                              "Amount",
                                              editableTextField(
                                                data,
                                                "Amount",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      /// Row 3: CGST, SGST
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildDetailItem(
                                              "CGST",
                                              editableTextField(
                                                data,
                                                "cgst",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: buildDetailItem(
                                              "SGST",
                                              editableTextField(
                                                data,
                                                "sgst",
                                                (v) {},
                                                readOnly: true,
                                                fieldControllers:
                                                    profileRidgeAndArchController
                                                        .fieldControllers,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                              child:
                                                  SizedBox()), // keeps spacing
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      /// Row 4: Base Product Search + Attach button
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: profileRidgeAndArchController
                                                .buildBaseProductSearchField(
                                                    data),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.green[200]!),
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.attach_file,
                                                  color: Colors.green[600],
                                                  size: 20),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileAttachment(
                                                      productId:
                                                          data['id'].toString(),
                                                      mainProductId:
                                                          profileRidgeAndArchController
                                                                  .currentMainProductId ??
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
                      ),
                    ],
                    Obx(() => upvcAccessoriesController
                            .responseProducts.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(24),
                              Text(
                                "UPVC Accessories Products",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Gap(16),
                              ...upvcAccessoriesController.responseProducts
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final data =
                                    Map<String, dynamic>.from(entry.value);
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${data['S.No'] ?? (index + 1)}. ${data["Products"] ?? 'N/A'}",
                                              style: GoogleFonts.figtree(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
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
                                          Container(
                                            height: 40.h,
                                            width: 50.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.deepPurple[50],
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              onPressed: () => Get.dialog(
                                                AlertDialog(
                                                  title: Text("Delete Item"),
                                                  content: Text(
                                                      "Are you sure you want to delete this item?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Get.back(),
                                                      child: Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        upvcAccessoriesController
                                                            .deleteCard(data[
                                                                    "id"]
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
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Basic Rate",
                                                    editableTextField(
                                                      data,
                                                      "Basic Rate",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          upvcAccessoriesController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Nos",
                                                    editableTextField(
                                                      data,
                                                      "Nos",
                                                      (v) {
                                                        data["Nos"] = v;
                                                        upvcAccessoriesController
                                                            .debounceCalculation(
                                                                data);
                                                      },
                                                      fieldControllers:
                                                          upvcAccessoriesController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Amount",
                                                    editableTextField(
                                                      data,
                                                      "Amount",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          upvcAccessoriesController
                                                              .fieldControllers,
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
                                                    "CGST",
                                                    editableTextField(
                                                      data,
                                                      "cgst",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          upvcAccessoriesController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "SGST",
                                                    editableTextField(
                                                      data,
                                                      "sgst",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          upvcAccessoriesController
                                                              .fieldControllers,
                                                    ),
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
                            ],
                          )
                        : SizedBox.shrink()),
                    Gap(10),

                    // Roll Sheet Section in SummaryScreen
                    if (rollSheetController.responseProducts.isNotEmpty) ...[
                      Gap(5),
                      Text(
                        "Roll Sheet Products",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(5),
                      ...rollSheetController.responseProducts
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final data = Map<String, dynamic>.from(entry.value);
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Header Row with product name, ID, and delete button
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
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                                  // Attachment Button for Roll Sheet
                                  Container(
                                    height: 40.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.green[100]!),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green[50],
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.attach_file,
                                          color: Colors.green[600], size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RollAttachment(
                                              productId: data['id'].toString(),
                                              mainProductId: rollSheetController
                                                  .currentMainProductId.value,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => Get.dialog(
                                      AlertDialog(
                                        title: Text("Delete Item"),
                                        content: Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              rollSheetController.deleteCard(
                                                  data["id"].toString());
                                              Get.back();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Product Details
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    // First Row: UOM, Profile, Nos
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "UOM",
                                            rollSheetController
                                                .uomDropdown(data),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Profile",
                                            editableTextField(
                                              data,
                                              "Profile",
                                              (v) {
                                                data["Profile"] = v;
                                                rollSheetController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Nos",
                                            editableTextField(
                                              data,
                                              "Nos",
                                              (v) {
                                                data["Nos"] = v;
                                                rollSheetController
                                                    .debounceCalculation(data);
                                              },
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(5),
                                    // Second Row: Basic Rate, SQMtr, Amount
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "Basic Rate",
                                            editableTextField(
                                              data,
                                              "Basic Rate",
                                              (v) {
                                                data["Basic Rate"] = v;
                                                rollSheetController
                                                    .debounceCalculation(data);
                                              },
                                              readOnly: true,
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SQMtr",
                                            editableTextField(
                                              data,
                                              "SQMtr",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "Amount",
                                            editableTextField(
                                              data,
                                              "Amount",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(5),
                                    // Third Row: CGST, SGST
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildDetailItem(
                                            "CGST",
                                            editableTextField(
                                              data,
                                              "cgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: buildDetailItem(
                                            "SGST",
                                            editableTextField(
                                              data,
                                              "sgst",
                                              (v) {},
                                              readOnly: true,
                                              fieldControllers:
                                                  rollSheetController
                                                      .fieldControllers,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(10),
                                    // Base Product Search Field - USE THE PRIVATE METHOD HERE
                                    _buildRollSheetBaseProductSearchField(
                                        rollSheetController, data),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    Obx(() => giStiffnerController.responseProducts.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(24),
                              Text(
                                "GI Stiffner Products",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Gap(16),
                              ...giStiffnerController.responseProducts
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final data =
                                    Map<String, dynamic>.from(entry.value);
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                                color: Colors.black87,
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
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.redAccent),
                                            onPressed: () => Get.dialog(
                                              AlertDialog(
                                                title: Text("Delete Item"),
                                                content: Text(
                                                    "Are you sure you want to delete this item?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: Text("Cancel"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      giStiffnerController
                                                          .deleteCard(data["id"]
                                                              .toString());
                                                      Get.back();
                                                    },
                                                    child: Text("Delete"),
                                                  ),
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
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "UOM",
                                                    giStiffnerController
                                                        .uomDropdown(data),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Billing Option",
                                                    giStiffnerController
                                                        .billingDropdown(data),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Length",
                                                    editableTextField(
                                                      data,
                                                      "Length",
                                                      (v) {
                                                        data["Length"] = v;
                                                        giStiffnerController
                                                            .debounceCalculation(
                                                                data);
                                                      },
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
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
                                                    "Nos",
                                                    editableTextField(
                                                      data,
                                                      "Nos",
                                                      (v) {
                                                        data["Nos"] = v;
                                                        giStiffnerController
                                                            .debounceCalculation(
                                                                data);
                                                      },
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Basic Rate",
                                                    editableTextField(
                                                      data,
                                                      "Basic Rate",
                                                      (v) {
                                                        data["Basic Rate"] = v;
                                                        giStiffnerController
                                                            .debounceCalculation(
                                                                data);
                                                      },
                                                      readOnly: true,
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Qty",
                                                    editableTextField(
                                                      data,
                                                      "qty",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
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
                                                    "Amount",
                                                    editableTextField(
                                                      data,
                                                      "Amount",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "CGST",
                                                    editableTextField(
                                                      data,
                                                      "cgst",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "SGST",
                                                    editableTextField(
                                                      data,
                                                      "sgst",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          giStiffnerController
                                                              .fieldControllers,
                                                    ),
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
                              }),
                            ],
                          )
                        : Container()),
                    Obx(() => screwAcesssController.responseProducts.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(24),
                              Text(
                                "Screw Accessories Products",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Gap(16),
                              ...screwAcesssController.responseProducts
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final data =
                                    Map<String, dynamic>.from(entry.value);
                                // Ensure Amount, CGST, and SGST are initialized
                                data['Amount'] =
                                    data['Amount']?.toString() ?? '0';
                                data['cgst'] = data['cgst']?.toString() ?? '0';
                                data['sgst'] = data['sgst']?.toString() ?? '0';
                                screwAcesssController.calculateAmount(
                                    data); // Recalculate to ensure consistency
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  color: Colors.black87,
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
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              onPressed: () => Get.dialog(
                                                AlertDialog(
                                                  title: Text("Delete Item"),
                                                  content: Text(
                                                      "Are you sure you want to delete this item?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Get.back(),
                                                      child: Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        screwAcesssController
                                                            .deleteCard(data[
                                                                    "id"]
                                                                .toString());
                                                        Get.back();
                                                      },
                                                      child: Text("Delete"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Basic Rate",
                                                    editableTextField(
                                                      data,
                                                      "Basic Rate",
                                                      (v) {
                                                        data["Basic Rate"] = v;
                                                        screwAcesssController
                                                            .calculateAmount(
                                                                data);
                                                      },
                                                      fieldControllers:
                                                          screwAcesssController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "Nos",
                                                    editableTextField(
                                                      data,
                                                      "Nos",
                                                      (v) {
                                                        data["Nos"] = v;
                                                        screwAcesssController
                                                            .calculateAmount(
                                                                data);
                                                      },
                                                      fieldControllers:
                                                          screwAcesssController
                                                              .fieldControllers,
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
                                                    "Amount",
                                                    editableTextField(
                                                      data,
                                                      "Amount",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          screwController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "CGST",
                                                    editableTextField(
                                                      data,
                                                      "cgst",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          screwController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                                Gap(10),
                                                Expanded(
                                                  child: buildDetailItem(
                                                    "SGST",
                                                    editableTextField(
                                                      data,
                                                      "sgst",
                                                      (v) {},
                                                      readOnly: true,
                                                      fieldControllers:
                                                          screwController
                                                              .fieldControllers,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          )
                        : Container()),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
