/// Exceção lançada pela camada de serviço ao falar com a API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? upstreamError;

  const ApiException(this.message, {this.statusCode, this.upstreamError});

  factory ApiException.fromBody(String body, int statusCode) {
    String msg;
    String? upstream;
    try {
      // Tenta interpretar como JSON {"error": "..."}
      final idx = body.indexOf('"error"');
      if (idx >= 0) {
        final colon = body.indexOf(':', idx);
        final start = body.indexOf('"', colon);
        final end = body.indexOf('"', start + 1);
        if (start >= 0 && end > start) {
          msg = body.substring(start + 1, end);
        } else {
          msg = body;
        }
      } else {
        msg = body;
      }
    } catch (_) {
      msg = body;
      upstream = null;
    }
    return ApiException(
      msg.isEmpty ? 'Erro $statusCode' : msg,
      statusCode: statusCode,
      upstreamError: upstream,
    );
  }

  /// `true` quando o servidor respondeu que o título não está disponível
  /// em nenhum provedor (sentinela `provider: title not available`).
  bool get isTitleUnavailable =>
      message.contains('title not available') ||
      message.contains('no provider registered');

  /// `true` quando o provedor está offline (sentinela
  /// `provider: upstream unreachable`).
  bool get isUpstreamUnreachable =>
      message.contains('upstream unreachable') ||
      statusCode == 502 ||
      statusCode == 503;

  @override
  String toString() => message;
}
