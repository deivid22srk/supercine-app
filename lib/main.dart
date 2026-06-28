import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movies_screen.dart';
import 'screens/player_screen.dart';
import 'screens/search_screen.dart';
import 'screens/series_screen.dart';
import 'screens/settings_screen.dart';
import 'services/app_store.dart';
import 'services/favorites_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Trava em modo retrato para uma experiência mais "app-like".
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar transparente com ícones claros (sobre fundo escuro).
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: SupercineColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();
  runApp(SupercineApp(prefs: prefs));
}

class SupercineApp extends StatelessWidget {
  final SharedPreferences prefs;
  const SupercineApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SettingsService>(create: (_) => SettingsService(prefs)),
        Provider<FavoritesService>(create: (_) => FavoritesService(prefs)),
        ChangeNotifierProvider<AppStore>(
          create: (ctx) => AppStore(
            settings: ctx.read<SettingsService>(),
            favorites: ctx.read<FavoritesService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Supercine',
        debugShowCheckedModeBanner: false,
        theme: SupercineTheme.dark,
        initialRoute: '/home',
        routes: {
          '/home': (_) => const MainShell(),
          '/movies': (_) => const MoviesScreen(),
          '/series': (_) => const SeriesScreen(),
          '/search': (_) => const SearchScreen(),
          '/favorites': (_) => const FavoritesScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/detail': (_) => const DetailScreen(),
          '/player': (_) => const PlayerScreen(),
        },
      ),
    );
  }
}

/// Estrutura principal com bottom navigation (5 abas).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    MoviesScreen(),
    SeriesScreen(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: SupercineColors.surface,
          border: Border(
            top: BorderSide(
                color: SupercineColors.divider.withValues(alpha: 0.6),
                width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined),
                  activeIcon: Icon(Icons.movie_rounded),
                  label: 'Filmes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tv_outlined),
                  activeIcon: Icon(Icons.tv_rounded),
                  label: 'Séries',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoritos',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
