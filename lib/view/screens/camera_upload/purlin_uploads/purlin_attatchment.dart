import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/screens/camera_upload/purlin_uploads/purlin_image_upload.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';

class PurlinAttachment extends StatefulWidget {
  final String productId;
  final String mainProductId;

  const PurlinAttachment({
    super.key,
    required this.productId,
    required this.mainProductId,
  });

  @override
  State<PurlinAttachment> createState() => _PurlinAttachmentState();
}

class _PurlinAttachmentState extends State<PurlinAttachment> {
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
    final url = "$apiUrl/product_images";
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Subhead(
              text: 'Product Attachments',
              weight: FontWeight.w500,
              color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.info_outline,
                                color: Colors.deepPurple[400], size: 24),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product ID: ${widget.productId}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Main ID: ${widget.mainProductId}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 55,
                  margin: EdgeInsets.only(bottom: 20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurlinImageUpload(
                            productId: widget.productId,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.add_photo_alternate,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Upload New Image',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? _buildLoadingState()
                      : productImages.isEmpty
                          ? _buildEmptyState()
                          : _buildImageList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.deepPurple[400]!),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading images...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No images found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Upload some images to get started',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton.icon(
                onPressed: _loadProductImages,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return RefreshIndicator(
      onRefresh: _loadProductImages,
      color: Colors.deepPurple[400],
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20),
        itemCount: productImages.length,
        itemBuilder: (context, index) {
          var imageData = productImages[index];
          String imageUrl = "";
          String imageName = "";

          if (imageData is Map<String, dynamic>) {
            imageUrl = imageData["product_image"]?.toString() ?? "";
            imageName = imageData["image_layout_plan"]?.toString() ??
                "Image ${index + 1}";
          }

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        _showFullScreenImage(context, imageUrl, imageName),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: imageUrl,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image_outlined,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        "Image not available",
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'View',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          imageName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ID: ${imageData["id"] ?? "N/A"}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          backgroundColor: Colors.grey,
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
