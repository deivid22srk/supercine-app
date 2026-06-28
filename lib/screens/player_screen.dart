import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import 'detail_screen.dart';

/// Player de vídeo em tela cheia usando `video_player` + `chewie`.
///
/// Suporta múltiplas URLs (servidores) com fallback. HLS (m3u8) é
/// suportado nativamente pelo video_player no Android/iOS.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerArgs _args;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentIdx = 0;
  bool _loading = true;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is PlayerArgs) {
      _args = arg;
      _initVideo(0);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _initVideo(int idx) async {
    if (idx >= _args.videos.length) {
      setState(() {
        _error = 'Nenhuma fonte de vídeo disponível.';
        _loading = false;
      });
      return;
    }
    setState(() {
      _currentIdx = idx;
      _loading = true;
      _error = null;
    });

    await _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;

    final url = _args.videos[idx].url as String;
    final isHls = url.toLowerCase().endsWith('.m3u8');

    final newVideoController = isHls
        ? VideoPlayerController.networkUrl(Uri.parse(url),
            formatHint: VideoFormat.hls)
        : VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await newVideoController.initialize();
    } catch (e) {
      // Tenta próximo servidor
      if (mounted) {
        await newVideoController.dispose();
        _initVideo(idx + 1);
      }
      return;
    }

    if (!mounted) {
      await newVideoController.dispose();
      return;
    }

    _videoController = newVideoController;
    _chewieController = ChewieController(
      videoPlayerController: newVideoController,
      autoPlay: true,
      looping: false,
      aspectRatio: newVideoController.value.aspectRatio == 0
          ? 16 / 9
          : newVideoController.value.aspectRatio,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: SupercineColors.brand,
        handleColor: SupercineColors.brand,
        bufferedColor: SupercineColors.brand.withValues(alpha: 0.3),
        backgroundColor: SupercineColors.surfaceAlt,
      ),
      errorBuilder: (context, errorMessage) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: SupercineColors.danger, size: 48),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              if (idx + 1 < _args.videos.length)
                ElevatedButton.icon(
                  onPressed: () => _initVideo(idx + 1),
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Tentar próximo servidor'),
                ),
            ],
          ),
        ),
      ),
    );

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _args.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (_args.subtitle != null)
                          Text(
                            _args.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_args.servers.isNotEmpty)
                    PopupMenuButton<int>(
                      tooltip: 'Servidores',
                      icon: const Icon(Icons.layers_rounded,
                          color: Colors.white),
                      color: SupercineColors.surface,
                      onSelected: (i) => _initVideo(i),
                      itemBuilder: (_) => [
                        for (int i = 0; i < _args.videos.length; i++)
                          PopupMenuItem(
                            value: i,
                            child: Row(
                              children: [
                                Icon(
                                  i == _currentIdx
                                      ? Icons.play_circle_filled
                                      : Icons.play_circle_outline,
                                  color: i == _currentIdx
                                      ? SupercineColors.brand
                                      : SupercineColors.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    i < _args.servers.length
                                        ? _args.servers[i].name
                                        : 'Servidor ${i + 1}',
                                    style: const TextStyle(
                                        color: SupercineColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            // Player
            Expanded(
              child: _buildPlayerArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerArea() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: SupercineColors.brand),
            SizedBox(height: 12),
            Text(
              'Carregando vídeo...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: SupercineColors.danger, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Fechar'),
              ),
            ],
          ),
        ),
      );
    }
    if (_chewieController == null) {
      return const Center(
        child: Text('Player indisponível',
            style: TextStyle(color: Colors.white70)),
      );
    }
    return Center(child: Chewie(controller: _chewieController!));
  }
}
