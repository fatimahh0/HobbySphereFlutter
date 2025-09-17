// Events for the details BLoC                                       // file role

abstract class UserActivityDetailEvent {} // base type

class UserActivityDetailStarted extends UserActivityDetailEvent {
  // load item
  final int itemId; // item id
  final String? imageBaseUrl; // server base for relative images
  UserActivityDetailStarted(this.itemId, {this.imageBaseUrl}); // ctor
}

class UserParticipantsChanged extends UserActivityDetailEvent {
  // qty change
  final int value; // new qty value
  UserParticipantsChanged(this.value); // ctor
}

class UserCheckAvailabilityPressed extends UserActivityDetailEvent {
  // check seats
  final String bearerToken; // "Bearer xxx"
  UserCheckAvailabilityPressed(this.bearerToken); // ctor
}

class UserConfirmBookingPressed extends UserActivityDetailEvent {
  // confirm booking
  final String bearerToken; // "Bearer xxx"
  final String stripePaymentId; // Stripe payment id
  UserConfirmBookingPressed(this.bearerToken, this.stripePaymentId); // ctor
}
