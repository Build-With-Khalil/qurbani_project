part of 'receipts_bloc.dart';

abstract class ReceiptsEvent extends Equatable {
  const ReceiptsEvent();
  @override
  List<Object?> get props => [];
}

class ReceiptsLoadRequested extends ReceiptsEvent {
  const ReceiptsLoadRequested();
}

class ReceiptsSearchChanged extends ReceiptsEvent {
  final String query;
  const ReceiptsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class ReceiptsFilterChanged extends ReceiptsEvent {
  final String filter;
  const ReceiptsFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class ReceiptDetailRequested extends ReceiptsEvent {
  final String id;
  const ReceiptDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}
