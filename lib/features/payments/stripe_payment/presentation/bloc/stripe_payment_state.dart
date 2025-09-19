/// Immutable UI state for the Stripe flow.
class StripePaymentState {
  final bool loading; // creating intent or showing sheet
  final String? error; // error message, if any

  const StripePaymentState({this.loading = false, this.error});

  StripePaymentState copyWith({bool? loading, String? error}) {
    return StripePaymentState(
      loading: loading ?? this.loading,
      error: error, // replace (can be null)
    );
    // NOTE: use like copyWith(loading: false, error: '$err');
  }
}
