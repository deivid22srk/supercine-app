import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

/// Lista horizontal de cards de pôster — estado carregando com shimmer.
class HorizontalPosterList extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final EdgeInsets padding;

  const HorizontalPosterList({
    super.key,
    required this.children,
    this.height = 210,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  factory HorizontalPosterList.loading({
    int count = 6,
    double cardWidth = 118,
    double height = 210,
  }) {
    return HorizontalPosterList(
      height: height,
      children: List.generate(count, (_) => _ShimmerCard(width: cardWidth)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double width;
  const _ShimmerCard({required this.width});

  @override
  Widget build(BuildContext context) {
    final h = width * 1.5;
    return Shimmer.fromColors(
      baseColor: SupercineColors.surfaceAlt,
      highlightColor: SupercineColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: h,
            decoration: BoxDecoration(
              color: SupercineColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: width * 0.8,
            height: 10,
            color: SupercineColors.surfaceAlt,
          ),
        ],
      ),
    );
  }
}
