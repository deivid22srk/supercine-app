import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_meta.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import 'network_image_box.dart';

/// Hero banner rotativo no topo da Home, no estilo HBO Max:
/// grande, imersivo, com gradientes e CTA "Assistir".
class HeroBanner extends StatefulWidget {
  final List<MovieMeta> items;
  final double height;

  const HeroBanner({
    super.key,
    required this.items,
    this.height = 460,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final meta = widget.items[i];
              return _HeroItem(meta: meta, active: i == _page);
            },
          ),
        ),
        const SizedBox(height: 12),
        _Dots(
          count: widget.items.length,
          current: _page,
          onTap: (i) {
            _controller.animateToPage(i,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut);
          },
        ),
      ],
    );
  }
}

class _HeroItem extends StatelessWidget {
  final MovieMeta meta;
  final bool active;

  const _HeroItem({required this.meta, required this.active});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final fav = store.isFavorite(meta.imdb);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () =>
            Navigator.of(context).pushNamed('/detail', arguments: meta),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: active ? 1 : 0.85,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop
                NetworkImageBox(
                  url: meta.backdropUrl.isNotEmpty
                      ? meta.backdropUrl
                      : meta.posterUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(18),
                ),
                // Gradiente
                Container(
                  decoration: const BoxDecoration(
                    gradient: SupercineTheme.heroGradient,
                  ),
                ),
                // Conteúdo
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: SupercineColors.brand,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              meta.isTv ? 'SÉRIE' : 'FILME',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (meta.year > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              meta.year.toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (meta.imdbRating > 0) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded,
                                color: SupercineColors.warning, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              meta.imdbRatingFormatted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (meta.runtimeFormatted.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${meta.runtimeFormatted}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            onPressed: () => store.toggleFavorite(meta),
                            icon: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              color:
                                  fav ? SupercineColors.danger : Colors.white,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meta.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.05,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      if (meta.cast.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          meta.cast,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: meta.available
                                ? () => Navigator.of(context)
                                    .pushNamed('/detail', arguments: meta)
                                : null,
                            icon: const Icon(Icons.play_arrow_rounded,
                                size: 20),
                            label: const Text('Assistir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SupercineColors.brand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              minimumSize: const Size(0, 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .pushNamed('/detail', arguments: meta),
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: const Text('Detalhes'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black38,
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              minimumSize: const Size(0, 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Indisponível ribbon
                if (!meta.available)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Transform.rotate(
                      angle: -math.pi / 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SupercineColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Indisponível',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;
  final ValueChanged<int> onTap;

  const _Dots({
    required this.count,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? SupercineColors.brand
                  : SupercineColors.textMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
