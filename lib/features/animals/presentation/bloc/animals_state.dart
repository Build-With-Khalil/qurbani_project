part of 'animals_bloc.dart';

enum AnimalsStatus { initial, loading, ready, failure }

enum AnimalsTab { all, partial, complete, bakra }

class AnimalsState extends Equatable {
  final AnimalsStatus status;
  final List<Animal> all;
  final AnimalsTab tab;
  final Animal? selected;
  final String? errorMessage;

  const AnimalsState({
    this.status = AnimalsStatus.initial,
    this.all = const [],
    this.tab = AnimalsTab.all,
    this.selected,
    this.errorMessage,
  });

  List<Animal> get visible {
    switch (tab) {
      case AnimalsTab.all:
        return all;
      case AnimalsTab.partial:
        return all.where((a) => a.isPartial).toList();
      case AnimalsTab.complete:
        return all.where((a) => a.isComplete).toList();
      case AnimalsTab.bakra:
        return all.where((a) => a.type != AnimalType.gaay).toList();
    }
  }

  AnimalsState copyWith({
    AnimalsStatus? status,
    List<Animal>? all,
    AnimalsTab? tab,
    Animal? selected,
    String? errorMessage,
  }) =>
      AnimalsState(
        status: status ?? this.status,
        all: all ?? this.all,
        tab: tab ?? this.tab,
        selected: selected ?? this.selected,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, all, tab, selected, errorMessage];
}
