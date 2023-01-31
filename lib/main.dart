import 'package:flutter/material.dart';
import 'package:omniwave/ui/pages/home_page/home_page.dart';

void main() {
  runApp(const OmniwaveApp());
}

class OmniwaveApp extends StatelessWidget {
  const OmniwaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omniwave Music Player',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.resolveWith<Color?>((states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.white;
              }
              return Colors.grey;
            }),
            textStyle: MaterialStateProperty.all(
              Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
