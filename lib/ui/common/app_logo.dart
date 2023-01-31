import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(
        'OmniWave',
        style: Theme.of(context)
            .textTheme
            .headlineLarge
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
