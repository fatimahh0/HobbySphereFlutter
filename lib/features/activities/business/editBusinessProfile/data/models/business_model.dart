import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required int id,
    required String name,
    String? email,
    required String phoneNumber,
    String? websiteUrl,
    required String description,
    String? logoUrl,
    String? bannerUrl,
    required String status,
    required bool isPublicProfile,
  }) : super(
         id: id,
         name: name,
         email: email,
         phoneNumber: phoneNumber,
         websiteUrl: websiteUrl,
         description: description,
         logoUrl: logoUrl,
         bannerUrl: bannerUrl,
         status: status,
         isPublicProfile: isPublicProfile,
       );

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['businessName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? '',
      websiteUrl: json['websiteUrl'],
      description: json['description'] ?? '',
      logoUrl: json['businessLogoUrl'],
      bannerUrl: json['businessBannerUrl'],
      status: json['status']?['name'] ?? '',
      isPublicProfile: json['isPublicProfile'] ?? false,
    );
  }
}
