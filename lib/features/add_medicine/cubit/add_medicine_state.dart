import 'package:equatable/equatable.dart';

abstract class AddMedicineState extends Equatable {
  const AddMedicineState();

  @override
  List<Object?> get props => [];
}

class AddMedicineInitial extends AddMedicineState {}

class AddMedicineLoading extends AddMedicineState {}

class AddMedicineSuccess extends AddMedicineState {}

class AddMedicineError extends AddMedicineState {
  final String message;

  const AddMedicineError(this.message);

  @override
  List<Object?> get props => [message];
}
