import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({Key? key, required this.audioUrl})
      : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setVolume(1.0);

    // Отслеживаем изменения длительности и позиции воспроизведения
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
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      try {
        // Устанавливаем источник для аудио по URL
        await _audioPlayer.setSource(UrlSource(widget.audioUrl));
        // Запускаем воспроизведение
        await _audioPlayer.resume();
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        // Если произошла ошибка, выводим её в консоль
        print("Ошибка при воспроизведении аудио: $e");
      }
    }
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          min: 0,
          max: totalDuration.inSeconds.toDouble(),
          value: currentPosition.inSeconds.toDouble().clamp(
              0.0, totalDuration.inSeconds.toDouble()),
          onChanged: (value) {
            _seekTo(value);
          },
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
        )
      ],
    );
  }
}
