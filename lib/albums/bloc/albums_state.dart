part of 'albums_bloc.dart';

class AlbumsState extends Equatable {
  const AlbumsState({this.albums = const []});

  final List<Album> albums;

  @override
  List<Object> get props => [...albums];
}
