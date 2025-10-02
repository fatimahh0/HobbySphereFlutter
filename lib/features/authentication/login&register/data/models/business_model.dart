class BusinessModel {
  final int id;
  final String? businessName;
  final String? email;
  final String? phoneNumber;
  final String? websiteUrl;
  final String? description;
  final String? businessLogo;
  final String? businessBanner;

  BusinessModel({
    required this.id,
    this.businessName,
    this.email,
    this.phoneNumber,
    this.websiteUrl,
    this.description,
    this.businessLogo,
    this.businessBanner,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> m) => BusinessModel(
    id: (m['id'] as num).toInt(),
    businessName: m['businessName'],
    email: m['email'],
    phoneNumber: m['phoneNumber'],
    websiteUrl: m['websiteUrl'],
    description: m['description'],
    businessLogo: m['businessLogo'] ?? m['businessLogoUrl'],
    businessBanner: m['businessBanner'] ?? m['businessBannerUrl'],
  );
}
