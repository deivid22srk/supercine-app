/// Informações sobre um provedor (retornadas por `/v1/providers`).
class ProviderInfo {
  final String name;
  final String displayName;
  final int priority;
  final bool healthy;

  const ProviderInfo({
    required this.name,
    required this.displayName,
    required this.priority,
    required this.healthy,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) => ProviderInfo(
        name: json['name'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        priority: (json['priority'] as num?)?.toInt() ?? 0,
        healthy: json['healthy'] as bool? ?? false,
      );
}

class ProvidersResponse {
  final int count;
  final List<ProviderInfo> providers;

  const ProvidersResponse({required this.count, required this.providers});

  factory ProvidersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['providers'] as List? ?? const [];
    return ProvidersResponse(
      count: (json['count'] as num?)?.toInt() ?? raw.length,
      providers: raw
          .map((e) => ProviderInfo.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
