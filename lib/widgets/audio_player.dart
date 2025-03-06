import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  /// Путь к обложке. Если null, будет использоваться дефолтное изображение.
  final String? cover;
  const AudioPlayerWidget({Key? key, required this.audioUrl, this.cover})
      : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isLoading = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  late AnimationController _animationController;

  String get _durationText => _formatDuration(currentPosition);
  String get _totalDurationText => _formatDuration(totalDuration);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(1.0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
        _animationController.reverse();
      });
    });

    // Предзагрузка аудио
    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка предзагрузки аудио: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
      _animationController.reverse();
    } else {
      try {
        if (currentPosition.inSeconds == 0) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.resume();
        setState(() {
          isPlaying = true;
        });
        _animationController.forward();
      } catch (e) {
        print("Ошибка воспроизведения аудио: $e");
      }
    }
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? twoDigits(duration.inHours) + ':' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Если обложка не указана, используем дефолтное изображение для аудио
    final bool hasCover = widget.cover != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Верхняя часть с обложкой или визуализацией
          if (hasCover)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: widget.cover!.startsWith('assets/')
                      ? AssetImage(widget.cover!) as ImageProvider
                      : FileImage(File(widget.cover!)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.secondary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  size: 64,
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                ),
              ),
            ),

          // Нижняя часть с контролами
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Ряд с временем и общей длительностью
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _durationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      Text(
                        _totalDurationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Слайдер прогресса
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14.0,
                    ),
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    min: 0,
                    max: totalDuration.inSeconds.toDouble(),
                    value: currentPosition.inSeconds.toDouble().clamp(
                      0.0,
                      totalDuration.inSeconds.toDouble(),
                    ),
                    onChanged: (value) {
                      _seekTo(value);
                    },
                  ),
                ),

                // Кнопки управления
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Кнопка перемотки назад
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        _audioPlayer.seek(
                          Duration(seconds: (currentPosition.inSeconds - 10).clamp(0, totalDuration.inSeconds)),
                        );
                      },
                    ),

                    // Кнопка воспроизведения/паузы
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : _togglePlayPause,
                          customBorder: const CircleBorder(),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                                : AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _animationController,
                              color: theme.colorScheme.onPrimary,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Кнопка перемотки вперед
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        _audioPlayer.seek(
                          Duration(seconds: (currentPosition.inSeconds + 10).clamp(0, totalDuration.inSeconds)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}