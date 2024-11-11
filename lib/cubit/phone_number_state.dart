part of 'phone_number_cubit.dart';

@immutable
sealed class PhoneNumberState {}

final class PhoneNumberInitial extends PhoneNumberState {}

final class PhoneNumberSuccess extends PhoneNumberState {
  final String phoneNumber;
  PhoneNumberSuccess(this.phoneNumber);
}

final class PhoneNumberFailure extends PhoneNumberState {
  final String error;
  PhoneNumberFailure(this.error);
}
