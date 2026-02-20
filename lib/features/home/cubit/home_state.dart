import 'package:equatable/equatable.dart';
import '../../../models/medicine_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Medicine> medicines;
  final DateTime selectedDate;
  final String profileId;

  const HomeLoaded({
    required this.medicines,
    required this.selectedDate,
    required this.profileId,
  });

  @override
  List<Object?> get props => [medicines, selectedDate, profileId];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
