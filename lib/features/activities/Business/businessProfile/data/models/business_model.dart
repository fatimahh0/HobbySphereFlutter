import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  BusinessModel({
    required super.id,
    required super.name,
    super.description,
    super.logoUrl,
    super.bannerUrl,
    super.phoneNumber,
    super.websiteUrl,
    required super.status,
    required super.isPublicProfile,
    required super.stripeConnected,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['businessName'] ?? '',
      description: json['description'],
      logoUrl: json['businessLogoUrl'],
      bannerUrl: json['businessBannerUrl'],
      phoneNumber: json['phoneNumber'],
      websiteUrl: json['websiteUrl'],
      status: json['status']['name'] ?? 'UNKNOWN',
      isPublicProfile: json['isPublicProfile'] ?? false,
      stripeConnected:
          (json['stripeAccountId'] != null &&
          json['stripeAccountId'].toString().isNotEmpty),
    );
  }
}
