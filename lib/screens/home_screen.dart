import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_meta.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/horizontal_poster_list.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/states.dart';

/// Tela inicial — banner rotativo + seções horizontais (filmes e séries).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<AppStore>();
      if (store.isConfigured) {
        store.loadPopularMovies();
        store.loadPopularTv();
        store.loadProviders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    if (!store.isConfigured) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.settings_input_antenna_rounded,
          title: 'Configure a API',
          subtitle:
              'Toque no ícone de engrenagem no topo e informe a URL base do proxy Supercine para começar a assistir.',
          actionLabel: 'Abrir configurações',
          onAction: () => Navigator.of(context).pushNamed('/settings'),
        ),
      );
    }

    final movies = store.popularMovies;
    final series = store.popularTv;

    return Scaffold(
      body: RefreshIndicator(
        color: SupercineColors.brand,
        onRefresh: () async {
          await Future.wait([
            store.loadPopularMovies(force: true),
            store.loadPopularTv(force: true),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              toolbarHeight: 64,
              backgroundColor: SupercineColors.background,
              surfaceTintColor: Colors.transparent,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: SupercineTheme.brandGradient,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Supercine',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Buscar',
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/search'),
                ),
                IconButton(
                  tooltip: 'Configurações',
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings'),
                ),
                const SizedBox(width: 4),
              ],
            ),
            // Hero
            SliverToBoxAdapter(
              child: _HeroArea(movies: movies, series: series),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            // Filmes populares
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Filmes populares',
                subtitle: 'Os títulos mais vistos da semana',
                onAction: movies != null && movies.isNotEmpty
                    ? () => Navigator.of(context).pushNamed('/movies')
                    : null,
              ),
            ),
            SliverToBoxAdapter(
              child: _PopularSection(
                loading: store.isLoadingMovies,
                error: store.moviesError,
                items: movies,
                onRetry: () => store.loadPopularMovies(force: true),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            // Séries populares
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Séries populares',
                subtitle: 'Maratone agora mesmo',
                onAction: series != null && series.isNotEmpty
                    ? () => Navigator.of(context).pushNamed('/series')
                    : null,
              ),
            ),
            SliverToBoxAdapter(
              child: _PopularSection(
                loading: store.isLoadingTv,
                error: store.tvError,
                items: series,
                onRetry: () => store.loadPopularTv(force: true),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _HeroArea extends StatelessWidget {
  final List<MovieMeta>? movies;
  final List<MovieMeta>? series;
  const _HeroArea({required this.movies, required this.series});

  @override
  Widget build(BuildContext context) {
    final all = <MovieMeta>[
      if (movies != null) ...movies!,
      if (series != null) ...series!,
    ];
    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 460,
            color: SupercineColors.surfaceAlt,
          ),
        ),
      );
    }
    final filtered = all
        .where((m) => m.backdropUrl.isNotEmpty || m.posterUrl.isNotEmpty)
        .take(6)
        .toList();
    if (filtered.isEmpty) {
      return const SizedBox(height: 460);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: HeroBanner(items: filtered),
    );
  }
}

class _PopularSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<MovieMeta>? items;
  final VoidCallback onRetry;

  const _PopularSection({
    required this.loading,
    required this.error,
    required this.items,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && (items == null || items!.isEmpty)) {
      return HorizontalPosterList.loading();
    }
    if (error != null && (items == null || items!.isEmpty)) {
      return SizedBox(
        height: 210,
        child: ErrorState(message: error!, onRetry: onRetry),
      );
    }
    if (items == null || items!.isEmpty) {
      return const SizedBox(height: 210);
    }
    return HorizontalPosterList(
      children: items!.map((m) => MovieCard(meta: m)).toList(),
    );
  }
}
