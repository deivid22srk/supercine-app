/// Servidor disponível para um título resolvido.
class Server {
  final int index;
  final String name;
  final String description;

  const Server({
    required this.index,
    required this.name,
    required this.description,
  });

  factory Server.fromJson(Map<String, dynamic> json) => Server(
        index: (json['index'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  /// `true` quando a descrição começa com `[OK]` — indica o servidor
  /// que de fato funcionou na extração.
  bool get isOk => description.trim().toLowerCase().startsWith('[ok]');
}

/// URL direta de vídeo (mp4 ou m3u8).
class VideoUrl {
  final String url;
  final String quality;

  const VideoUrl({required this.url, required this.quality});

  factory VideoUrl.fromJson(Map<String, dynamic> json) => VideoUrl(
        url: json['url'] as String? ?? '',
        quality: json['quality'] as String? ?? 'Normal',
      );

  /// `true` se for um stream HLS.
  bool get isHls =>
      url.toLowerCase().endsWith('.m3u8') ||
      quality.toLowerCase().contains('hls');
}

/// Resposta de `/v1/resolve` e `/v1/resolveEpisode`.
class ResolveResult {
  final String provider;
  final String imdb;
  final String type;
  final int? season;
  final int? episode;
  final List<Server> servers;
  final List<VideoUrl> videos;

  const ResolveResult({
    required this.provider,
    required this.imdb,
    required this.type,
    this.season,
    this.episode,
    required this.servers,
    required this.videos,
  });

  factory ResolveResult.fromJson(Map<String, dynamic> json) {
    final rawServers = json['servers'] as List? ?? const [];
    final rawVideos = json['videos'] as List? ?? const [];
    return ResolveResult(
      provider: json['provider'] as String? ?? '',
      imdb: json['imdb'] as String? ?? '',
      type: json['type'] as String? ?? 'movies',
      season: (json['season'] as num?)?.toInt(),
      episode: (json['episode'] as num?)?.toInt(),
      servers: rawServers
          .map((e) => Server.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      videos: rawVideos
          .map((e) => VideoUrl.fromJson(e as Map<String, dynamic>))
          .where((v) => v.url.isNotEmpty)
          .toList(growable: false),
    );
  }

  bool get hasVideos => videos.isNotEmpty;
}
