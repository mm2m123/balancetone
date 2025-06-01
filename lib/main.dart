import 'package:balance_tone/viewmodel/tone_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ToneViewModel(),
      child: const BalanceToneApp(),
    ),
  );
}
