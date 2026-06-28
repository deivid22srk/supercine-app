import 'movie_meta.dart';

/// Categoria de uma linha de destaque da home (v1.4.0).
enum HomeCategory {
  lancamentos,
  destaques,
  recentes,
  sugeridos,
  unknown;

  static HomeCategory fromString(String? s) {
    switch (s) {
      case 'lancamentos':
        return HomeCategory.lancamentos;
      case 'destaques':
        return HomeCategory.destaques;
      case 'recentes':
        return HomeCategory.recentes;
      case 'sugeridos':
        return HomeCategory.sugeridos;
      default:
        return HomeCategory.unknown;
    }
  }
}

/// Uma linha da home (Lançamentos / Destaques / Recentes / Sugeridos).
class HomeRow {
  final HomeCategory category;
  final String label;
  final int count;
  final List<MovieMeta> items;

  const HomeRow({
    required this.category,
    required this.label,
    required this.count,
    required this.items,
  });

  factory HomeRow.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? const [];
    return HomeRow(
      category: HomeCategory.fromString(json['category'] as String?),
      label: json['label'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? rawItems.length,
      items: rawItems
          .map((e) => MovieMeta.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Resposta de `GET /v1/catalog/home` (v1.4.0).
///
/// Retorna 4 linhas de destaque (Lançamentos, Destaques, Recentes,
/// Sugeridos) com 12 itens cada. Diferente do `/popular`, espelha
/// exatamente a home do app original do Supercine.
class HomeResponse {
  final String type; // "movies" | "tvshows"
  final int count; // sempre 4
  final List<HomeRow> rows;

  const HomeResponse({
    required this.type,
    required this.count,
    required this.rows,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['rows'] as List? ?? const [];
    return HomeResponse(
      type: json['type'] as String? ?? 'movies',
      count: (json['count'] as num?)?.toInt() ?? raw.length,
      rows: raw
          .map((e) => HomeRow.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
