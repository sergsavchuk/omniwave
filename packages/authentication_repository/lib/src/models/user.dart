import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id});

  final String id;

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;

  @override
  List<Object?> get props => [id];
}
