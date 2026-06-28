import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/home_response.dart';
import '../models/movie_meta.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/horizontal_poster_list.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/states.dart';

/// Tela inicial — banner rotativo + 4 linhas de destaque da home
/// (Lançamentos, Destaques, Recentes, Sugeridos) usando o endpoint
/// `GET /v1/catalog/home` da Output API v1.4.0.
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
        store.loadHomeMovies();
        store.loadHomeTv();
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

    return Scaffold(
      body: RefreshIndicator(
        color: SupercineColors.brand,
        onRefresh: () async {
          await Future.wait([
            store.loadHomeMovies(force: true),
            store.loadHomeTv(force: true),
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
            // Hero — montado a partir dos Lançamentos de filmes + Destaques de séries
            SliverToBoxAdapter(
              child: _HeroArea(store: store),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // 4 linhas de FILMES (Lançamentos, Destaques, Recentes, Sugeridos)
            ..._homeRowsSlivers(
              response: store.homeMovies,
              loading: store.isLoadingHomeMovies,
              error: store.homeMoviesError,
              onRetry: () => store.loadHomeMovies(force: true),
              emptyFallback: store.popularMovies,
              emptyLoading: store.isLoadingMovies,
              emptyError: store.moviesError,
              onLoadFallback: () => store.loadPopularMovies(force: true),
              fallbackTitle: 'Filmes populares',
              seeAllRoute: '/movies',
              context: context,
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 4 linhas de SÉRIES
            ..._homeRowsSlivers(
              response: store.homeTv,
              loading: store.isLoadingHomeTv,
              error: store.homeTvError,
              onRetry: () => store.loadHomeTv(force: true),
              emptyFallback: store.popularTv,
              emptyLoading: store.isLoadingTv,
              emptyError: store.tvError,
              onLoadFallback: () => store.loadPopularTv(force: true),
              fallbackTitle: 'Séries populares',
              seeAllRoute: '/series',
              context: context,
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de slivers para uma HomeResponse.
  ///
  /// Se a resposta `/home` estiver vazia/erro, faz fallback para `/popular`.
  List<Widget> _homeRowsSlivers({
    required HomeResponse? response,
    required bool loading,
    required String? error,
    required VoidCallback onRetry,
    required List<MovieMeta>? emptyFallback,
    required bool emptyLoading,
    required String? emptyError,
    required VoidCallback onLoadFallback,
    required String fallbackTitle,
    required String seeAllRoute,
    required BuildContext context,
  }) {
    // Caminho feliz: temos linhas da home
    if (response != null && response.rows.isNotEmpty) {
      return response.rows
          .map((row) => _rowSliver(
                label: row.label.isNotEmpty ? row.label : row.category.name,
                items: row.items,
                seeAllRoute: seeAllRoute,
                fallbackTitle: fallbackTitle,
                isFallback: false,
              ))
          .toList();
    }

    // Carregando /home ainda
    if (loading) {
      return [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Carregando destaques…',
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            actionLabel: '',
            onAction: null,
          ),
        ),
        const SliverToBoxAdapter(child: _LoadingRow()),
      ];
    }

    // Erro no /home — tenta /popular como fallback
    if (emptyFallback == null || emptyFallback.isEmpty) {
      // Dispara o fallback uma vez
      WidgetsBinding.instance.addPostFrameCallback((_) => onLoadFallback());
      return [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: fallbackTitle,
            subtitle: 'Não foi possível carregar os destaques.',
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            onAction: () => Navigator.of(context).pushNamed(seeAllRoute),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 210,
            child: emptyLoading
                ? const Center(child: CircularProgressIndicator())
                : ErrorState(
                    message: error ?? emptyError ?? 'Erro desconhecido',
                    onRetry: onRetry,
                  ),
          ),
        ),
      ];
    }

    // Fallback para /popular
    return [
      _rowSliver(
        label: fallbackTitle,
        items: emptyFallback,
        seeAllRoute: seeAllRoute,
        fallbackTitle: fallbackTitle,
        isFallback: true,
      ),
    ];
  }

  Widget _rowSliver({
    required String label,
    required List<MovieMeta> items,
    required String seeAllRoute,
    required String fallbackTitle,
    required bool isFallback,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: label,
            subtitle: isFallback
                ? 'Destaque indisponível — mostrando $fallbackTitle'
                : null,
            onAction: items.isNotEmpty
                ? () => Navigator.of(context).pushNamed(seeAllRoute)
                : null,
          ),
          if (items.isEmpty)
            const SizedBox(
              height: 210,
              child: Center(
                child: Text('Nenhum título nesta categoria.',
                    style: TextStyle(color: SupercineColors.textMuted)),
              ),
            )
          else
            HorizontalPosterList(
              children: items.map((m) => MovieCard(meta: m)).toList(),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return HorizontalPosterList.loading();
  }
}

class _HeroArea extends StatelessWidget {
  final AppStore store;
  const _HeroArea({required this.store});

  @override
  Widget build(BuildContext context) {
    // Combina os Lançamentos de filmes com os Destaques de séries
    // para ter um hero variado (mix de filmes e séries).
    final moviesHome = store.homeMovies;
    final tvHome = store.homeTv;

    List<MovieMeta> moviesLancamentos = const [];
    List<MovieMeta> tvDestaques = const [];

    if (moviesHome != null && moviesHome.rows.isNotEmpty) {
      moviesLancamentos = moviesHome.rows.first.items;
    }
    if (tvHome != null && tvHome.rows.isNotEmpty) {
      // Pega a segunda linha (Destaques) das séries se existir, senão a primeira
      tvDestaques = tvHome.rows.length > 1
          ? tvHome.rows[1].items
          : tvHome.rows.first.items;
    }

    final heroItems = <MovieMeta>[
      ...moviesLancamentos.take(3),
      ...tvDestaques.take(3),
    ];

    if (heroItems.isEmpty) {
      // Fallback: usa populares
      final all = <MovieMeta>[
        if (store.popularMovies != null) ...store.popularMovies!,
        if (store.popularTv != null) ...store.popularTv!,
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
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: HeroBanner(items: filtered),
      );
    }

    // Filtra apenas itens com imagem
    final filtered = heroItems
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
