import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'phone_number_state.dart';

class PhoneNumberCubit extends Cubit<PhoneNumberState> {
  PhoneNumberCubit() : super(PhoneNumberInitial());

  void extractPhoneNumber(String inputText) {
    final RegExp phoneNumberRegex = RegExp(r'01[0-2|5]\d{8}');
    final match = phoneNumberRegex.firstMatch(inputText);

    if (match != null) {
      final extractedPhoneNumber = match.group(0);
      emit(PhoneNumberSuccess(extractedPhoneNumber!));
    } else {
      emit(PhoneNumberFailure('لم يتم العثور على رقم هاتف.'));
    }
  }

  void callPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      emit(PhoneNumberFailure('لم يتم العثور على رقم هاتف.'));
    }
  }
}
