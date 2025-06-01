import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../view/tone_page.dart';

class BalanceToneApp extends StatelessWidget {
  const BalanceToneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '平衡声 BalanceTone',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const TonePage(),
    );
  }
}