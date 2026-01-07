import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  String _selectedCategory = 'general';

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
    try {
      // Prepare files for upload
      final List<dynamic> filesToUpload = [];
      
      if (kIsWeb) {
        // For web, read as bytes
        for (var image in _selectedImages) {
          final bytes = await image.readAsBytes();
          filesToUpload.add(bytes);
        }
      } else {
        // For mobile, use File objects
        for (var image in _selectedImages) {
          filesToUpload.add(File(image.path));
        }
      }

      // Upload to Firebase Storage
      final downloadUrls = await _storageService.uploadMultipleImages(
        imageFiles: filesToUpload,
        category: _selectedCategory,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Successfully uploaded ${downloadUrls.length} images!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear the list after successful upload
      setState(() {
        _selectedImages.clear();
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
            // Category selector
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Image Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'review', child: Text('Business Review')),
                DropdownMenuItem(value: 'checkin', child: Text('Check-in Photo')),
                DropdownMenuItem(value: 'event', child: Text('Event')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'general';
                });
              },
            ),
            const SizedBox(height: 16),
            
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        final image = _selectedImages[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: kIsWeb
                              ? Image.network(
                                  image.path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(image.path),
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
