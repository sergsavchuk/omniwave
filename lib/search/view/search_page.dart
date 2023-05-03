import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_repository/music_repository.dart';

import 'package:omniwave/common/common.dart';
import 'package:omniwave/search/search.dart';
import 'package:omniwave/styles.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SearchPage());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      category: MusicItemCategory.search,
      body: BlocProvider(
        create: (context) =>
            SearchBloc(musicRepository: context.read<MusicRepository>()),
        child: const SearchView(),
      ),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(searchBloc: context.read<SearchBloc>()),
        Expanded(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (_, state) => ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) => SizedBox(
                height: 70,
                child: _SearchItemView(searchResult: state.results[index]),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required SearchBloc searchBloc,
  }) : _searchBloc = searchBloc;

  final SearchBloc _searchBloc;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    textEditingController.addListener(() {
      widget._searchBloc.add(SearchQueryChanged(textEditingController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
    );
  }

  @override
  void dispose() {
    super.dispose();

    textEditingController.dispose();
  }
}

class _SearchItemView<T> extends StatelessWidget {
  const _SearchItemView({super.key, required this.searchResult});

  final SearchResult<T> searchResult;

  @override
  Widget build(BuildContext context) {
    final item = searchResult.result;

    String? imageUrl;
    String? name;
    String? type;

    if (item is Playlist) {
      imageUrl = item.imageUrl;
      name = item.name;
      type = 'Playlist';
    } else if (item is Track) {
      imageUrl = item.imageUrl;
      name = item.name;
      type = 'Track';
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(Insets.extraSmall),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl ?? Urls.defaultCover,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        const SizedBox(width: Insets.extraSmall),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? Values.unknownItem,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              Text(
                type ?? Values.unknownItem,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              )
            ],
          ),
        ),
      ],
    );
  }
}
