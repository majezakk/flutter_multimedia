import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  const VideoPlayerWidget({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.startsWith('http')) {
      _controller = VideoPlayerController.network(widget.videoPath);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }

    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
      _startHideControlsTimer();
    });

    _controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    setState(() {});
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  void _rewind() {
    final currentPosition = _controller.value.position;
    Duration newPosition = currentPosition - const Duration(seconds: 10);
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    _controller.seekTo(newPosition);
    _showControlsTemporarily();
  }

  void _fastForward() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    Duration newPosition = currentPosition + const Duration(seconds: 10);
    if (newPosition > duration) {
      newPosition = duration;
    }
    _controller.seekTo(newPosition);
    _showControlsTemporarily();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
        _hideControlsTimer?.cancel();
      } else {
        _controller.play();
        _showControlsTemporarily();
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Загрузка видео...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Видео
            GestureDetector(
              onTap: _showControlsTemporarily,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // Оверлей контролов
            if (_showControls)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54.withOpacity(0.3),
                        Colors.black54,
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),

            // Кнопки управления
            if (_showControls)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Основные контроли (перемотка, воспроизведение)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                        onPressed: _rewind,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        iconSize: 64,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                        onPressed: _fastForward,
                      ),
                    ],
                  ),

                  // Индикатор прогресса и таймеры
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: theme.colorScheme.primary,
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.white10,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            // Большая кнопка воспроизведения для остановленного видео
            if (!_controller.value.isPlaying && !_showControls)
              IconButton(
                iconSize: 80,
                icon: const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white54,
                ),
                onPressed: _togglePlayPause,
              ),
          ],
        ),
      ),
    );
  }
}