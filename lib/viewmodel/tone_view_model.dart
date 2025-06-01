import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ToneViewModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  bool isPlaying = false;
  bool isCountdownMode = false;
  int remainingSeconds = 0;
  double progress = 0.0;

  final double _volume = 1.0;

  Timer? _countdownTimer;
  DateTime? _endTime;

  Future<void> play({bool oneMinute = false}) async {
    isCountdownMode = oneMinute;
    HapticFeedback.lightImpact();

    await _player.stop();
    await _player.setVolume(_volume);
    await _player.play(AssetSource('audio/100hz.mp3'), volume: _volume);

    isPlaying = true;
    notifyListeners();

    if (oneMinute) {
      remainingSeconds = 60;
      _endTime = DateTime.now().add(const Duration(seconds: 60));
      _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        final diff = _endTime!.difference(DateTime.now());
        if (diff.inMilliseconds <= 0) {
          stop();
        } else {
          remainingSeconds = diff.inSeconds;
          progress = (60000 - diff.inMilliseconds) / 60000;
          notifyListeners();
        }
      });
    }
  }

  Future<void> stop() async {
    HapticFeedback.lightImpact();
    await _player.stop();

    isPlaying = false;
    remainingSeconds = 0;
    progress = 0.0;
    isCountdownMode = false;

    _countdownTimer?.cancel();
    _countdownTimer = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}