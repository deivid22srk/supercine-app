import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_exception.dart';
import '../models/movie_meta.dart';
import '../models/resolve_result.dart';
import '../models/seasons_response.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/network_image_box.dart';
import '../widgets/section_header.dart';
import '../widgets/states.dart';

/// Tela de detalhes de um título.
///
/// - Para filmes: backdrop, sinopse, elenco, botão "Assistir".
/// - Para séries: lista de temporadas + episódios, com botão "Assistir"
///   em cada episódio.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MovieMeta? _metaArg;
  bool _loadingResolve = false;
  String? _resolveError;
  ResolveResult? _resolveResult;

  // Séries
  SeasonsResponse? _seasons;
  bool _loadingSeasons = false;
  String? _seasonsError;
  int _selectedSeason = 1;
  bool _seasonsLoaded = false;

  MovieMeta get _meta => _metaArg!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_metaArg != null) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is MovieMeta) {
      _metaArg = arg;
      _maybeLoadSeasons();
    }
  }

  void _maybeLoadSeasons() {
    if (!_meta.isTv) return;
    if (_seasonsLoaded) return;
    _seasonsLoaded = true;
    final store = context.read<AppStore>();
    setState(() {
      _loadingSeasons = true;
      _seasonsError = null;
    });
    store.loadSeasons(_meta.imdb).then((s) {
      if (!mounted) return;
      setState(() {
        _seasons = s;
        _loadingSeasons = false;
        if (s.seasons.isNotEmpty) {
          _selectedSeason = s.seasons.first.number;
        }
      });
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _seasonsError = e.toString();
        _loadingSeasons = false;
      });
    });
  }

  Future<void> _playMovie() async {
    final store = context.read<AppStore>();
    setState(() {
      _loadingResolve = true;
      _resolveError = null;
    });
    try {
      final result = await store.resolveMovie(
        _meta.imdb,
        type: _meta.embedType,
      );
      if (!result.hasVideos) {
        setState(() {
          _resolveError =
              'Nenhuma URL de vídeo retornada. Tente outro servidor.';
          _loadingResolve = false;
        });
        return;
      }
      if (!mounted) return;
      setState(() => _loadingResolve = false);
      Navigator.of(context).pushNamed(
        '/player',
        arguments: PlayerArgs(
          videos: result.videos,
          title: _meta.displayTitle,
          subtitle: _meta.year > 0 ? _meta.year.toString() : null,
          servers: result.servers
              .map((s) => ServerOption(name: s.name, description: s.description))
              .toList(),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        _resolveError = e.message;
        _loadingResolve = false;
      });
    } catch (e) {
      setState(() {
        _resolveError = e.toString();
        _loadingResolve = false;
      });
    }
  }

  Future<void> _playEpisode(int season, int episode,
      {String? epTitle}) async {
    final store = context.read<AppStore>();
    setState(() {
      _loadingResolve = true;
      _resolveError = null;
    });
    try {
      final result =
          await store.resolveEpisode(_meta.imdb, season, episode);
      if (!result.hasVideos) {
        setState(() {
          _resolveError =
              'Nenhuma URL de vídeo retornada para o episódio.';
          _loadingResolve = false;
        });
        return;
      }
      if (!mounted) return;
      setState(() => _loadingResolve = false);
      Navigator.of(context).pushNamed(
        '/player',
        arguments: PlayerArgs(
          videos: result.videos,
          title: _meta.displayTitle,
          subtitle:
              'T$season E$episode${epTitle != null && epTitle.isNotEmpty ? ' • $epTitle' : ''}',
          servers: result.servers
              .map((s) => ServerOption(
                  name: s.name, description: s.description))
              .toList(),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        _resolveError = e.message;
        _loadingResolve = false;
      });
    } catch (e) {
      setState(() {
        _resolveError = e.toString();
        _loadingResolve = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_metaArg == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Nenhum título selecionado.',
              style: TextStyle(color: SupercineColors.textMuted)),
        ),
      );
    }
    final store = context.watch<AppStore>();
    final fav = store.isFavorite(_meta.imdb);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Backdrop + ações
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            backgroundColor: SupercineColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? SupercineColors.danger : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => store.toggleFavorite(_meta),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'poster_${_meta.imdb}',
                    child: NetworkImageBox(
                      url: _meta.backdropUrl.isNotEmpty
                          ? _meta.backdropUrl
                          : _meta.posterUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0x00000000),
                          Color(0xE6000000),
                        ],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        _meta.isTv ? 'SÉRIE' : 'FILME',
                        color: SupercineColors.brand,
                      ),
                      if (_meta.year > 0) _Chip(_meta.year.toString()),
                      if (_meta.available)
                        const _Chip('Disponível',
                            color: SupercineColors.success)
                      else
                        const _Chip('Indisponível',
                            color: SupercineColors.warning),
                      if (_meta.serverCount > 0)
                        _Chip('${_meta.serverCount} servidores'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Título
                  Text(
                    _meta.displayTitle,
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                  ),
                  if (_meta.titleOrig.isNotEmpty &&
                      _meta.titleOrig != _meta.displayTitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      _meta.titleOrig,
                      style: const TextStyle(
                        color: SupercineColors.textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Botões
                  if (!_meta.isTv)
                    _PlayButton(
                      available: _meta.available,
                      loading: _loadingResolve,
                      onPressed: _playMovie,
                    ),
                  if (_resolveError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SupercineColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              SupercineColors.danger.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: SupercineColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _resolveError!,
                              style: const TextStyle(
                                color: SupercineColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  // Sinopse (não há na API; mostramos info de elenco/ano)
                  SectionHeader(
                    title: 'Sobre',
                    padding: EdgeInsets.zero,
                    actionLabel: '',
                    onAction: null,
                  ),
                  const SizedBox(height: 8),
                  _InfoTable(meta: _meta),
                  if (_meta.cast.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Elenco',
                      style: TextStyle(
                        color: SupercineColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _meta.cast,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Séries: temporadas + episódios
          if (_meta.isTv) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Temporadas',
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                actionLabel: '',
                onAction: null,
              ),
            ),
            SliverToBoxAdapter(
              child: _SeasonsTabs(
                seasons: _seasons?.seasons ?? const [],
                loading: _loadingSeasons,
                error: _seasonsError,
                selected: _selectedSeason,
                onSelect: (n) => setState(() => _selectedSeason = n),
                onRetry: _maybeLoadSeasons,
              ),
            ),
            if (_seasons != null)
              ..._seasons!.seasons
                  .where((s) => s.number == _selectedSeason)
                  .expand((s) => s.episodes)
                  .map((e) => SliverToBoxAdapter(
                        child: _EpisodeTile(
                          episode: e,
                          season: _selectedSeason,
                          onTap: () => _playEpisode(_selectedSeason, e.number,
                              epTitle: e.title),
                          loading: _loadingResolve,
                        ),
                      ))
                  ,
            if (_seasons != null &&
                _seasons!.seasons
                    .where((s) => s.number == _selectedSeason)
                    .expand((s) => s.episodes)
                    .isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Nenhum episódio nesta temporada.',
                      style: TextStyle(color: SupercineColors.textMuted),
                    ),
                  ),
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  const _Chip(this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? SupercineColors.surfaceAlt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == null ? SupercineColors.textPrimary : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool available;
  final bool loading;
  final VoidCallback onPressed;
  const _PlayButton({
    required this.available,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (available && !loading) ? onPressed : null,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.play_arrow_rounded, size: 22),
        label: Text(
          available ? 'Assistir agora' : 'Indisponível',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: SupercineColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SupercineColors.surfaceAlt,
          disabledForegroundColor: SupercineColors.textMuted,
        ),
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  final MovieMeta meta;
  const _InfoTable({required this.meta});

  @override
  Widget build(BuildContext context) {
    final rows = <_Row>[];
    if (meta.year > 0) rows.add(_Row('Ano', meta.year.toString()));
    if (meta.type.isNotEmpty) {
      rows.add(_Row('Tipo', meta.isTv ? 'Série' : 'Filme'));
    }
    rows.add(_Row('IMDB', meta.imdb));
    if (meta.provider.isNotEmpty) {
      rows.add(_Row('Provedor', meta.provider));
    }
    if (meta.rank > 0) {
      rows.add(_Row('Popularidade IMDB', '#${meta.rank}'));
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SupercineColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SupercineColors.divider),
      ),
      child: Column(
        children: rows
            .map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          r.label,
                          style: const TextStyle(
                              color: SupercineColors.textMuted, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r.value,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  _Row(this.label, this.value);
}

class _SeasonsTabs extends StatelessWidget {
  final List<dynamic> seasons;
  final bool loading;
  final String? error;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onRetry;

  const _SeasonsTabs({
    required this.seasons,
    required this.loading,
    required this.error,
    required this.selected,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return SizedBox(
        height: 140,
        child: ErrorState(message: error!, onRetry: onRetry),
      );
    }
    if (seasons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text('Nenhuma temporada encontrada.',
            style: TextStyle(color: SupercineColors.textMuted)),
      );
    }
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: seasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = seasons[i];
          final isSel = (s.number as int) == selected;
          return ActionChip(
            label: Text('Temporada ${s.number}'),
            onPressed: () => onSelect(s.number as int),
            backgroundColor: isSel
                ? SupercineColors.brand
                : SupercineColors.surfaceAlt,
            labelStyle: TextStyle(
              color: isSel ? Colors.white : SupercineColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final dynamic episode;
  final int season;
  final VoidCallback onTap;
  final bool loading;
  const _EpisodeTile({
    required this.episode,
    required this.season,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final number = episode.number as int;
    final title = (episode.title as String).isNotEmpty
        ? episode.title as String
        : 'Episódio $number';
    final date = episode.date as String;
    final backdrop = episode.backdrop as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: SupercineColors.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 130,
                        height: 74,
                        child: backdrop.isNotEmpty
                            ? NetworkImageBox(
                                url: backdrop,
                                width: 130,
                                height: 74,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: SupercineColors.surfaceAlt,
                                alignment: Alignment.center,
                                child: const Icon(Icons.tv_rounded,
                                    color: SupercineColors.textMuted),
                              ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          alignment: Alignment.center,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: SupercineColors.brand,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'T$season E$number',
                        style: const TextStyle(
                          color: SupercineColors.brand,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (date.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: const TextStyle(
                              color: SupercineColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ],
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

class PlayerArgs {
  final List<dynamic> videos;
  final String title;
  final String? subtitle;
  final List<ServerOption> servers;
  const PlayerArgs({
    required this.videos,
    required this.title,
    this.subtitle,
    required this.servers,
  });
}

class ServerOption {
  final String name;
  final String description;
  const ServerOption({required this.name, required this.description});
}
