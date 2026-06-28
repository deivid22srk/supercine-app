/// Episódio de uma temporada (retornado por `/v1/seasons`).
class Episode {
  final int number;
  final String id;
  final String title;
  final String date;
  final String backdrop;

  const Episode({
    required this.number,
    required this.id,
    required this.title,
    required this.date,
    required this.backdrop,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        number: (json['number'] as num?)?.toInt() ?? 0,
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        date: json['date'] as String? ?? '',
        backdrop: json['backdrop'] as String? ?? '',
      );

  String get displayTitle => title.isNotEmpty ? title : 'Episódio $number';
}

/// Temporada de uma série.
class Season {
  final int number;
  final String id;
  final List<Episode> episodes;

  const Season({
    required this.number,
    required this.id,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    final raw = json['episodes'] as List? ?? const [];
    return Season(
      number: (json['number'] as num?)?.toInt() ?? 0,
      id: json['id']?.toString() ?? '',
      episodes: raw
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Resposta de `/v1/seasons`.
class SeasonsResponse {
  final String imdb;
  final String status;
  final int seasonCount;
  final List<Season> seasons;

  const SeasonsResponse({
    required this.imdb,
    required this.status,
    required this.seasonCount,
    required this.seasons,
  });

  factory SeasonsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['seasons'] as List? ?? const [];
    return SeasonsResponse(
      imdb: json['imdb'] as String? ?? '',
      status: json['status'] as String? ?? 'success',
      seasonCount: (json['season_count'] as num?)?.toInt() ?? raw.length,
      seasons: raw
          .map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
