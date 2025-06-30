import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart ' as path;
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';

class AccessoriesImageUpload extends StatefulWidget {
  final String productId;

  const AccessoriesImageUpload({required this.productId, super.key});

  @override
  State<AccessoriesImageUpload> createState() => _AccessoriesImageUploadState();
}

class _AccessoriesImageUploadState extends State<AccessoriesImageUpload> {
  File? _selectedImage;
  bool _isUploading = false;

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

  ///
  ///
  ///
  ///
  ///
  ///
  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final url = Uri.parse("$apiUrl/upload_product_image");

      // Method 1: Multipart upload (recommended for file uploads)
      final request = http.MultipartRequest("POST", url);
      // FIXED: Changed from 'product_id' to 'id' to match API expectation
      request.fields['id'] = widget.productId;

      // Add the file
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Make sure this matches your API expectation
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
          // Go back to previous screen
          Navigator.pop(context, true); // Return true to indicate success
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

  // Alternative method if your API expects JSON with base64 encoded image
  Future<void> _uploadImageAsJson(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final url = Uri.parse("$apiUrl/upload_product_image");

      // Read file as bytes and encode to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final headers = {
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        // FIXED: Changed from 'product_id' to 'id' to match API expectation
        'id': widget.productId,
        'file': path.basename(imageFile.path), // Just the filename
        'image_data': base64Image, // Base64 encoded image data
      });

      debugPrint("Uploading as JSON...");
      debugPrint("Product ID: ${widget.productId}");
      debugPrint("File name: ${path.basename(imageFile.path)}");

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Image uploaded successfully.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image uploaded successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
              // ShaderMask(
              //   shaderCallback: (bounds) => LinearGradient(
              //     colors: [Colors.white, Colors.white],
              //     begin: Alignment.centerLeft,
              //     end: Alignment.centerRight,
              //   ).createShader(bounds),
              //   child: AnimatedDefaultTextStyle(
              //     duration: Duration(seconds: 1),
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 20,
              //       fontWeight: FontWeight.w800,
              //       letterSpacing: 1.2,
              //       shadows: [
              //         Shadow(
              //           color: Colors.black26,
              //           offset: Offset(2, 2),
              //           blurRadius: 4,
              //         ),
              //       ],
              //     ),
              //     child: Text("Product ID: ${widget.productId}"),
              //   ),
              // ),
              SizedBox(height: 20),

              // Image preview
              if (_selectedImage != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey, style: BorderStyle.solid),
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
                          "No image selected",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 20),

              // Upload button
              // Select Image button
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: Icon(Icons.photo_camera_outlined,
                    color: Colors.white, size: 20),
                label: Text("Select Image"),
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

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
