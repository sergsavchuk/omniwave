import 'dart:developer';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:palette_generator/palette_generator.dart';

class DynamicGradient extends StatefulWidget {
  const DynamicGradient({
    super.key,
    required this.child,
    required this.imageUrl,
    required this.surfaceColor,
    required this.blendAmount,
    this.fromBlended = false,
  });

  final Widget child;
  final String imageUrl;
  final Color surfaceColor;
  final int blendAmount;
  final bool fromBlended;

  @override
  State<DynamicGradient> createState() => _DynamicGradientState();
}

class _DynamicGradientState extends State<DynamicGradient> {
  // reuse single instance of the ColorProvider
  static final _colorProvider = _ColorProviderWithHiveCache();

  Color? _gradientColor;

  @override
  void initState() {
    super.initState();

    _colorProvider
        .generateColorFromImage(NetworkImage(widget.imageUrl), widget.imageUrl)
        .then((color) => setState(() => _gradientColor = color));
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _gradientColor ?? widget.surfaceColor;
    final colors = widget.fromBlended
        ? [
            gradientColor.blend(
              widget.surfaceColor,
              widget.blendAmount,
            ),
            widget.surfaceColor
          ]
        : [
            gradientColor,
            gradientColor.blend(
              widget.surfaceColor,
              widget.blendAmount,
            ),
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: widget.child,
    );
  }
}

class _ColorProviderWithHiveCache {
  _ColorProviderWithHiveCache() : _colorBox = Hive.openBox<int>('imageColor');

  final Future<Box<int>> _colorBox;

  Future<Color> generateColorFromImage(
    ImageProvider imageProvider,
    String cacheKey,
  ) async {
    final colorBox = await _colorBox;

    final unsupportedCacheKey = !isASCII(cacheKey);
    if (unsupportedCacheKey) {
      log('Hive does not support non-ASCII keys');
    }

    if (!unsupportedCacheKey && colorBox.containsKey(cacheKey)) {
      return Color(colorBox.get(cacheKey)!);
    }

    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    final color = palette.dominantColor!.color;

    if (!unsupportedCacheKey) {
      await colorBox.put(cacheKey, color.value);
    }

    return color;
  }

  bool isASCII(String str) => str.codeUnits.every((codeUnit) => codeUnit < 128);
}
