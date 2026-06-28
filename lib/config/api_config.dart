import 'api_exception.dart';

/// Configuração da API. A URL base é fornecida pelo usuário na tela de
/// configurações e persistida em `SharedPreferences`.
class ApiConfig {
  static const _defaultTimeout = Duration(seconds: 30);
  static const popularTimeout = Duration(seconds: 90);
  static const searchTimeout = Duration(seconds: 60);
  static const resolveTimeout = Duration(seconds: 45);
  static const seasonsTimeout = Duration(seconds: 30);
  static const providersTimeout = Duration(seconds: 10);

  String _baseUrl;

  ApiConfig(this._baseUrl);

  factory ApiConfig.empty() => ApiConfig('');

  String get baseUrl => _baseUrl;
  bool get isConfigured => _baseUrl.isNotEmpty;

  set baseUrl(String value) {
    var v = value.trim();
    // remove trailing slash
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    _baseUrl = v;
  }

  /// Monta a URL completa de um endpoint.
  ///
  /// Ex: `url('/v1/catalog/popular', {'type': 'movies'})` ->
  /// `https://host/v1/catalog/popular?type=movies`.
  String url(String path, [Map<String, dynamic>? query]) {
    if (!isConfigured) {
      throw ApiException(
        'URL base da API não configurada. Abra Configurações e informe a URL do proxy.',
      );
    }
    var full = '$_baseUrl${path.startsWith('/') ? path : '/$path'}';
    if (query != null && query.isNotEmpty) {
      final qs = query.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      if (qs.isNotEmpty) full += '?$qs';
    }
    return full;
  }

  Duration get defaultTimeout => _defaultTimeout;
}
