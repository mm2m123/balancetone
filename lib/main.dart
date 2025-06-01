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

// 主应用程序组件，设置全局主题和首页
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
      home: const ToneHomePage(), // 应用首页，音频播放与倒计时界面
    );
  }
}

// 首页 StatefulWidget，管理播放状态、动画和倒计时
class ToneHomePage extends StatefulWidget {
  const ToneHomePage({super.key});

  @override
  State<ToneHomePage> createState() => _ToneHomePageState();
}

class _ToneHomePageState extends State<ToneHomePage>
    with TickerProviderStateMixin {
  // 音频播放器实例，用于播放音频文件
  final AudioPlayer _player = AudioPlayer();

  // 播放状态标识，true 表示正在播放
  bool _isPlaying = false;

  // 固定音量大小，范围 0.0 - 1.0
  final double _volume = 1.0;

  // 控制播放按钮动画的动画控制器
  late AnimationController _animationController;

  // 播放按钮缩放动画，播放时放大缩小
  late Animation<double> _scaleAnimation;

  // 定时器用于更新可视化音频动画
  Timer? _visualizerTimer;

  // 倒计时剩余秒数，显示在界面中央
  int _remainingSeconds = 0;

  // 倒计时定时器
  Timer? _countdownTimer;

  // 当前进度值，0.0 - 1.0，用于圆形进度条绘制
  double _progress = 0.0;

  // 进度条动画控制器，用于平滑动画效果
  late AnimationController _progressAnimationController;

  // 进度条动画，驱动进度条变化
  late Animation<double> _progressAnimation;

  bool _isCountdownMode = false;

  // 播放音频方法，支持持续播放或播放 1 分钟倒计时
  Future<void> _play({bool oneMinute = false}) async {
    _isCountdownMode = oneMinute;
    // 触发轻微震动反馈，增强交互感
    HapticFeedback.lightImpact();

    // 停止当前播放，确保音频重新开始
    await _player.stop();

    // 设置音量
    await _player.setVolume(_volume);

    // 播放指定音频资源
    await _player.play(AssetSource('audio/100hz.mp3'), volume: _volume);

    // 更新播放状态为播放中
    setState(() => _isPlaying = true);

    // 如果是播放 1 分钟，启动倒计时逻辑和进度动画
    if (oneMinute) {
      // 启动播放按钮缩放动画，反复执行
      _animationController.repeat(reverse: true);

      // 启动定时器，定期刷新可视化动画
      _visualizerTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
        if (_isPlaying) setState(() {});
      });
      setState(() {
        _remainingSeconds = 60;
      });
      DateTime endTime = DateTime.now().add(const Duration(seconds: 60));

      // 重置进度条动画控制器
      _progressAnimationController.value = 0.0;

      // 初始化进度动画为无进度
      _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _progressAnimationController, curve: Curves.easeOut),
      );

      // 启动倒计时定时器，每 100 毫秒更新一次
      _countdownTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        final now = DateTime.now();
        final diff = endTime.difference(now);

        // 倒计时结束，停止播放
        if (diff.inMilliseconds <= 0) {
          timer.cancel();
          _progressAnimation = Tween<double>(
            begin: _progressAnimation.value,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: _progressAnimationController,
            curve: Curves.easeOut,
          ));
          _progressAnimationController.forward(from: 0.0);
          _stop();
        } else {
          setState(() {
            // 更新剩余秒数
            _remainingSeconds = diff.inSeconds;

            // 计算当前进度，范围 0.0 - 1.0
            double newProgress = (60000 - diff.inMilliseconds) / 60000;

            // 创建新的进度动画，从当前动画值平滑过渡到新进度
            _progressAnimation = Tween<double>(
              begin: _progressAnimation.value,
              end: newProgress,
            ).animate(CurvedAnimation(
              parent: _progressAnimationController,
              curve: Curves.easeOut,
            ));

            // 启动进度动画
            _progressAnimationController.forward(from: 0.0);
          });
        }
      });
    }
  }

  // 停止播放音频并重置状态
  Future<void> _stop() async {
    // 触发轻微震动反馈
    HapticFeedback.lightImpact();

    // 停止音频播放
    await _player.stop();

    // 更新播放状态为停止
    setState(() => _isPlaying = false);

    // 停止播放按钮动画并重置
    _animationController.stop();
    _animationController.reset();

    // 取消可视化动画定时器
    _visualizerTimer?.cancel();
    _visualizerTimer = null;

    // 取消倒计时定时器
    _countdownTimer?.cancel();
    _countdownTimer = null;

    // 重置倒计时和进度
    _remainingSeconds = 0;
    _progress = 0.0;
    _progressAnimationController.value = 0.0;
    if (_isCountdownMode) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOut,
      ));
      _progressAnimationController.forward(from: 0.0);
    }
    _isCountdownMode = false;
  }

  @override
  void initState() {
    super.initState();

    // 初始化播放按钮动画控制器，时长 800 毫秒
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 定义缩放动画，从 1.0 放大到 1.2，平滑过渡
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 初始化进度条动画控制器，时长 300 毫秒
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 初始化进度动画，初始无进度
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _progressAnimationController, curve: Curves.easeOut),
    )
      // 监听动画变化，刷新界面
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    // 释放音频播放器资源
    _player.dispose();

    // 释放动画控制器资源
    _animationController.dispose();
    _progressAnimationController.dispose();

    // 取消所有定时器
    _visualizerTimer?.cancel();
    _countdownTimer?.cancel();

    super.dispose();
  }

  // 构建音频可视化动画条，随机高度模拟音频波动
  Widget _buildVisualizer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(20, (index) {
        // 随机高度，播放时高度变化，停止时固定高度 10
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

  // 构建播放控制按钮，包含标签、点击事件和是否可用状态
  Widget _buildPlayButton(String label, VoidCallback onPressed, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          onPressed: enabled
              ? () {
                  // 触发轻微震动反馈
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

  // 构建主界面布局，包括图标、标题、说明文字、进度条和控制按钮
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // 圆形图标容器，带阴影和发光效果
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
                // 应用标题
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
                // 应用说明文字
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
                // 进度条与剩余时间统一占位区域
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isCountdownMode
                            ? LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 8,
                                backgroundColor: kPrimaryColor.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(kProgressColor),
                              )
                            : Container(
                                height: 8,
                                color: Colors.transparent,
                              ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: (_remainingSeconds > 0)
                            ? Text(
                                '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 播放 1 分钟按钮，播放时禁用
                _buildPlayButton(
                    '播放 1 分钟', () => _play(oneMinute: true), !_isPlaying),
                // 持续播放按钮，播放时禁用
                _buildPlayButton(
                    '持续播放', () => _play(oneMinute: false), !_isPlaying),
                // 停止播放按钮，仅播放时可用
                _buildPlayButton('停止播放', _stop, _isPlaying),
                const Spacer(),
                // 版权信息
                const Text(
                  '© 2025 BalanceTone',
                  style: TextStyle(fontSize: 12, color: Colors.black26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
