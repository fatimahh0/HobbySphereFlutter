import 'package:equatable/equatable.dart';

class Business extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String phoneNumber;
  final String? websiteUrl;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final String status;
  final bool isPublicProfile;

  const Business({
    required this.id,
    required this.name,
    this.email,
    required this.phoneNumber,
    this.websiteUrl,
    required this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.status,
    required this.isPublicProfile,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    websiteUrl,
    description,
    logoUrl,
    bannerUrl,
    status,
    isPublicProfile,
  ];
}
