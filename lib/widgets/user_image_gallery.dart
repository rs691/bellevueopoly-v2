import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/storage_service.dart';

/// Widget to display user's uploaded images in a gallery
class UserImageGallery extends StatelessWidget {
  final StorageService _storageService = StorageService();

  UserImageGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _storageService.getUserImagesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading images',
              style: TextStyle(color: Colors.red[300]),
            ),
          );
        }

        final images = snapshot.data?.docs ?? [];

        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.white30,
                ),
                const SizedBox(height: 16),
                Text(
                  'No images uploaded yet',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageDoc = images[index];
            final data = imageDoc.data() as Map<String, dynamic>;
            final imageUrl = data['imageUrl'] as String;
            final category = data['category'] as String? ?? 'general';

            return GestureDetector(
              onTap: () => _showImageDetail(context, imageDoc),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.white12,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white12,
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showImageDetail(BuildContext context, DocumentSnapshot imageDoc) {
    final data = imageDoc.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl'] as String;
    final category = data['category'] as String? ?? 'general';
    final businessName = data['businessName'] as String?;
    final uploadedAt = data['uploadedAt'] as Timestamp?;
    final tags = (data['tags'] as List?)?.cast<String>() ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.white12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  if (businessName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.store, size: 16, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            businessName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (uploadedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(uploadedAt.toDate()),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.white12,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(
                        context,
                        imageDoc.id,
                        imageUrl,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String imageDocId, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text(
          'This will permanently delete this image. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close confirm dialog
              Navigator.of(context).pop(); // Close image detail dialog

              try {
                await _storageService.deleteImageWithMetadata(
                  imageDocId,
                  imageUrl,
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Image deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
