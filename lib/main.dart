import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

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
      ),
      home: const OmniwaveHomePage(),
    );
  }
}

class OmniwaveHomePage extends StatelessWidget {
  const OmniwaveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 5,
          dividerPainter: DividerPainters.background(
            color: Colors.black,
            highlightedColor: Colors.grey,
          ),
        ),

        // TODO(sergsavchuk): add maximumSize parameter to Area
        // TODO(sergsavhcuk): make the gesture area larger than the divider
        // thickness so it would be easier to drag very thin ones / or
        // implement a custom DividerPainter that draws a thin line
        child: MultiSplitView(
          initialAreas: [
            Area(minimalSize: 128, weight: 0.3),
            Area(minimalWeight: 0.7),
          ],
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [AppLogo()],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Theme.of(context).primaryColor, Colors.black],
                  stops: const [0.0, 0.30],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

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
