import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie_meta.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/states.dart';

/// Tela "Filmes" — grid completo dos filmes populares.
class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<AppStore>();
      if (store.isConfigured) {
        store.loadPopularMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final items = store.popularMovies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: SupercineColors.brand,
        onRefresh: () => store.loadPopularMovies(force: true),
        child: _Body(items: items, store: store),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<MovieMeta>? items;
  final AppStore store;
  const _Body({required this.items, required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.isLoadingMovies && (items == null || items!.isEmpty)) {
      return const _GridShimmer();
    }
    if (store.moviesError != null &&
        (items == null || items!.isEmpty)) {
      return ErrorState(
        message: store.moviesError!,
        onRetry: () => store.loadPopularMovies(force: true),
      );
    }
    if (items == null || items!.isEmpty) {
      return EmptyState(
        icon: Icons.movie_outlined,
        title: 'Nenhum filme encontrado',
        subtitle: 'Verifique sua conexão e tente novamente.',
        actionLabel: 'Recarregar',
        onAction: () => store.loadPopularMovies(force: true),
      );
    }

    final available = items!.where((m) => m.available).toList();
    final unavailable = items!.where((m) => !m.available).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Disponíveis agora',
            subtitle: '${available.length} títulos prontos para assistir',
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          ),
        ),
        if (available.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum filme disponível no momento.'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 130,
                childAspectRatio: 0.52,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => MovieCard(meta: available[i], width: 130),
                childCount: available.length,
              ),
            ),
          ),
        if (unavailable.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Em breve / indisponíveis',
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 130,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => MovieCard(meta: unavailable[i], width: 130),
                childCount: unavailable.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemCount: 12,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: SupercineColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
