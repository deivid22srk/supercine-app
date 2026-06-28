import 'movie_meta.dart';

/// Resposta de `/v1/catalog/popular` e `/v1/catalog/search`.
class CatalogResponse {
  final String? type;
  final String? query;
  final int count;
  final List<MovieMeta> items;

  const CatalogResponse({
    this.type,
    this.query,
    required this.count,
    required this.items,
  });

  factory CatalogResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? const [];
    return CatalogResponse(
      type: json['type'] as String?,
      query: json['query'] as String?,
      count: (json['count'] as num?)?.toInt() ?? rawItems.length,
      items: rawItems
          .map((e) => MovieMeta.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
