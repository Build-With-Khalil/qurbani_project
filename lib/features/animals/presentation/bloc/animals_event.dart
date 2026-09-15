part of 'animals_bloc.dart';

abstract class AnimalsEvent extends Equatable {
  const AnimalsEvent();
  @override
  List<Object?> get props => [];
}

class AnimalsLoadRequested extends AnimalsEvent {
  const AnimalsLoadRequested();
}

class AnimalsTabChanged extends AnimalsEvent {
  final AnimalsTab tab;
  const AnimalsTabChanged(this.tab);
  @override
  List<Object?> get props => [tab];
}

class AnimalsCowSelected extends AnimalsEvent {
  final String tag;
  const AnimalsCowSelected(this.tag);
  @override
  List<Object?> get props => [tag];
}
