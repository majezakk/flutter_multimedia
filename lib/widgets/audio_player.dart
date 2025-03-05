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
        await _audioPlayer.setSourceUrl(widget.audioUrl);
        await _audioPlayer.resume();
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        print("Ошибка воспроизведения аудио: $e");
      }
    }
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    // Если обложка не указана, используем дефолтное изображение
    final coverPath = widget.cover ?? 'assets/default_cover.jpg';
    return Column(
      children: [
        // Отображаем обложку
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            image: DecorationImage(
              image: coverPath.startsWith('assets/')
                  ? AssetImage(coverPath) as ImageProvider
                  : FileImage(File(coverPath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          min: 0,
          max: totalDuration.inSeconds.toDouble(),
          value: currentPosition.inSeconds.toDouble().clamp(0.0, totalDuration.inSeconds.toDouble()),
          onChanged: (value) {
            _seekTo(value);
          },
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
          iconSize: 36,
        )
      ],
    );
  }
}
