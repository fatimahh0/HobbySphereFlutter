class ManagerInviteResponse {
  final String? message;
  final String? error;

  const ManagerInviteResponse({this.message, this.error});

  bool get ok => error == null || error!.isEmpty;

  factory ManagerInviteResponse.fromJson(dynamic data) {
    if (data is Map) {
      return ManagerInviteResponse(
        message: data['message']?.toString(),
        error: data['error']?.toString(),
      );
    }
    return ManagerInviteResponse(message: data?.toString());
  }
}
