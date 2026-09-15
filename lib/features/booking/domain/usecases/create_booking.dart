import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking_draft.dart';
import '../entities/booking_result.dart';
import '../repositories/booking_repository.dart';

class CreateBooking implements UseCase<BookingResult, BookingDraft> {
  final BookingRepository repository;
  CreateBooking(this.repository);

  @override
  Future<Either<Failure, BookingResult>> call(BookingDraft params) =>
      repository.createBooking(params);
}
