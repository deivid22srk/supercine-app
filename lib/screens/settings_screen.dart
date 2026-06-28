import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_exception.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/states.dart';

/// Tela de configurações — onde o usuário fornece a URL base da API.
///
/// Também mostra o status do proxy (health check) e dos provedores,
/// seguindo a aba "Config screen" escolhida pelo usuário.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _urlController =
        TextEditingController(text: context.read<AppStore>().baseUrl);
    _urlController.addListener(() {
      final current = context.read<AppStore>().baseUrl;
      setState(() => _hasChanges = _urlController.text.trim() != current);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testResult = 'Informe uma URL primeiro.';
        _testOk = false;
      });
      return;
    }
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      // Salva temporariamente e testa
      await context.read<AppStore>().setBaseUrl(url);
      final health = await context.read<AppStore>().api.health();
      final providers = await context.read<AppStore>().api.providers();
      setState(() {
        _testOk = true;
        _testResult =
            '✓ Conectado! Proxy v${health.version} • ${providers.count} provedor(es) ativo(s).';
      });
    } on ApiException catch (e) {
      setState(() {
        _testOk = false;
        _testResult = e.message;
      });
    } catch (e) {
      setState(() {
        _testOk = false;
        _testResult = e.toString();
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await context.read<AppStore>().setBaseUrl(url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL salva com sucesso.'),
          backgroundColor: SupercineColors.success,
        ),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'API do Supercine Proxy',
            subtitle:
                'Informe a URL base do proxy (ex: https://meu-proxy.com). '
                'Todas as chamadas são feitas para <URL>/v1/...',
            icon: Icons.dns_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    hintText: 'https://meu-proxy.com',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _testConnection,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.network_check_rounded,
                                size: 18),
                        label: const Text('Testar conexão'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _hasChanges && !_testing ? _save : null,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
                if (_testResult != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_testOk
                              ? SupercineColors.success
                              : SupercineColors.danger)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_testOk
                                ? SupercineColors.success
                                : SupercineColors.danger)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _testOk
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          color: _testOk
                              ? SupercineColors.success
                              : SupercineColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testResult!,
                            style: TextStyle(
                              color: _testOk
                                  ? SupercineColors.success
                                  : SupercineColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Status do proxy',
            subtitle: 'Health check + provedores registrados.',
            icon: Icons.health_and_safety_rounded,
            child: _ProxyStatus(store: store),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Sobre o app',
            subtitle: 'Supercine App v1.0.0 • Flutter • HBO Max-like UI.',
            icon: Icons.info_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Versão', '1.0.0'),
                _row('API', 'Output API v1.3.0'),
                _row('Desenvolvido por', '@deivid22srk'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: SupercineColors.textMuted)),
          Text(v,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SupercineColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SupercineColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: SupercineTheme.brandGradient,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: SupercineColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ProxyStatus extends StatefulWidget {
  final AppStore store;
  const _ProxyStatus({required this.store});

  @override
  State<_ProxyStatus> createState() => _ProxyStatusState();
}

class _ProxyStatusState extends State<_ProxyStatus> {
  bool _loading = false;
  String? _error;
  dynamic _health;
  List<dynamic>? _providers;

  @override
  void initState() {
    super.initState();
    if (widget.store.isConfigured) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _health = await widget.store.api.health();
      _providers = (await widget.store.api.providers()).providers;
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.store.isConfigured) {
      return const Text('Configure a URL da API para ver o status.',
          style: TextStyle(color: SupercineColors.textMuted));
    }
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _refresh);
    }
    if (_health == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle,
                color: SupercineColors.success, size: 10),
            const SizedBox(width: 6),
            const Text(
              'Online',
              style: TextStyle(
                  color: SupercineColors.success,
                  fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              'v${_health.version}',
              style: const TextStyle(color: SupercineColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_providers != null && _providers!.isNotEmpty) ...[
          const Text(
            'Provedores',
            style: TextStyle(
                color: SupercineColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _providers!
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: SupercineColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (p.healthy as bool)
                              ? SupercineColors.success.withValues(alpha: 0.4)
                              : SupercineColors.danger.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: (p.healthy as bool)
                                ? SupercineColors.success
                                : SupercineColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (p.displayName as String).isNotEmpty
                                ? p.displayName as String
                                : p.name as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Atualizar'),
          ),
        ),
      ],
    );
  }
}
