class BusinessProfile {
  final int id;
  final String businessName;
  final String? email;
  final String? phoneNumber;
  final String? websiteUrl;
  final String? description;
  final String? businessLogo;
  final String? businessBanner;
  final bool? isPublicProfile;

  BusinessProfile({
    required this.id,
    required this.businessName,
    this.email,
    this.phoneNumber,
    this.websiteUrl,
    this.description,
    this.businessLogo,
    this.businessBanner,
    this.isPublicProfile,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> m) => BusinessProfile(
    id: (m['id'] as num).toInt(),
    businessName: m['businessName'] ?? '',
    email: m['email'],
    phoneNumber: m['phoneNumber'],
    websiteUrl: m['websiteUrl'],
    description: m['description'],
    businessLogo: m['businessLogo'] ?? m['businessLogoUrl'],
    businessBanner: m['businessBanner'] ?? m['businessBannerUrl'],
    isPublicProfile: m['isPublicProfile'] as bool?,
  );
}
