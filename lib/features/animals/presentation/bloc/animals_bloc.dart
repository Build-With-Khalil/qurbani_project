import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/animal.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/get_cow_detail.dart';

part 'animals_event.dart';
part 'animals_state.dart';

class AnimalsBloc extends Bloc<AnimalsEvent, AnimalsState> {
  final GetAnimals getAnimals;
  final GetCowDetail getCowDetail;

  AnimalsBloc({required this.getAnimals, required this.getCowDetail})
      : super(const AnimalsState()) {
    on<AnimalsLoadRequested>(_onLoad);
    on<AnimalsTabChanged>((e, emit) => emit(state.copyWith(tab: e.tab)));
    on<AnimalsCowSelected>(_onSelect);
  }

  Future<void> _onLoad(
      AnimalsLoadRequested e, Emitter<AnimalsState> emit) async {
    emit(state.copyWith(status: AnimalsStatus.loading));
    final r = await getAnimals(const NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: AnimalsStatus.failure, errorMessage: f.message)),
      (list) =>
          emit(state.copyWith(status: AnimalsStatus.ready, all: list)),
    );
  }

  Future<void> _onSelect(
      AnimalsCowSelected e, Emitter<AnimalsState> emit) async {
    final r = await getCowDetail(e.tag);
    r.fold(
      (_) => null,
      (animal) => emit(state.copyWith(selected: animal)),
    );
  }
}
