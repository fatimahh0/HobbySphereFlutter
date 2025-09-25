// immutable UI state for payment flow
class StripePaymentState {
  final bool loading; // busy flag
  final String? error; // error text

  const StripePaymentState({this.loading = false, this.error}); // ctor

  StripePaymentState copyWith({bool? loading, String? error}) {
    return StripePaymentState(
      loading: loading ?? this.loading, // keep or replace loading
      error: error, // replace error (can be null)
    );
  }
}
