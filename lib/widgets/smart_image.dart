import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Yol "assets/" ile başlıyorsa AssetImage, değilse cihazdaki dosya olarak
/// (image_picker'dan gelen) yükler. Web'de dosya yolu desteklenmediğinden
/// orada placeholder gösterir.
class SmartImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final Widget Function(BuildContext) placeholder;

  const SmartImage({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null || p.isEmpty) return placeholder(context);

    if (p.startsWith('assets/')) {
      return Image.asset(p, fit: fit, errorBuilder: (_, __, ___) => placeholder(context));
    }
    if (!kIsWeb) {
      final file = File(p);
      return Image.file(file, fit: fit, errorBuilder: (_, __, ___) => placeholder(context));
    }
    return placeholder(context);
  }
}
