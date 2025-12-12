import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    // Allows selecting multiple images from the gallery
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select images to upload first!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // --- Placeholder for actual upload logic ---
    // In a real app, you would loop through _selectedImages
    // and upload each file to Firebase Storage or another service.
    await Future.delayed(const Duration(seconds: 3));
    // --- End of placeholder ---

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload complete (simulation)!')),
    );
    // Optionally, clear the list after upload
    // setState(() {
    //   _selectedImages = [];
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Your Images'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Use GoRouter to navigate back to the home screen
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. The image selection button
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Images from Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _pickImages,
            ),
            const SizedBox(height: 20),

            // 2. The grid to display selected images
            Expanded(
              child: _selectedImages.isEmpty
                  ? const Center(
                child: Text(
                  'No images selected.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 3. The upload button
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: Text('Upload (${_selectedImages.length}) Images'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _handleUpload,
            ),
          ],
        ),
      ),
    );
  }
}
