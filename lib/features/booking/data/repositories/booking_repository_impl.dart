import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking_draft.dart';
import '../../domain/entities/booking_result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/partial_cow.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource remote;
  BookingRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, BookingResult>> createBooking(BookingDraft draft) async {
    try {
      return Right(await remote.createBooking(draft));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers(String query) async {
    try {
      return Right(await remote.searchCustomers(query));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PartialCow>>> getPartialCows() async {
    try {
      return Right(await remote.getPartialCows());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
