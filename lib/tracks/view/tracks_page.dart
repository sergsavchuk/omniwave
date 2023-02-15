import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omniwave/common/app_scaffold/app_scaffold.dart';

import 'package:omniwave/tracks/tracks.dart';

class TracksPage extends StatelessWidget {
  const TracksPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const TracksPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: MusicItemCategory.tracks,
      body: BlocProvider(
        create: (___) => TracksBloc(),
        child: const TracksView(),
      ),
    );
  }
}

class TracksView extends StatelessWidget {
  const TracksView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TracksBloc, TracksState>(
      builder: (context, state) {
        return const SizedBox.shrink();
      },
    );
  }
}
