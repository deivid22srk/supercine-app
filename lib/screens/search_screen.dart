import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import '../widgets/states.dart';

/// Tela de busca — campo de texto no topo + lista de resultados.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    context.read<AppStore>().search(value);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Buscar filmes, séries, atores...',
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _hasSearched = false);
                        store.search('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: SupercineColors.surfaceAlt,
            ),
            onSubmitted: _submit,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      body: _Body(
        store: store,
        hasSearched: _hasSearched,
        onSuggestionTap: (q) {
          _controller.text = q;
          _submit(q);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AppStore store;
  final bool hasSearched;
  final ValueChanged<String> onSuggestionTap;
  const _Body({
    required this.store,
    required this.hasSearched,
    required this.onSuggestionTap,
  });

  static const _suggestions = [
    'Breaking Bad',
    'Interestelar',
    'Batman',
    'Vingadores',
    'Stranger Things',
    'Game of Thrones',
    'Matrix',
    'Senhor dos Anéis',
  ];

  @override
  Widget build(BuildContext context) {
    if (!hasSearched) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Buscas populares',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map((q) => ActionChip(
                      label: Text(q),
                      onPressed: () => onSuggestionTap(q),
                      backgroundColor: SupercineColors.surfaceAlt,
                      labelStyle: const TextStyle(
                        color: SupercineColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ))
                .toList(),
          ),
        ],
      );
    }

    if (store.isSearching &&
        (store.searchResults.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.searchError != null && store.searchResults.isEmpty) {
      return ErrorState(
        message: store.searchError!,
        onRetry: () => store.search(store.searchResults.toString()),
      );
    }

    if (store.searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nenhum resultado',
        subtitle: 'Tente outro termo ou verifique sua conexão.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        childAspectRatio: 0.52,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemCount: store.searchResults.length,
      itemBuilder: (context, i) =>
          MovieCard(meta: store.searchResults[i], width: 130),
    );
  }
}
