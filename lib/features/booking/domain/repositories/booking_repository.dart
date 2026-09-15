import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_draft.dart';
import '../entities/booking_result.dart';
import '../entities/customer.dart';
import '../entities/partial_cow.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingResult>> createBooking(BookingDraft draft);
  Future<Either<Failure, List<Customer>>> searchCustomers(String query);
  Future<Either<Failure, List<PartialCow>>> getPartialCows();
}
