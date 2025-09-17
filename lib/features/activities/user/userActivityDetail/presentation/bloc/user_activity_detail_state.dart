// Immutable state for the details screen                             // file role
import '../../domain/entities/user_activity_detail_entity.dart'; // entity

class UserActivityDetailState {
  // state bag
  final bool loading; // loading item
  final UserActivityDetailEntity? item; // loaded item
  final int participants; // selected qty
  final bool checking; // checking seats
  final bool canBook; // seats ok
  final bool booking; // confirming booking
  final String? error; // error message
  final String? imageBaseUrl; // server base for images

  const UserActivityDetailState({
    // ctor
    this.loading = false, // default
    this.item, // nullable
    this.participants = 1, // default qty
    this.checking = false, // default
    this.canBook = false, // default
    this.booking = false, // default
    this.error, // none
    this.imageBaseUrl, // none
  });

  UserActivityDetailState copyWith({
    // copy util
    bool? loading, // override
    UserActivityDetailEntity? item, // override
    int? participants, // override
    bool? checking, // override
    bool? canBook, // override
    bool? booking, // override
    String? error, // override
    String? imageBaseUrl, // override
  }) {
    return UserActivityDetailState(
      // new state
      loading: loading ?? this.loading, // keep/override
      item: item ?? this.item, // keep/override
      participants: participants ?? this.participants, // keep/override
      checking: checking ?? this.checking, // keep/override
      canBook: canBook ?? this.canBook, // keep/override
      booking: booking ?? this.booking, // keep/override
      error: error, // replace (can be null)
      imageBaseUrl: imageBaseUrl ?? this.imageBaseUrl, // keep/override
    );
  }
}
