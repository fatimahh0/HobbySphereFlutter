class ManagerInviteRequest {
  final String email;
  const ManagerInviteRequest({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}
