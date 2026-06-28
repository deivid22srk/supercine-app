/// Modelo de metadados de um título (filme ou série).
///
/// Retornado por `/v1/catalog/popular`, `/v1/catalog/search`,
/// `/v1/catalog/resolve` e como item de cada linha de `/v1/catalog/home`.
/// Veja `MovieMeta` e `HomeItem` na documentação da Output API v1.4.0.
class MovieMeta {
  final String imdb;
  final String type; // "movie" | "tv"
  final String embedType; // "movies" | "tvshows"
  final String titlePtbr;
  final String titleOrig;
  final int year;
  final String posterUrl;
  final String backdropUrl;
  final String cast;
  final int rank;
  final bool available;
  final int serverCount;
  final String provider;

  // Campos extras retornados por /v1/catalog/home (v1.4.0).
  // São opcionais — ausentes em /popular, /search e /resolve.
  final double imdbRating;
  final String runtime; // duração em minutos como string (ex: "96")
  final List<String> categories; // ["Crime", "Drama", ...]
  final String postId; // ID interno do post no Supercine

  const MovieMeta({
    required this.imdb,
    required this.type,
    required this.embedType,
    required this.titlePtbr,
    required this.titleOrig,
    required this.year,
    required this.posterUrl,
    required this.backdropUrl,
    required this.cast,
    required this.rank,
    required this.available,
    required this.serverCount,
    required this.provider,
    this.imdbRating = 0,
    this.runtime = '',
    this.categories = const [],
    this.postId = '',
  });

  factory MovieMeta.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    return MovieMeta(
      imdb: json['imdb'] as String? ?? '',
      type: json['type'] as String? ?? 'movie',
      embedType: json['embed_type'] as String? ?? 'movies',
      titlePtbr: json['title_ptbr'] as String? ?? '',
      titleOrig: json['title_orig'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      posterUrl: json['poster_url'] as String? ?? '',
      backdropUrl: json['backdrop_url'] as String? ?? '',
      cast: json['cast'] as String? ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? false,
      serverCount: (json['server_count'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String? ?? '',
      imdbRating: (json['imdb_rating'] as num?)?.toDouble() ?? 0,
      runtime: json['runtime']?.toString() ?? '',
      categories: rawCategories is List
          ? rawCategories
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList(growable: false)
          : const [],
      postId: json['post_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'imdb': imdb,
        'type': type,
        'embed_type': embedType,
        'title_ptbr': titlePtbr,
        'title_orig': titleOrig,
        'year': year,
        'poster_url': posterUrl,
        'backdrop_url': backdropUrl,
        'cast': cast,
        'rank': rank,
        'available': available,
        'server_count': serverCount,
        'provider': provider,
        if (imdbRating > 0) 'imdb_rating': imdbRating,
        if (runtime.isNotEmpty) 'runtime': runtime,
        if (categories.isNotEmpty) 'categories': categories,
        if (postId.isNotEmpty) 'post_id': postId,
      };

  /// Título a exibir: PT-BR se existir, senão original.
  String get displayTitle => titlePtbr.isNotEmpty ? titlePtbr : titleOrig;

  /// `true` se for série.
  bool get isTv => type == 'tv' || embedType == 'tvshows';

  /// `true` quando este item veio do endpoint `/v1/catalog/home`
  /// (carrega os campos extras `imdb_rating`, `runtime`, `categories`, `post_id`).
  bool get hasHomeExtras =>
      imdbRating > 0 ||
      runtime.isNotEmpty ||
      categories.isNotEmpty ||
      postId.isNotEmpty;

  /// Duração formatada em `1h 36min` ou vazio se não houver.
  String get runtimeFormatted {
    final mins = int.tryParse(runtime) ?? 0;
    if (mins <= 0) return '';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  /// Nota IMDB formatada com 1 casa decimal (ex: `8.4`), ou vazio.
  String get imdbRatingFormatted =>
      imdbRating > 0 ? imdbRating.toStringAsFixed(1) : '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MovieMeta && other.imdb == imdb);

  @override
  int get hashCode => imdb.hashCode;
}
