import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  // Singleton pattern
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Default cache settings
  static const int defaultMemCacheWidth = 500;
  static const int defaultMemCacheHeight = 750;
  static const int defaultMaxWidthDiskCache = 1000;
  static const int defaultMaxHeightDiskCache = 1500;

  // Get a cached network image with default settings
  Widget getCachedImage({
    required String imageUrl,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
    int? maxWidthDiskCache,
    int? maxHeightDiskCache,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: placeholder ?? _defaultPlaceholder,
      errorWidget: errorWidget ?? _defaultErrorWidget,
      memCacheWidth: memCacheWidth ?? defaultMemCacheWidth,
      memCacheHeight: memCacheHeight ?? defaultMemCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache ?? defaultMaxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache ?? defaultMaxHeightDiskCache,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }

  // Default placeholder widget
  Widget _defaultPlaceholder(BuildContext context, String url) {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // Default error widget
  Widget _defaultErrorWidget(BuildContext context, String url, dynamic error) {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  // Clear all cached images
  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  // Clear specific image from cache
  Future<void> clearImageFromCache(String imageUrl) async {
    await DefaultCacheManager().removeFile(imageUrl);
  }
}
