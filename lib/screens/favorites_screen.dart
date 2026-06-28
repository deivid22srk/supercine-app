import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import '../widgets/states.dart';

/// Tela de favoritos — grid dos títulos salvos localmente.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final favs = store.favoriteList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          if (favs.isNotEmpty)
            IconButton(
              tooltip: 'Limpar tudo',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: SupercineColors.surface,
                    title: const Text('Limpar favoritos?'),
                    content: const Text(
                      'Esta ação remove todos os títulos salvos localmente.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: SupercineColors.danger,
                        ),
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  for (final m in favs) {
                    store.removeFavorite(m.imdb);
                  }
                }
              },
            ),
        ],
      ),
      body: favs.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Nenhum favorito ainda',
              subtitle:
                  'Toque no coração de qualquer título para salvá-lo aqui.',
              actionLabel: 'Explorar catálogo',
              onAction: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (r) => false),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 130,
                childAspectRatio: 0.52,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              itemCount: favs.length,
              itemBuilder: (context, i) =>
                  MovieCard(meta: favs[i], width: 130),
            ),
    );
  }
}
