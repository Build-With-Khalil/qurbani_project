import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer.dart';
import '../repositories/booking_repository.dart';

class SearchCustomers implements UseCase<List<Customer>, String> {
  final BookingRepository repository;
  SearchCustomers(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(String params) =>
      repository.searchCustomers(params);
}
