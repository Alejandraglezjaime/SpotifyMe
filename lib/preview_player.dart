import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PreviewPlayer extends StatefulWidget {
  final String previewUrl;

  const PreviewPlayer({Key? key, required this.previewUrl}) : super(key: key);

  @override
  _PreviewPlayerState createState() => _PreviewPlayerState();
}

class _PreviewPlayerState extends State<PreviewPlayer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(UrlSource(widget.previewUrl));
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reproduciendo preview'),
      content: const Text('Escuchando fragmento de 30 segundos...'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}