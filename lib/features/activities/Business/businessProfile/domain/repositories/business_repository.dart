// Flutter 3.35.x
// Business repository contract.

import '../entities/business.dart'; // entity

abstract class BusinessRepository {
  Future<Business> getBusinessById(String token, int id); // get one
  Future<void> updateVisibility(
    String token,
    int id,
    bool isPublic,
  ); // toggle visibility
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }); // change status
  Future<void> deleteBusiness(String token, int id, String password); // delete
  Future<bool> checkStripeStatus(String token, int id); // stripe status

  // NEW: create Stripe connect link (returns URL)
  Future<String> createStripeConnectLink(String token, int id); // onboarding
}
