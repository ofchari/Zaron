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

import '../global_user/global_user.dart';

class Accessories extends StatefulWidget {
const Accessories({super.key, required this.data});

final Map<String, dynamic> data;

@override
State<Accessories> createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
late TextEditingController editController;
String? selectedAccessories;
String? selectedBrands;
String? selectedColors;
String? selectedThickness;
String? selectedCoatingMass;
String? selectedProductBaseId;

List<String> accessoriesList = [];
List<String> brandandList = [];
List<String> colorandList = [];
List<String> thickAndList = [];
List<String> coatingAndList = [];

// List<String> brandList = [];
List<Map<String, dynamic>> submittedData = [];

// Form key for validation
final _formKey = GlobalKey<FormState>();

@override
void initState() {
super.initState();
editController = TextEditingController(text: widget.data["Base Product"]);
_fetchAccessories();
_fetchBrandData();
}

@override
void dispose() {
editController.dispose();
super.dispose();
}

Future<void> _fetchAccessories() async {
setState(() {
accessoriesList = [];
selectedAccessories = null;
});

final client =
IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
final url = Uri.parse('$apiUrl/showlables/1');

try {
final response = await client.get(url);

if (response.statusCode == 200) {
final data = jsonDecode(response.body);
final accessories = data["message"]["message"][1];
debugPrint("Accessories:::${accessories}");
debugPrint(response.body, wrapWidth: 1024);

if (accessories is List) {
setState(() {
accessoriesList = accessories
    .whereType<Map>()
    .map((e) => e["accessories_name"]?.toString())
    .whereType<String>()
    .toList();
});
}
}
} catch (e) {
print("Exception fetching brands: $e");
}
}

Future<void> _fetchBrandData() async {
setState(() {
brandandList = [];
selectedBrands;
});

final client =
IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
final url = Uri.parse('$apiUrl/showlables/1');

try {
final response = await client.get(url);

if (response.statusCode == 200) {
final data = jsonDecode(response.body);
final brandData = data["message"]["message"][2][1];
debugPrint(response.body);

if (brandData is List) {
setState(() {
brandandList = brandData
    .whereType<Map>()
    .map((e) => e["brand"]?.toString())
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
Future<void> _fetchColorData() async {
if (selectedBrands == null) return;

setState(() {
colorandList = [];
selectedColors = null;
});

final client =
IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
final url = Uri.parse('$apiUrl/test');

try {
final response = await client.post(
url,
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
// "category_id": "3",
// "selectedlabel": "brand",
// "selectedvalue": selectedBrands,
// "label_name": "color",

"product_label": "color",
"product_filters": [selectedAccessories],
"product_label_filters": ["accessories_name"],
"product_category_id": 1,
"base_product_filters": [selectedBrands],
"base_label_filters": ["brand"],
"base_category_id": 3
}),
);

if (response.statusCode == 200) {
final data = jsonDecode(response.body);
final selectedThickness = data["message"]["message"][0];
print("Fetching colors for brand: $selectedThickness");
print("API response: ${response.body}");

if (selectedThickness is List) {
setState(() {
colorandList = selectedThickness
    .whereType<Map>()
    .map((e) => e["color"]?.toString())
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
Future<void> _fetchThicknessData() async {
if (selectedBrands == null) return;

setState(() {
thickAndList = [];
selectedThickness = null;
});

final client =
IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
final url = Uri.parse('$apiUrl/test');

try {
final response = await client.post(
url,
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
// "category_id": "3",
// "selectedlabel": "color",
// "selectedvalue": selectedColors,
// "label_name": "thickness",

"product_label": "thickness",
"product_filters": [selectedAccessories],
"product_label_filters": ["accessories_name"],
"product_category_id": 1,
"base_product_filters": [selectedBrands, selectedColors],
"base_label_filters": ["brand", "color"],
"base_category_id": 3
}),
);

if (response.statusCode == 200) {
final data = jsonDecode(response.body);
final thickness = data["message"]["message"][0];
print("Fetching colors for brand: $selectedColors");
print("API response: ${response.body}");

if (thickness is List) {
setState(() {
thickAndList = thickness
    .whereType<Map>()
    .map((e) => e["thickness"]?.toString())
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
Future<void> _fetchCoatingMassData() async {
if (selectedBrands == null ||
selectedColors == null ||
selectedThickness == null ||
!mounted) return;

setState(() {
coatingAndList = [];
selectedCoatingMass = null;
});

final client =
IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
final url = Uri.parse('$apiUrl/test');

try {
final response = await client.post(
url,
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
"product_label": "coating_mass",
"product_filters": [selectedAccessories],
"product_label_filters": ["accessories_name"],
"product_category_id": 1,
"base_product_filters": [
selectedBrands,
selectedColors,
selectedThickness
],
"base_label_filters": ["brand", "color", "thickness"],
"base_category_id": 3,
}),
);

if (response.statusCode == 200) {
final data = jsonDecode(response.body);
final message = data["message"]["message"];

print("Full API Response: $message");

if (message is List && message.length >= 2) {
final coatingData = message[0];
final idData = message[1];

if (coatingData is List) {
setState(() {
coatingAndList = coatingData
    .whereType<Map>()
    .map((e) => e["coating_mass"]?.toString())
    .whereType<String>()
    .toList();
});
}

if (idData is List && idData.isNotEmpty && idData.first is Map) {
selectedProductBaseId = idData.first["id"]?.toString();
debugPrint("Selected Product Base ID: $selectedProductBaseId");
}
} else {
debugPrint("Unexpected message format for coating mass data.");
}
} else {
debugPrint("Failed to fetch coating mass data: ${response.statusCode}");
}
} catch (e) {
print("Exception fetching coating mass data: $e");
}
}

///post All Data
Future<void> postAllData() async {
HttpClient client = HttpClient();
client.badCertificateCallback =
((X509Certificate cert, String host, int port) => true);
IOClient ioClient = IOClient(client);
final headers = {"Content-Type": "application/json"};
final data = {
"customer_id": UserSession().userId,
"product_id": 1,
"product_name": selectedAccessories,
"product_base_id": null,
"product_base_name":
"$selectedBrands,$selectedColors,$selectedThickness,$selectedCoatingMass,",
"category_id": 1,
"category_name": "accessories_name"

// "product_filters": null,
// "product_label_filters": null,
// "product_category_id": null,
// "base_product_filters": [
//   "${selectedBrands?.trim()}",
//   "${selectedColors?.trim()}",
//   "${selectedThickness?.trim()}",
//   "${selectedCoatingMass?.trim()}",
// ],
// "base_label_filters": [
//   "brand",
//   "color",
//   "thickness",
//   "coating_mass",
// ],
// "base_category_id": 590
};

print("This is a body data: $data");
final url = "$apiUrl/addbag";
final body = jsonEncode(data);
try {
final response = await ioClient.post(
Uri.parse(url),
headers: headers,
body: body,
);

debugPrint("This is a response: ${response.body}");
if (selectedAccessories == null ||
selectedBrands == null ||
selectedColors == null ||
selectedThickness == null ||
selectedCoatingMass == null) return;
if (response.statusCode == 200) {
// Get.snackbar(
//   "Data Added",
//   "Successfully",
//   colorText: Colors.white,
//   backgroundColor: Colors.green,
//   snackPosition: SnackPosition.BOTTOM,
// );
}
} catch (e) {
throw Exception("Error posting data: $e");
}
}

void _submitData() {
if (selectedAccessories == null ||
selectedBrands == null ||
selectedColors == null ||
selectedThickness == null ||
selectedCoatingMass == null) {
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
"Product": "Accessories",
"UOM": "Feet",
"Length": "0",
"Nos": "1",
"Basic Rate": "0",
"SQ": "0",
"Amount": "0",
"Base Product":
"$selectedAccessories, $selectedBrands, $selectedColors, $selectedThickness, $selectedCoatingMass,",
});
selectedAccessories = null;
selectedBrands = null;
selectedColors = null;
selectedThickness = null;
selectedCoatingMass = null;
accessoriesList = [];
brandandList = [];
colorandList = [];
thickAndList = [];
coatingAndList = [];
_fetchAccessories();
_fetchBrandData();
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
title: Text("Edit Your Linear Sheets"),
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

String selectedItem() {
List<String> value = [
if (selectedAccessories != null) "Product: $selectedAccessories",
if (selectedBrands != null) "Brand: $selectedBrands",
if (selectedColors != null) "Color: $selectedColors",
if (selectedThickness != null) "Thickness: $selectedThickness",
if (selectedCoatingMass != null) "CoatingMass: $selectedCoatingMass",
];
return value.isEmpty ? "No selection yet" : value.join(",  ");
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
text: 'Accessories',
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
_buildDropdown(accessoriesList, selectedAccessories,
(value) {
setState(() {
selectedAccessories = value;
});
// _fetchProductName();
},
// enabled: productList.isNotEmpty,
label: "Product Name"),
_buildDropdown(brandandList, selectedBrands, (value) {
setState(() {
selectedBrands = value;

///clear fields
selectedColors = null;
selectedThickness = null;
selectedCoatingMass = null;
colorandList = [];
thickAndList = [];
coatingAndList = [];
});
_fetchColorData();
}, label: "Brand"),
_buildDropdown(colorandList, selectedColors, (value) {
setState(() {
selectedColors = value;

///clear fields
selectedThickness = null;
selectedCoatingMass = null;
thickAndList = [];
coatingAndList = [];
});
_fetchThicknessData();
}, enabled: colorandList.isNotEmpty, label: "Color"),
_buildDropdown(thickAndList, selectedThickness,
(value) {
setState(() {
selectedThickness = value;

///clear fields
selectedCoatingMass = null;
coatingAndList = [];
});
_fetchCoatingMassData();
},
enabled: thickAndList.isNotEmpty,
label: "Thickness"),
_buildDropdown(coatingAndList, selectedCoatingMass,
(value) {
setState(() {
selectedCoatingMass = value;
});
},
enabled: coatingAndList.isNotEmpty,
label: "Coating Mass"),

Gap(20),
Card(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10)),
elevation: 1,
child: Padding(
padding: const EdgeInsets.all(12),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
MyText(
text: "Selected Product Details",
weight: FontWeight.w600,
color: Colors.black),
Gap(5),
MyText(
text: selectedItem(),
weight: FontWeight.w400,
color: Colors.grey)
],
),
),
),
// _buildDropdown(coatingAndList, selectedBrand, (value) {
//   setState(() {
//     selectedBrand = value;
//   });
// }, enabled: coatingAndList.isNotEmpty, label: "Brand"),
SizedBox(height: 20),
SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton(
onPressed: () async {
await postAllData();
_submitData();
},
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
