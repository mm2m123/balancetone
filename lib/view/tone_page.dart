import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../viewmodel/tone_view_model.dart';

class TonePage extends StatelessWidget {
  const TonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ToneViewModel>(context);

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
                  child: const Icon(
                    Icons.graphic_eq,
                    size: 80,
                    color: kSecondaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '平衡声 BalanceTone',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
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
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: vm.isCountdownMode
                        ? LinearProgressIndicator(
                            value: vm.progress,
                            minHeight: 8,
                            backgroundColor: kPrimaryColor.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                kProgressColor),
                          )
                        : Container(
                            height: 8,
                            color: Colors.transparent,
                          ),
                  ),
                ),
                if (vm.remainingSeconds > 0)
                  Container(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '${(vm.remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(vm.remainingSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                if (vm.remainingSeconds == 0)
                  Container(
                    height: 50,
                  ),
                const Spacer(),
                _buildPlayButton(
                    '播放 1 分钟', () => vm.play(oneMinute: true), !vm.isPlaying),
                _buildPlayButton(
                    '持续播放', () => vm.play(oneMinute: false), !vm.isPlaying),
                _buildPlayButton('停止播放', () => vm.stop(), vm.isPlaying),
                const Spacer(),
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

  Widget _buildPlayButton(String label, VoidCallback onPressed, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
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
}
