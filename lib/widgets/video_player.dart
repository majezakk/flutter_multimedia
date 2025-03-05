import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  const VideoPlayerWidget({Key? key, required this.videoPath})
      : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

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
    });
  }

  @override
  void dispose() {
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
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        VideoProgressIndicator(_controller, allowScrubbing: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: _rewind,
            ),
            IconButton(
              icon: Icon(_controller.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
            )
          ],
        )
      ],
    )
        : const Center(child: CircularProgressIndicator());
  }
}
