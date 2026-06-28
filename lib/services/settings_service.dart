import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Persiste as preferências do usuário (URL base, toggle de proxy, etc).
class SettingsService {
  static const _baseUrlKey = 'api.base_url.v1';
  static const _defaultTypeKey = 'settings.default_type.v1';
  static const _lastProviderKey = 'settings.last_provider.v1';
  static const _useStreamProxyKey = 'settings.use_stream_proxy.v2';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  String get baseUrl => _prefs.getString(_baseUrlKey) ?? '';
  set baseUrl(String value) => _prefs.setString(_baseUrlKey, value);

  /// "movies" ou "tvshows" — qual categoria mostrar primeiro na Home.
  String get defaultType => _prefs.getString(_defaultTypeKey) ?? 'movies';
  set defaultType(String value) => _prefs.setString(_defaultTypeKey, value);

  /// Último provedor usado (vazio = automático).
  String get lastProvider => _prefs.getString(_lastProviderKey) ?? '';
  set lastProvider(String value) => _prefs.setString(_lastProviderKey, value);

  /// Quando `true`, repassa URLs de vídeo por `/v1/stream?url=...` antes
  /// de enviar ao player.
  ///
  /// **Padrão: `true`** (desde a v1.1.1). Na prática os CDNs dos hosters
  /// (MixDrop, StreamWish, VidHide) rejeitam qualquer requisição direta
  /// com 403 — não apenas por `Origin` estrangeiro, mas também por IP/
  /// token. O proxy `/v1/stream` resolve isso server-side enviando os
  /// headers corretos. Sem ele, o player mostra "Nenhuma fonte
  /// disponível".
  ///
  /// Só desligue se você souber exatamente o que está fazendo.
  bool get useStreamProxy {
    // Se a chave nunca foi escrita, default = true.
    if (!_prefs.containsKey(_useStreamProxyKey)) return true;
    return _prefs.getBool(_useStreamProxyKey) ?? true;
  }

  set useStreamProxy(bool value) =>
      _prefs.setBool(_useStreamProxyKey, value);

  /// Constrói a configuração atual da API.
  ApiConfig buildApiConfig() => ApiConfig(baseUrl);
}
