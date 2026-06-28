import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Persiste a URL base da API configurada pelo usuário.
class SettingsService {
  static const _baseUrlKey = 'api.base_url.v1';
  static const _defaultTypeKey = 'settings.default_type.v1';
  static const _lastProviderKey = 'settings.last_provider.v1';

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

  /// Constrói a configuração atual da API.
  ApiConfig buildApiConfig() => ApiConfig(baseUrl);
}
