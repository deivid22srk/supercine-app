import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/home_response.dart';
import '../models/movie_meta.dart';
import '../models/provider_info.dart';
import '../models/resolve_result.dart';
import '../models/seasons_response.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../services/settings_service.dart';

/// Estado global da aplicação exposto via `Provider`.
///
/// Mantém:
/// - configuração da API (URL base + toggle de proxy de stream)
/// - cache de populares (filmes e séries)
/// - cache de home (4 linhas de destaque, v1.4.0)
/// - favoritos
/// - provedores
class AppStore extends ChangeNotifier {
  final SettingsService settings;
  final FavoritesService favorites;
  late ApiService _api;

  AppStore({required this.settings, required this.favorites}) {
    _api = ApiService(config: settings.buildApiConfig());
  }

  ApiService get api => _api;

  // ===================== Configuração =====================

  String get baseUrl => settings.baseUrl;
  bool get isConfigured => baseUrl.isNotEmpty;

  /// `true` se as URLs de vídeo devem passar por `/v1/stream?url=...`.
  bool get useStreamProxy => settings.useStreamProxy;

  Future<void> setBaseUrl(String url) async {
    settings.baseUrl = url;
    _api = ApiService(config: ApiConfig(url));
    // Invalida caches ao trocar de servidor.
    _moviesCache = null;
    _tvCache = null;
    _homeMoviesCache = null;
    _homeTvCache = null;
    _providersCache = null;
    notifyListeners();
  }

  void setUseStreamProxy(bool value) {
    settings.useStreamProxy = value;
    notifyListeners();
  }

  /// Aplica o proxy de stream (se habilitado) a uma URL de vídeo.
  String resolveVideoUrl(String directUrl) {
    if (directUrl.isEmpty) return directUrl;
    if (useStreamProxy) return _api.streamUrl(directUrl);
    return directUrl;
  }

  // ===================== Cache populares =====================

  List<MovieMeta>? _moviesCache;
  List<MovieMeta>? _tvCache;
  bool _loadingMovies = false;
  bool _loadingTv = false;
  String? _moviesError;
  String? _tvError;

  List<MovieMeta>? get popularMovies => _moviesCache;
  List<MovieMeta>? get popularTv => _tvCache;
  bool get isLoadingMovies => _loadingMovies;
  bool get isLoadingTv => _loadingTv;
  String? get moviesError => _moviesError;
  String? get tvError => _tvError;

  Future<void> loadPopularMovies({bool force = false}) async {
    if (!force && (_moviesCache != null || _loadingMovies)) return;
    _loadingMovies = true;
    _moviesError = null;
    notifyListeners();
    try {
      _moviesCache = await _api.popular(type: 'movies', limit: 80);
    } catch (e) {
      _moviesError = e.toString();
      _moviesCache = const [];
    } finally {
      _loadingMovies = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularTv({bool force = false}) async {
    if (!force && (_tvCache != null || _loadingTv)) return;
    _loadingTv = true;
    _tvError = null;
    notifyListeners();
    try {
      _tvCache = await _api.popular(type: 'tvshows', limit: 80);
    } catch (e) {
      _tvError = e.toString();
      _tvCache = const [];
    } finally {
      _loadingTv = false;
      notifyListeners();
    }
  }

  // ===================== Cache home (v1.4.0) =====================

  HomeResponse? _homeMoviesCache;
  HomeResponse? _homeTvCache;
  bool _loadingHomeMovies = false;
  bool _loadingHomeTv = false;
  String? _homeMoviesError;
  String? _homeTvError;

  HomeResponse? get homeMovies => _homeMoviesCache;
  HomeResponse? get homeTv => _homeTvCache;
  bool get isLoadingHomeMovies => _loadingHomeMovies;
  bool get isLoadingHomeTv => _loadingHomeTv;
  String? get homeMoviesError => _homeMoviesError;
  String? get homeTvError => _homeTvError;

  Future<void> loadHomeMovies({bool force = false}) async {
    if (!force && (_homeMoviesCache != null || _loadingHomeMovies)) return;
    _loadingHomeMovies = true;
    _homeMoviesError = null;
    notifyListeners();
    try {
      _homeMoviesCache = await _api.home(type: 'movies');
    } catch (e) {
      _homeMoviesError = e.toString();
      _homeMoviesCache = null;
    } finally {
      _loadingHomeMovies = false;
      notifyListeners();
    }
  }

  Future<void> loadHomeTv({bool force = false}) async {
    if (!force && (_homeTvCache != null || _loadingHomeTv)) return;
    _loadingHomeTv = true;
    _homeTvError = null;
    notifyListeners();
    try {
      _homeTvCache = await _api.home(type: 'tvshows');
    } catch (e) {
      _homeTvError = e.toString();
      _homeTvCache = null;
    } finally {
      _loadingHomeTv = false;
      notifyListeners();
    }
  }

  // ===================== Providers =====================

  List<ProviderInfo>? _providersCache;
  String? _providersError;

  List<ProviderInfo>? get providers => _providersCache;
  String? get providersError => _providersError;

  Future<void> loadProviders({bool force = false}) async {
    if (!force && _providersCache != null) return;
    try {
      _providersCache = await _api.providers().then((r) => r.providers);
      _providersError = null;
    } catch (e) {
      _providersError = e.toString();
    }
    notifyListeners();
  }

  // ===================== Busca =====================

  List<MovieMeta> _searchResults = const [];
  bool _searching = false;
  String? _searchError;

  List<MovieMeta> get searchResults => _searchResults;
  bool get isSearching => _searching;
  String? get searchError => _searchError;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = const [];
      _searchError = null;
      notifyListeners();
      return;
    }
    _searching = true;
    _searchError = null;
    notifyListeners();
    try {
      _searchResults = await _api.search(query, limit: 30);
    } catch (e) {
      _searchError = e.toString();
      _searchResults = const [];
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  // ===================== Favoritos =====================

  List<MovieMeta> get favoriteList => favorites.all();

  bool isFavorite(String imdb) => favorites.isFavorite(imdb);

  void toggleFavorite(MovieMeta meta) {
    favorites.toggle(meta);
    notifyListeners();
  }

  void removeFavorite(String imdb) {
    favorites.remove(imdb);
    notifyListeners();
  }

  // ===================== Resolução de vídeo =====================

  Future<ResolveResult> resolveMovie(String imdb,
          {String type = 'movies'}) =>
      _api.resolveVideo(imdb, type: type);

  Future<ResolveResult> resolveEpisode(
          String imdb, int season, int episode) =>
      _api.resolveEpisode(imdb, season: season, episode: episode);

  Future<SeasonsResponse> loadSeasons(String imdb) => _api.seasons(imdb);
}
