import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String additionalData;

  const Failure(this.message, {this.additionalData = ""});

  @override
  List<Object?> get props => [message, additionalData];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.additionalData});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class BluetoothOffFailure extends Failure {
  const BluetoothOffFailure(super.message);
}
