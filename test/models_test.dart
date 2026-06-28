import 'package:flutter_test/flutter_test.dart';

import 'package:supercine_app/models/home_response.dart';
import 'package:supercine_app/models/movie_meta.dart';
import 'package:supercine_app/models/resolve_result.dart';
import 'package:supercine_app/models/seasons_response.dart';

void main() {
  group('MovieMeta', () {
    test('fromJson preenche todos os campos', () {
      final json = {
        'imdb': 'tt0111161',
        'type': 'movie',
        'embed_type': 'movies',
        'title_ptbr': 'Um Sonho de Liberdade',
        'title_orig': 'The Shawshank Redemption',
        'year': 1994,
        'poster_url':
            'https://m.media-amazon.com/images/M/MV5BMDAyY2FhYjctNDc5OS00MDNlLThiMGUtY2UxYWVkNGY2ZjljXkEyXkFqcGc@._V1_SX400_.jpg',
        'backdrop_url':
            'https://image.tmdb.org/t/p/original/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg',
        'cast': 'Tim Robbins, Morgan Freeman',
        'rank': 78,
        'available': true,
        'server_count': 3,
        'provider': 'supercine',
      };
      final m = MovieMeta.fromJson(json);
      expect(m.imdb, 'tt0111161');
      expect(m.displayTitle, 'Um Sonho de Liberdade');
      expect(m.isTv, isFalse);
      expect(m.available, isTrue);
    });

    test('fromJson lida com campos ausentes', () {
      final m = MovieMeta.fromJson({});
      expect(m.imdb, '');
      expect(m.year, 0);
      expect(m.available, isFalse);
      expect(m.displayTitle, '');
    });
  });

  group('ResolveResult', () {
    test('fromJson parseia vídeos e servidores', () {
      final json = {
        'provider': 'supercine',
        'imdb': 'tt0111161',
        'type': 'movies',
        'servers': [
          {'index': 0, 'name': 'Player 1', 'description': '[OK] mixdrop'},
        ],
        'videos': [
          {'url': 'https://example.com/video.mp4', 'quality': 'Normal'},
          {'url': '', 'quality': 'Normal'}, // deve ser filtrado
        ],
      };
      final r = ResolveResult.fromJson(json);
      expect(r.hasVideos, isTrue);
      expect(r.videos.length, 1);
      expect(r.servers.first.isOk, isTrue);
    });
  });

  group('SeasonsResponse', () {
    test('fromJson parseia temporadas', () {
      final json = {
        'imdb': 'tt0903747',
        'status': 'success',
        'season_count': 2,
        'seasons': [
          {
            'number': 1,
            'id': '14107',
            'episodes': [
              {'number': 1, 'id': '14100', 'title': 'Piloto', 'date': '', 'backdrop': ''},
            ],
          },
          {'number': 2, 'id': '14121', 'episodes': []},
        ],
      };
      final s = SeasonsResponse.fromJson(json);
      expect(s.seasonCount, 2);
      expect(s.seasons.first.episodes.first.title, 'Piloto');
      expect(s.seasons.last.episodes, isEmpty);
    });
  });

  group('HomeResponse (v1.4.0)', () {
    test('fromJson parseia 4 linhas com itens', () {
      final json = {
        'type': 'movies',
        'count': 4,
        'rows': [
          {
            'category': 'lancamentos',
            'label': '🔥 Lançamentos',
            'count': 12,
            'items': [
              {
                'imdb': 'tt42192165',
                'type': 'movie',
                'embed_type': 'movies',
                'title_ptbr': 'O Assassinato de Rachel Nickell',
                'title_orig': '',
                'year': 2026,
                'available': true,
                'server_count': 0,
                'provider': 'supercine',
                'imdb_rating': 6.8,
                'runtime': '96',
                'categories': ['Crime', 'Documentário', 'Lançamentos'],
                'post_id': '1447376',
              }
            ],
          },
          {
            'category': 'destaques',
            'label': '⭐ Destaques',
            'count': 12,
            'items': [],
          },
        ],
      };
      final h = HomeResponse.fromJson(json);
      expect(h.type, 'movies');
      expect(h.count, 4);
      expect(h.rows.length, 2);
      expect(h.rows.first.category, HomeCategory.lancamentos);
      expect(h.rows.first.label, '🔥 Lançamentos');

      final item = h.rows.first.items.first;
      expect(item.imdb, 'tt42192165');
      expect(item.imdbRating, 6.8);
      expect(item.imdbRatingFormatted, '6.8');
      expect(item.runtime, '96');
      expect(item.runtimeFormatted, '1h 36min');
      expect(item.categories, ['Crime', 'Documentário', 'Lançamentos']);
      expect(item.postId, '1447376');
      expect(item.hasHomeExtras, isTrue);
    });

    test('runtimeFormatted lida com horas exatas e minutos <60', () {
      final m1 = MovieMeta(
        imdb: 'x', type: 'movie', embedType: 'movies',
        titlePtbr: '', titleOrig: '', year: 0, posterUrl: '', backdropUrl: '',
        cast: '', rank: 0, available: false, serverCount: 0, provider: '',
        runtime: '120',
      );
      expect(m1.runtimeFormatted, '2h');

      final m2 = MovieMeta(
        imdb: 'x', type: 'movie', embedType: 'movies',
        titlePtbr: '', titleOrig: '', year: 0, posterUrl: '', backdropUrl: '',
        cast: '', rank: 0, available: false, serverCount: 0, provider: '',
        runtime: '45',
      );
      expect(m2.runtimeFormatted, '45min');

      final m3 = MovieMeta(
        imdb: 'x', type: 'movie', embedType: 'movies',
        titlePtbr: '', titleOrig: '', year: 0, posterUrl: '', backdropUrl: '',
        cast: '', rank: 0, available: false, serverCount: 0, provider: '',
        runtime: '',
      );
      expect(m3.runtimeFormatted, '');
    });
  });
}
