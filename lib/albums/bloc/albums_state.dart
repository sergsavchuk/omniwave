part of 'albums_bloc.dart';

class AlbumsState extends Equatable {
  const AlbumsState({this.albums = const [], this.loadingNextPage = false});

  final List<Album> albums;
  final bool loadingNextPage;

  @override
  List<Object> get props => [albums, loadingNextPage];
}
