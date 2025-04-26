import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

class CutToLengthSheet extends StatefulWidget {
  const CutToLengthSheet({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<CutToLengthSheet> createState() => _CutToLengthSheetState();
}

class _CutToLengthSheetState extends State<CutToLengthSheet> {
  late TextEditingController editController;
  String? selectedProduct;
  String? selectedMeterial;
  String? selectedThichness;
  String? selsectedCoat;
  String? selectedyie;
  String? selectedBrand;

  List<String> productList = [];
  List<String> meterialList = [];
  List<String> thichnessLists = [];
  List<String> coatMassList = [];
  List<String> yieldsListt = [];
  List<String> brandList = [];
  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchProductName();
    _fetchMeterialType();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductName() async {
    setState(() {
      productList = [];
      selectedProduct = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/626');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        debugPrint("PRoduct:::${products}");
        debugPrint(response.body, wrapWidth: 1024);

        if (products is List) {
          setState(() {
            productList = products
                .whereType<Map>()
                .map((e) => e["product_name"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  Future<void> _fetchMeterialType() async {
    setState(() {
      meterialList = [];
      selectedMeterial;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/626');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meterialData = data["message"]["message"][2][1];
        debugPrint(response.body);

        if (meterialData is List) {
          setState(() {
            meterialList = meterialData
                .whereType<Map>()
                .map((e) => e["material_type"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  /// fetch colors Api's //
  Future<void> _fetchThickness() async {
    if (selectedMeterial == null) return;

    setState(() {
      thichnessLists = [];
      selectedThichness = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/validinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category_id": "3",
          "selectedlabel": "material_type",
          "selectedvalue": selectedMeterial,
          "label_name": "thickness",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");

        if (selectedThickness is List) {
          setState(() {
            thichnessLists = selectedThickness
                .whereType<Map>()
                .map((e) => e["thickness"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching colors: $e");
    }
  }

  /// fetch Thickness Api's ///
  Future<void> _fetchCoat() async {
    if (selectedMeterial == null) return;

    setState(() {
      coatMassList = [];
      selsectedCoat = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/validinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category_id": "3",
          "selectedlabel": "thickness",
          "selectedvalue": selectedThichness,
          "label_name": "coating_mass",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coat = data["message"]["message"];
        print("Fetching colors for brand: $selectedThichness");
        print("API response: ${response.body}");

        if (coat is List) {
          setState(() {
            coatMassList = coat
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  /// fetch Thickness Api's ///
  Future<void> _fetchYie() async {
    if (selectedMeterial == null) return;

    setState(() {
      yieldsListt = [];
      selectedyie = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/validinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category_id": "3",
          "selectedlabel": "coating_mass",
          "selectedvalue": selsectedCoat,
          "label_name": "yield_strength",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final yieldsStrength = data["message"]["message"];
        print("Fetching colors for brand: $selectedThichness");
        print("API response: ${response.body}");

        if (yieldsStrength is List) {
          setState(() {
            yieldsListt = yieldsStrength
                .whereType<Map>()
                .map((e) => e["yield_strength"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    }
  }

  Future<void> _fetchBrandss() async {
    if (selectedMeterial == null) return;

    setState(() {
      brandList = [];
      selectedBrand = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/validinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category_id": "3",
          "selectedlabel": "yield_strength",
          "selectedvalue": selectedyie,
          "label_name": "brand",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brands = data["message"]["message"];
        print("Fetching colors for brand: $brands");
        print("API response: ${response.body}");

        if (brands is List) {
          setState(() {
            brandList = brands
                .whereType<Map>()
                .map((e) => e["brand"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    }
  }

  void _submitData() {
    if (selectedMeterial == null ||
        selectedThichness == null ||
        selsectedCoat == null ||
        selectedyie == null ||
        selectedBrand == null ||
        selectedProduct == null) {
// Show elegant error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Form'),
          content: Text('Please fill all required fields to add a product.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      submittedData.add({
        "Product": "Iron and Steel",
        "UOM": "Feet",
        "Length": "0",
        "Nos": "1",
        "Basic Rate": "0",
        "SQ": "0",
        "Amount": "0",
        "Base Product":
            "$selectedThichness, $selsectedCoat, $selectedyie, $selectedBrand, $selectedMeterial",
      });
      selectedMeterial = null;
      selectedThichness = null;
      selsectedCoat = null;
      selectedyie = null;
      selectedBrand = null;
      selectedProduct = null;
    });

// Show success message with a more elegant snackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Product added successfully"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSubmittedDataList() {
    if (submittedData.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
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
      children: submittedData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = entry.value;

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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      height: 40.h,
                      width: 210.w,
                      child: Text(
                        "  ${index + 1}.  ${data["Product"]}" ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepPurple[50],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        title: Text("Edit"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildProductDetailInRows(data),
                                          ],
                                        ));
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              )),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Subhead(
                                          text:
                                              "Are you Sure to Delete This Item ?",
                                          weight: FontWeight.w500,
                                          color: Colors.black),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              submittedData.removeAt(index);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text("Yes"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("No"),
                                        )
                                      ],
                                    );
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  MyText(
                      text: "  UOM - ",
                      weight: FontWeight.w600,
                      color: Colors.grey.shade600),
                  MyText(
                      text: "Length - ",
                      weight: FontWeight.w600,
                      color: Colors.grey.shade600),
                  MyText(
                      text: "Nos  ",
                      weight: FontWeight.w600,
                      color: Colors.grey.shade600),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8),
                child: Container(
                  height: 40.h,
                  width: double.infinity.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
// color: Colors.red,
                        height: 40.h,
                        width: 280.w,
                        child: TextField(
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          controller:
                              TextEditingController(text: data["Base Product"]),
                          readOnly: true,
                        ),
                      ),
                      Gap(5),
                      Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: IconButton(
                              onPressed: () {
                                editController.text = data["Base Product"];
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Edit Your Iron and Steel"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
// color: Colors.white,
                                              height: 45.h,
                                              width: double.infinity.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 7.0),
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                  ),
                                                  controller: editController,
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      data["Base Product"] =
                                                          value;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  data["Base Product"] =
                                                      editController.text;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: MyText(
                                                  text: "Save",
                                                  weight: FontWeight.w500,
                                                  color: Colors.black))
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 15,
                              )))
                    ],
                  ),
                ),
              ),
              Gap(5),
            ],
          ),
        );
      }).toList(),
    );
  }

// New method that organizes fields in rows, two fields per row
  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem("UOM", _uomDropdown(data)),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _buildDetailItem(
                  "Length", _editableTextField(data, "Length")),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
            ),
          ],
        ),
        Gap(35),
// Row 3: Basic Rate & SQ
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                  "Basic Rate", _editableTextField(data, "Basic Rate")),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem("SQ", _editableTextField(data, "SQ")),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: _buildDetailItem(
                  "Amount", _editableTextField(data, "Amount")),
            ),
          ],
        ),
        Gap(35),
      ],
    );
  }

  Widget _buildDetailItem(String label, Widget field) {
    return Container(
      child: Column(
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
      ),
    );
  }

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    return SizedBox(
      height: 40.h,
      child: TextField(
        style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
        controller: TextEditingController(text: data[key]),
        onChanged: (val) => data[key] = val,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _uomDropdown(Map<String, dynamic> data) {
    List<String> uomOptions = ["Feet", "mm", "cm"];
    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: data["UOM"],
        items: uomOptions
            .map((uom) => DropdownMenuItem(value: uom, child: Text(uom)))
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = val!;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged,
      {bool enabled = true, String? label}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        items: items,
        selectedItem: selectedValue,
        onChanged: enabled ? onChanged : null,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label ?? "Select",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        enabled: enabled,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Cut To Length Sheets',
          weight: FontWeight.w500,
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Subhead(
                              text: "Add New Product",
                              weight: FontWeight.w600,
                              color: Colors.black),
                          SizedBox(height: 16),
                          _buildDropdown(productList, selectedProduct, (value) {
                            setState(() {
                              selectedProduct = value;
                            });
// _fetchProductName();
                          },
// enabled: productList.isNotEmpty,
                              label: "Product Name"),
                          _buildDropdown(meterialList, selectedMeterial,
                              (value) {
                            setState(() {
                              selectedMeterial = value;
                            });
                            _fetchThickness();
                          }, label: "Meterial Type"),
                          _buildDropdown(thichnessLists, selectedThichness,
                              (value) {
                            setState(() {
                              selectedThichness = value;
                            });
                            _fetchCoat();
                          },
                              enabled: thichnessLists.isNotEmpty,
                              label: "Thickness"),
                          _buildDropdown(coatMassList, selsectedCoat, (value) {
                            setState(() {
                              selsectedCoat = value;
                            });
                            _fetchYie();
                          },
                              enabled: coatMassList.isNotEmpty,
                              label: "Coating Mass"),
                          _buildDropdown(yieldsListt, selectedyie, (value) {
                            setState(() {
                              selectedyie = value;
                            });
                            _fetchBrandss();
                          },
                              enabled: yieldsListt.isNotEmpty,
                              label: "Yield Strength"),
                          _buildDropdown(brandList, selectedBrand, (value) {
                            setState(() {
                              selectedBrand = value;
                            });
                          }, enabled: brandList.isNotEmpty, label: "Brand"),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitData,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: MyText(
                                  text: "Add Product",
                                  weight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                if (submittedData.isNotEmpty)
                  Subhead(
                      text: "   Added Products",
                      weight: FontWeight.w600,
                      color: Colors.black),
                SizedBox(height: 8),
                _buildSubmittedDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
