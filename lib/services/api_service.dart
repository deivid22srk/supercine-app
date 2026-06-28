import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/api_exception.dart';
import '../models/catalog_response.dart';
import '../models/health_response.dart';
import '../models/movie_meta.dart';
import '../models/provider_info.dart';
import '../models/resolve_result.dart';
import '../models/seasons_response.dart';

/// Cliente da Output API do Supercine Proxy (v1.3.0).
///
/// Todos os métodos lançam [ApiException] em caso de erro.
class ApiService {
  final ApiConfig config;
  final http.Client _client;

  ApiService({required this.config, http.Client? client})
      : _client = client ?? http.Client();

  /// Executa um GET na API, decodificando o JSON e tratando erros.
  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, dynamic> query, {
    Duration? timeout,
  }) async {
    final uri = Uri.parse(config.url(path, query));
    final res = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(timeout ?? config.defaultTimeout);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw ApiException.fromBody(res.body, res.statusCode);
  }

  // ============== Health ==============

  /// `GET /v1/health` — verifica se o proxy está online.
  Future<HealthResponse> health() async {
    final json = await _get('/v1/health', const {}, timeout: ApiConfig.providersTimeout);
    return HealthResponse.fromJson(json);
  }

  // ============== Providers ==============

  /// `GET /v1/providers` — lista provedores registrados.
  Future<ProvidersResponse> providers() async {
    final json = await _get('/v1/providers', const {});
    return ProvidersResponse.fromJson(json);
  }

  // ============== Catalog ==============

  /// `GET /v1/catalog/popular?type=<movies|tvshows>&limit=N`
  Future<List<MovieMeta>> popular({
    String type = 'movies',
    int limit = 80,
  }) async {
    final json = await _get('/v1/catalog/popular', {
      'type': type,
      'limit': limit.toString(),
    }, timeout: ApiConfig.popularTimeout);
    return CatalogResponse.fromJson(json).items;
  }

  /// `GET /v1/catalog/search?q=<texto>&limit=N`
  Future<List<MovieMeta>> search(String query, {int limit = 12}) async {
    if (query.trim().isEmpty) {
      throw const ApiException('Informe um termo para buscar.');
    }
    final json = await _get('/v1/catalog/search', {
      'q': query,
      'limit': limit.toString(),
    }, timeout: ApiConfig.searchTimeout);
    return CatalogResponse.fromJson(json).items;
  }

  /// `GET /v1/catalog/resolve?imdb=<tt...>&type=<movies|tvshows>`
  Future<MovieMeta> resolve(String imdb, {String type = 'movies'}) async {
    final json = await _get('/v1/catalog/resolve', {
      'imdb': imdb,
      'type': type,
    }, timeout: ApiConfig.seasonsTimeout);
    return MovieMeta.fromJson(json);
  }

  // ============== Video resolution ==============

  /// `GET /v1/resolve?imdb=<tt...>&type=<movies|tvshows>`
  ///
  /// Retorna URLs diretas de vídeo para um filme.
  Future<ResolveResult> resolveVideo(
    String imdb, {
    String type = 'movies',
    String? provider,
  }) async {
    final json = await _get('/v1/resolve', {
      'imdb': imdb,
      'type': type,
      if (provider != null && provider.isNotEmpty) 'provider': provider,
    }, timeout: ApiConfig.resolveTimeout);
    return ResolveResult.fromJson(json);
  }

  /// `GET /v1/resolveEpisode?imdb=<tt...>&season=N&episode=N`
  ///
  /// Retorna URLs diretas de vídeo para um episódio de série.
  Future<ResolveResult> resolveEpisode(
    String imdb, {
    required int season,
    required int episode,
    String? provider,
  }) async {
    final json = await _get('/v1/resolveEpisode', {
      'imdb': imdb,
      'season': season.toString(),
      'episode': episode.toString(),
      if (provider != null && provider.isNotEmpty) 'provider': provider,
    }, timeout: ApiConfig.resolveTimeout);
    return ResolveResult.fromJson(json);
  }

  // ============== Seasons ==============

  /// `GET /v1/seasons?imdb=<tt...>`
  Future<SeasonsResponse> seasons(String imdb) async {
    final json = await _get('/v1/seasons', {
      'imdb': imdb,
    }, timeout: ApiConfig.seasonsTimeout);
    return SeasonsResponse.fromJson(json);
  }

  void dispose() {
    _client.close();
  }
}
