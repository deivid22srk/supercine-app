import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_meta.dart';

/// Persistência local de favoritos usando `SharedPreferences`.
///
/// Cada favorito é armazenado como JSON em uma lista serializada sob a
/// chave `favorites.v1`. O `imdb` é usado como identificador único.
class FavoritesService {
  static const _key = 'favorites.v1';

  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  /// Lista todos os favoritos (do mais recente para o mais antigo).
  List<MovieMeta> all() {
    final raw = _prefs.getStringList(_key) ?? const [];
    return raw
        .map((s) {
          try {
            return MovieMeta.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<MovieMeta>()
        .toList(growable: false);
  }

  bool isFavorite(String imdb) {
    return all().any((m) => m.imdb == imdb);
  }

  /// Adiciona um favorito. Se já existir, move para o topo.
  void add(MovieMeta meta) {
    final list = all()..removeWhere((m) => m.imdb == meta.imdb);
    list.insert(0, meta);
    _save(list);
  }

  void remove(String imdb) {
    final list = all()..removeWhere((m) => m.imdb == imdb);
    _save(list);
  }

  void toggle(MovieMeta meta) {
    if (isFavorite(meta.imdb)) {
      remove(meta.imdb);
    } else {
      add(meta);
    }
  }

  void _save(List<MovieMeta> list) {
    final raw = list.map((m) => jsonEncode(m.toJson())).toList();
    _prefs.setStringList(_key, raw);
  }
}
