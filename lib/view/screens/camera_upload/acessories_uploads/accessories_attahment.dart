import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';

import 'accsessoires_image _upload.dart';

class AttachmentScreen extends StatefulWidget {
  final String productId;
  final String mainProductId;

  const AttachmentScreen({
    super.key,
    required this.productId,
    required this.mainProductId,
  });

  @override
  State<AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<AttachmentScreen> {
  List<dynamic> productImages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductImages();
  }

  // Fixed: Make this async and update state properly
  Future<void> _loadProductImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final images =
          await fetchProductImages(widget.productId, widget.mainProductId);
      setState(() {
        productImages = images;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading images: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchProductImages(
      String productId, String mainProductId) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final headers = {"Content-Type": "application/json"};
    final data = {"product_id": mainProductId};
    debugPrint("Fetching images for product ID: $mainProductId");
    const url = "https://demo.zaron.in:8181/ci4/api/product_images";
    final body = jsonEncode(data);

    debugPrint("Fetching images for product ID: $mainProductId");
    debugPrint("Request body: $body");

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      debugPrint("Product Images Response Status: ${response.statusCode}");
      debugPrint("Product Images Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual response structure
        if (responseData["status"] == "success" &&
            responseData["product_images"] != null) {
          debugPrint(
              "Successfully fetched ${responseData["product_images"].length} images");
          return responseData["product_images"];
        } else {
          debugPrint("No images found or invalid response structure");
          debugPrint("Response status: ${responseData["status"]}");
          return [];
        }
      } else {
        debugPrint("Failed to fetch images: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");

        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body);
          debugPrint("Error details: ${errorData["message"]}");
        } catch (e) {
          debugPrint("Could not parse error response: $e");
        }
        return [];
      }
    } catch (e) {
      debugPrint("Exception in fetchProductImages: $e");
      return [];
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Attachments',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product ID: ${widget.productId}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Main Product ID: ${widget.mainProductId}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccessoriesImageUpload(
                      productId: widget.productId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Upload New Image',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Fixed: Better loading and empty state handling
            if (isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading images...'),
                    ],
                  ),
                ),
              )
            else if (productImages.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No images found for this product.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadProductImages,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadProductImages,
                  child: ListView.builder(
                    itemCount: productImages.length,
                    itemBuilder: (context, index) {
                      var imageData = productImages[index];
                      String imageUrl = "";
                      String imageName = "";

                      // Fixed: Better null safety and data handling
                      if (imageData is Map<String, dynamic>) {
                        // Get image URL - your API already provides full URL
                        imageUrl = imageData["product_image"]?.toString() ?? "";
                        imageName =
                            imageData["image_layout_plan"]?.toString() ??
                                "Image ${index + 1}";

                        // Debug print for troubleshooting
                        debugPrint("Image $index URL: $imageUrl");
                        debugPrint("Image $index Name: $imageName");
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Show full screen image
                                        _showFullScreenImage(
                                            context, imageUrl, imageName);
                                      },
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              height: 200,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            debugPrint(
                                                "Image load error for URL: $imageUrl");
                                            debugPrint("Error: $error");
                                            return Container(
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Failed to load image",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16),
                                                    child: Text(
                                                      imageUrl,
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Show image name/layout plan
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          imageName,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'ID: ${imageData["id"] ?? "N/A"}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListTile(
                                leading: Icon(Icons.broken_image,
                                    color: Colors.grey),
                                title: Text("Invalid image data"),
                                subtitle: Text("Index: $index"),
                              ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Added: Full screen image viewer
  void _showFullScreenImage(
      BuildContext context, String imageUrl, String imageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 64, color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              "Failed to load image",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    imageName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
