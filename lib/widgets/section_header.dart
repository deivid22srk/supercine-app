import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cabeçalho de seção no padrão HBO Max: título grande à esquerda,
/// opcionalmente com subtítulo e ação "Ver tudo".
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel = 'Ver tudo',
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        letterSpacing: -0.3,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SupercineColors.textMuted,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: SupercineColors.brand,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
