import 'package:equatable/equatable.dart';

abstract class EditBusinessEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBusiness extends EditBusinessEvent {
  final String token;
  final int id;
  LoadBusiness(this.token, this.id);
}

class SaveBusiness extends EditBusinessEvent {
  final String token;
  final int id;
  final Map<String, dynamic> body;
  final bool withImages;
  
  SaveBusiness(this.token, this.id, this.body, {this.withImages = false});
}

class RemoveLogo extends EditBusinessEvent {
  final String token;
  final int id;
  RemoveLogo(this.token, this.id);
}

class RemoveBanner extends EditBusinessEvent {
  final String token;
  final int id;
  RemoveBanner(this.token, this.id);
}

class DeleteBusinessEvent extends EditBusinessEvent {
  final String token;
  final int id;
  final String password;
  DeleteBusinessEvent(this.token, this.id, this.password);
}
