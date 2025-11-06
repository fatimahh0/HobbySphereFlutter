class Business {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? phoneNumber;
  final String? websiteUrl;
  final String status;
  final bool isPublicProfile;
  final bool stripeConnected;

  const Business({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.phoneNumber,
    this.websiteUrl,
    required this.status,
    required this.isPublicProfile,
    required this.stripeConnected,
  });

  
}
