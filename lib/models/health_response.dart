/// Resposta de `/v1/health`.
class HealthResponse {
  final String status;
  final String version;
  final String upstream;
  final int cache;

  const HealthResponse({
    required this.status,
    required this.version,
    required this.upstream,
    required this.cache,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) => HealthResponse(
        status: json['status'] as String? ?? 'unknown',
        version: json['version'] as String? ?? '',
        upstream: json['upstream'] as String? ?? '',
        cache: (json['cache'] as num?)?.toInt() ?? 0,
      );
}

/// Erro padronizado retornado pela API.
class ApiError {
  final String message;
  final int? statusCode;
  final String? imdb;
  final String? type;

  const ApiError({
    required this.message,
    this.statusCode,
    this.imdb,
    this.type,
  });

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiError(
      message: json['error'] as String? ?? 'Erro desconhecido',
      statusCode: statusCode,
      imdb: json['imdb'] as String?,
      type: json['type'] as String?,
    );
  }

  @override
  String toString() => message;
}
