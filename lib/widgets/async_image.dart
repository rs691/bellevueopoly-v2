import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AsyncImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String placeholderAsset;
  final double borderRadius;

  const AsyncImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderAsset = 'assets/images/no_image_available.png',
    this.borderRadius = 0,
  });

  @override
  State<AsyncImage> createState() => _AsyncImageState();
}

class _AsyncImageState extends State<AsyncImage> {
  String? _resolvedUrl;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(AsyncImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() {}); // Trigger rebuild to show placeholder
      return;
    }

    // If it's already an HTTP URL, use it directly
    if (url.startsWith('http') || url.startsWith('https')) {
      if (mounted) {
        setState(() {
          _resolvedUrl = url;
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    // Assume it's a Storage path (gs:// or relative path)
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final ref = _getStorageRef(url);
      final downloadUrl = await ref.getDownloadURL();
      if (mounted) {
        setState(() {
          _resolvedUrl = downloadUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error resolving storage URL "$url": $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Reference _getStorageRef(String url) {
    if (url.startsWith('gs://')) {
      return FirebaseStorage.instance.refFromURL(url);
    } else {
      // Treat as relative path
      return FirebaseStorage.instance.ref().child(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (_hasError || _resolvedUrl == null) {
      content = _buildPlaceholder();
    } else {
      content = CachedNetworkImage(
        imageUrl: _resolvedUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Error loading cached image: $error');
          return _buildPlaceholder();
        },
      );
    }

    if (widget.borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: content,
      );
    }

    return content;
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      widget.placeholderAsset,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }
}
