import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_meta.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import 'network_image_box.dart';

/// Card de pôster usado em listas horizontais e grids.
class MovieCard extends StatelessWidget {
  final MovieMeta meta;
  final double width;
  final bool showTitle;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.meta,
    this.width = 118,
    this.showTitle = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final fav = store.isFavorite(meta.imdb);
    final height = width * 1.5; // proporção 2:3 (pôster)

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.of(context).pushNamed('/detail', arguments: meta);
          },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'poster_${meta.imdb}',
                  child: NetworkImageBox(
                    url: meta.posterUrl,
                    width: width,
                    height: height,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Indisponível
                if (!meta.available)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'Indisponível',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: SupercineColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                // Favorito
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavBadge(active: fav),
                ),
                // Ano
                if (meta.year > 0)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        meta.year.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showTitle) ...[
              const SizedBox(height: 6),
              Text(
                meta.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SupercineColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
              ),
              if (meta.cast.isNotEmpty)
                Text(
                  meta.cast.split(',').first.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SupercineColors.textMuted,
                        fontSize: 11,
                      ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavBadge extends StatelessWidget {
  final bool active;
  const _FavBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        active ? Icons.favorite : Icons.favorite_border,
        size: 13,
        color: active ? SupercineColors.danger : Colors.white,
      ),
    );
  }
}
