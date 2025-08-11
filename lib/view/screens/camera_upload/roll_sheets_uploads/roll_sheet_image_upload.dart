import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart ' as path;
import 'package:zaron/view/widgets/subhead.dart';

import '../../../universal_api/api_key.dart';

class RollImageUpload extends StatefulWidget {
  final String productId;

  const RollImageUpload({required this.productId, super.key});

  @override
  State<RollImageUpload> createState() => _RollImageUploadState();
}

class _RollImageUploadState extends State<RollImageUpload> {
  File? _selectedImage;
  bool _isUploading = false;
  bool _isLoading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchExistingImage();
  }

  // GET API method to fetch existing product image
  Future<void> _fetchExistingImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse("$apiUrl/product_image_view/${widget.productId}");

      debugPrint("Fetching image for Product ID: ${widget.productId}");
      debugPrint("Request URL: $url");

      final response = await http.get(url);

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 'success' &&
            jsonData['product_images'] != null) {
          setState(() {
            _existingImageUrl = jsonData['product_images'];
          });
          debugPrint("✅ Existing image URL: $_existingImageUrl");
        } else {
          debugPrint("No existing image found or invalid response format");
        }
      } else {
        debugPrint("❌ Failed to fetch image. Status: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to load existing image"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Exception while fetching image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text("Choose Image Source"),
        content: Text("Select the source for your image"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ImageSource.camera),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text("Camera"),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ImageSource.gallery),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text("Gallery"),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel"),
          ),
        ],
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        debugPrint("No image selected.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No image selected")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error accessing camera/gallery: $e")),
        );
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final url = Uri.parse("$apiUrl/upload_product_image");

      final request = http.MultipartRequest("POST", url);
      request.fields['id'] = widget.productId;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));

      debugPrint("Uploading image: ${imageFile.path}");
      debugPrint("Product ID: ${widget.productId}");
      debugPrint("File name: ${path.basename(imageFile.path)}");

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: $responseString");

      if (response.statusCode == 200) {
        debugPrint("✅ Image uploaded successfully.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image uploaded successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the existing image after successful upload
          await _fetchExistingImage();
          // Clear the selected image
          setState(() {
            _selectedImage = null;
          });
        }
      } else {
        debugPrint("❌ Upload failed. Status: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Upload failed. Status: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Exception during upload: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Widget to display existing image from server
  Widget _buildExistingImageDisplay() {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Loading existing image...",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show existing image from server
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _existingImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Failed to load image",
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "CURRENT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No image available
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "No image available",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display newly selected image
  Widget _buildSelectedImageDisplay() {
    if (_selectedImage == null) return SizedBox.shrink();

    return Column(
      children: [
        Text(
          "Selected Image Preview:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple[700],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "NEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Subhead(
            text: "Upload Product Image",
            weight: FontWeight.w500,
            color: Colors.white),
        backgroundColor: Colors.deepPurple[300],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchExistingImage,
            tooltip: "Refresh image",
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[300]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap(10),
                Text(
                  "Product ID: ${widget.productId}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Select Image button
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: Icon(Icons.photo_camera_outlined,
                      color: Colors.white, size: 20),
                  label: Text(
                      _selectedImage != null ? "Change Image" : "Select Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Upload button (only shown when image is selected)
                if (_selectedImage != null)
                  ElevatedButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () async {
                            await _uploadImage(_selectedImage!);
                          },
                    icon: _isUploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.upload,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(_isUploading ? "Uploading..." : "Upload Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                SizedBox(height: 20),

                // Image display
                _buildImageDisplay(),

                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Existing Image:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple[700],
            ),
          ),
          SizedBox(height: 10),
          _buildExistingImageDisplay(),
          SizedBox(height: 20),
          _buildSelectedImageDisplay(),
        ],
      ),
    );
  }
}
