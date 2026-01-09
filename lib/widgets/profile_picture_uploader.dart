import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../providers/user_data_provider.dart';

/// Reusable widget for uploading and displaying profile pictures
class ProfilePictureUploader extends ConsumerStatefulWidget {
  final String? currentPhotoUrl;
  final String userName;
  final VoidCallback? onUploadComplete;

  const ProfilePictureUploader({
    super.key,
    this.currentPhotoUrl,
    required this.userName,
    this.onUploadComplete,
  });

  @override
  ConsumerState<ProfilePictureUploader> createState() =>
      _ProfilePictureUploaderState();
}

class _ProfilePictureUploaderState
    extends ConsumerState<ProfilePictureUploader> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // Upload based on platform
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await _storageService.uploadProfilePicture(bytes);
      } else {
        final file = File(image.path);
        await _storageService.uploadProfilePicture(file);
      }

      // Clean up old profile pictures
      await _storageService.deleteOldProfilePictures();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh user data to show new profile picture
        ref.invalidate(userDataProvider);
        widget.onUploadComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';

    return Stack(
      children: [
        // Profile picture circle
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: widget.currentPhotoUrl != null
              ? NetworkImage(widget.currentPhotoUrl!)
              : null,
          child: widget.currentPhotoUrl == null
              ? Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        // Upload overlay when uploading
        if (_isUploading)
          Positioned.fill(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black54,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Camera icon button
        if (!_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 18),
                color: Colors.white,
                padding: EdgeInsets.zero,
                onPressed: _pickAndUploadImage,
              ),
            ),
          ),
      ],
    );
  }
}
