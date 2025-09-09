import 'package:equatable/equatable.dart';

class BusinessUser extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phoneNumber;
  final String businessName;

  const BusinessUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phoneNumber,
    required this.businessName,
  });

  @override
  List<Object?> get props => [
    id,
    firstname,
    lastname,
    email,
    phoneNumber,
    businessName,
  ];
}
