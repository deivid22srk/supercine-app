/// Modelo de metadados de um título (filme ou série).
///
/// Retornado por `/v1/catalog/popular`, `/v1/catalog/search` e
/// `/v1/catalog/resolve`. Veja `MovieMeta` na documentação da Output API.
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
  });

  factory MovieMeta.fromJson(Map<String, dynamic> json) {
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
      };

  /// Título a exibir: PT-BR se existir, senão original.
  String get displayTitle => titlePtbr.isNotEmpty ? titlePtbr : titleOrig;

  /// `true` se for série.
  bool get isTv => type == 'tv' || embedType == 'tvshows';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MovieMeta && other.imdb == imdb);

  @override
  int get hashCode => imdb.hashCode;
}
