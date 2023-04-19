import 'package:flutter/material.dart';

class GridWithPagination extends StatelessWidget {
  GridWithPagination({
    super.key,
    required this.onGridEndReached,
    required this.crossAxisCount,
    required this.children,
    required this.childAspectRatio,
    required this.loadingNextPage,
  });

  final List<Widget> children;
  final VoidCallback onGridEndReached;
  final double childAspectRatio;
  final bool loadingNextPage;
  final int crossAxisCount;

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      controller: _scrollController
        ..addListener(() {
          if (_scrollController.position.maxScrollExtent ==
              _scrollController.position.pixels) {
            onGridEndReached();
          }
        }),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      children: children.cast<Widget>() +
          (loadingNextPage
              ? List.filled(
                  crossAxisCount * 10,
                  const _ShimmerPlaceholder(),
                )
              : []),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder();

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  void _onAnimationUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000))
      ..addListener(_onAnimationUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            transform: _SlidingGradientTransform(
              slidePercent: _shimmerController.value,
            ),
            colors: const [
              Color(0xFFEBEBF4),
              Color(0xFFF4F4F4),
              Color(0xFFEBEBF4),
            ],
            stops: const [
              0.1,
              0.3,
              0.4,
            ],
            begin: const Alignment(-1, -0.3),
            end: const Alignment(1, 0.3),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController
      ..removeListener(_onAnimationUpdate)
      ..dispose();
    super.dispose();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
