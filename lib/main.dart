import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_glow/flutter_glow.dart';

// ===================== 主题配色定义 =====================

// 主色：用于主题、文字高亮、图标等
const kPrimaryColor = Color(0xFF537D5D);

// 次色：用于 Glow 效果、播放按钮强调色
const kSecondaryColor = Color(0xFF73946B);

// 按钮背景色
const kButtonColor = Color(0xFF9EBC8A);

// 背景色（App 背景和进度条背景色）
const kBackgroundColor = Color(0xFFD2D0A0);

// 进度条颜色
const kProgressColor = kPrimaryColor;

// ========================================================

void main() {
  runApp(const BalanceToneApp());
}

class BalanceToneApp extends StatelessWidget {
  const BalanceToneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '平衡声 BalanceTone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        useMaterial3: true,
        fontFamily: 'SansSerif',
      ),
      home: const ToneHomePage(),
    );
  }
}

class ToneHomePage extends StatefulWidget {
  const ToneHomePage({super.key});

  @override
  State<ToneHomePage> createState() => _ToneHomePageState();
}

class _ToneHomePageState extends State<ToneHomePage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  final double _volume = 1.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _visualizerTimer;

  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  Future<void> _play({bool oneMinute = false}) async {
    HapticFeedback.lightImpact();
    await _player.stop();
    await _player.setVolume(_volume);
    await _player.play(AssetSource('audio/100hz.mp3'), volume: _volume);
    setState(() => _isPlaying = true);
    _animationController.repeat(reverse: true);
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (_isPlaying) setState(() {});
    });

    if (oneMinute) {
      setState(() {
        _remainingSeconds = 60;
      });
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      });
      Future.delayed(const Duration(minutes: 1), () {
        _stop();
      });
    }
  }

  Future<void> _stop() async {
    HapticFeedback.lightImpact();
    await _player.stop();
    setState(() => _isPlaying = false);
    _animationController.stop();
    _animationController.reset();
    _visualizerTimer?.cancel();
    _visualizerTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = 0;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    _visualizerTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Widget _buildVisualizer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(20, (index) {
        final height = Random().nextDouble() * 60;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: _isPlaying ? height : 10,
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPlayButton(String label, VoidCallback onPressed, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          onPressed: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed();
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            backgroundColor: kButtonColor,
            foregroundColor: Colors.white,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const GlowIcon(
                  Icons.graphic_eq,
                  color: kSecondaryColor,
                  size: 80,
                  blurRadius: 20,
                  glowColor: kSecondaryColor,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '平衡声 BalanceTone',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '100Hz 纯音可刺激前庭系统，缓解晕眩等不适。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kSecondaryColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(height: 80, child: _buildVisualizer()),
              if (_remainingSeconds > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (60 - _remainingSeconds) / 60,
                          backgroundColor: kBackgroundColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(kProgressColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '剩余：$_remainingSeconds 秒',
                        style: const TextStyle(
                          fontSize: 14,
                          color: kProgressColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              _buildPlayButton('播放 1 分钟', () => _play(oneMinute: true), !_isPlaying),
              _buildPlayButton('持续播放', () => _play(oneMinute: false), !_isPlaying),
              _buildPlayButton('停止播放', _stop, _isPlaying),
              const Spacer(),
              const Text(
                '© 2025 BalanceTone',
                style: TextStyle(fontSize: 12, color: Colors.black26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}