part of 'contact_us_cubit.dart';

class ContactUsState extends Equatable {
  final bool submissionLoading;
  final String? submissionSuccessMessage;
  final String? submissionFailureMessage;
  final bool historyLoading;
  final List<ContactUsHistoryItem>? historyList;
  final String? historyError;

  const ContactUsState({
    this.submissionLoading = false,
    this.submissionSuccessMessage,
    this.submissionFailureMessage,
    this.historyLoading = false,
    this.historyList,
    this.historyError,
  });

  static const ContactUsState initial = ContactUsState();

  ContactUsState copyWith({
    bool? submissionLoading,
    String? submissionSuccessMessage,
    String? submissionFailureMessage,
    bool? historyLoading,
    List<ContactUsHistoryItem>? historyList,
    String? historyError,
  }) {
    return ContactUsState(
      submissionLoading: submissionLoading ?? this.submissionLoading,
      submissionSuccessMessage: submissionSuccessMessage ?? this.submissionSuccessMessage,
      submissionFailureMessage: submissionFailureMessage ?? this.submissionFailureMessage,
      historyLoading: historyLoading ?? this.historyLoading,
      historyList: historyList ?? this.historyList,
      historyError: historyError ?? this.historyError,
    );
  }

  /// Clears submit result messages (use when emitting history updates after a submit).
  ContactUsState clearSubmitResult() {
    return ContactUsState(
      submissionLoading: submissionLoading,
      submissionSuccessMessage: null,
      submissionFailureMessage: null,
      historyLoading: historyLoading,
      historyList: historyList,
      historyError: historyError,
    );
  }

  @override
  List<Object?> get props => [
        submissionLoading,
        submissionSuccessMessage,
        submissionFailureMessage,
        historyLoading,
        historyList,
        historyError,
      ];
}
