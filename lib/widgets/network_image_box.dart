import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

/// Imagem de rede com placeholder shimmer e fallback elegante.
class NetworkImageBox extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    if (url.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: SupercineColors.surfaceAlt,
          borderRadius: radius,
        ),
        child: Icon(
          Icons.broken_image_outlined,
          color: SupercineColors.textMuted,
          size: 32,
        ),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        errorWidget: (context, url, error) => Container(
          color: SupercineColors.surfaceAlt,
          width: width,
          height: height,
          child: Icon(
            Icons.broken_image_outlined,
            color: SupercineColors.textMuted,
            size: 32,
          ),
        ),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: SupercineColors.surfaceAlt,
          highlightColor: SupercineColors.surface,
          child: Container(
            width: width,
            height: height,
            color: SupercineColors.surfaceAlt,
          ),
        ),
      ),
    );
  }
}
