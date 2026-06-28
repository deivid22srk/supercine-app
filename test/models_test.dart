import 'package:flutter_test/flutter_test.dart';

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
}
