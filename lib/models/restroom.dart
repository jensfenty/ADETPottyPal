import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class Restroom {
  final Color imageColor;
  final String imagePath;
  final Uint8List? imageBytes;
  final List<String> photoPaths;
  final List<Uint8List> photoBytesList;
  final Alignment imageAlignment;
  final String name;
  final String address;
  final String distance;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final Color cardColor;
  final bool isOpen;
  final bool isUserAdded;

  ImageProvider _providerFor(String path, Uint8List? bytes) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    if (bytes != null) {
      return MemoryImage(bytes);
    }

    if (kIsWeb) {
      return const AssetImage('assets/images/pottypal-logo.webp');
    }

    return FileImage(File(path));
  }

  ImageProvider get imageProvider {
    if (photoPaths.isNotEmpty) {
      final firstBytes = photoBytesList.isNotEmpty
          ? photoBytesList.first
          : imageBytes;
      return _providerFor(photoPaths.first, firstBytes);
    }

    return _providerFor(imagePath, imageBytes);
  }

  List<ImageProvider> get photoProviders {
    if (photoPaths.isEmpty) return [imageProvider];

    return List.generate(photoPaths.length, (index) {
      final bytes = index < photoBytesList.length
          ? photoBytesList[index]
          : null;
      return _providerFor(photoPaths[index], bytes);
    });
  }

  Restroom({
    required this.imageColor,
    required this.imagePath,
    this.imageBytes,
    List<String>? photoPaths,
    List<Uint8List>? photoBytesList,
    this.imageAlignment = Alignment.center,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.cardColor,
    required this.isOpen,
    this.isUserAdded = false,
  }) : photoPaths = List.unmodifiable(photoPaths ?? [imagePath]),
       photoBytesList = List.unmodifiable(
         photoBytesList ?? (imageBytes != null ? [imageBytes] : const []),
       );
}
