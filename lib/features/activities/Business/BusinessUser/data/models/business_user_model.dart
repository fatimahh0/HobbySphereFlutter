import '../../domain/entities/business_user.dart';

class BusinessUserModel extends BusinessUser {
  const BusinessUserModel({
    required int id,
    required String firstname,
    required String lastname,
    String? email,
    String? phoneNumber,
    required String businessName,
  }) : super(
         id: id,
         firstname: firstname,
         lastname: lastname,
         email: email,
         phoneNumber: phoneNumber,
         businessName: businessName,
       );

  factory BusinessUserModel.fromJson(Map<String, dynamic> json) {
    return BusinessUserModel(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      businessName: json['businessName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phoneNumber': phoneNumber,
      'businessName': businessName,
    };
  }
}
