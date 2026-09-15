part of 'reports_bloc.dart';

enum ReportsStatus { initial, loading, ready, failure }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final SeasonSummary? summary;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.summary,
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    SeasonSummary? summary,
    String? errorMessage,
  }) =>
      ReportsState(
        status: status ?? this.status,
        summary: summary ?? this.summary,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
