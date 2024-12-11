import 'package:bloc/bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

part 'phone_number_state.dart';

class PhoneNumberCubit extends Cubit<PhoneNumberState> {
  PhoneNumberCubit() : super(PhoneNumberInitial());
  final ImagePicker _picker = ImagePicker();

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

  Future<void> callPhoneNumber(String phoneNumber) async {
    var status = await Permission.phone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        emit(PhoneNumberFailure('لا يمكن إجراء المكالمة: URL غير مدعوم.'));
      }
    } else if (status.isDenied) {
      emit(PhoneNumberFailure('تم رفض إذن الاتصال.'));
    } else if (status.isPermanentlyDenied) {
      emit(PhoneNumberFailure(
          'تم رفض إذن الاتصال بشكل دائم. افتح الإعدادات لتغييره.'));
    } else {
      emit(PhoneNumberFailure('لم يتم منح إذن الاتصال.'));
    }
  }

  Future<void> openWhatsApp(String phoneNumber) async {
    final String internationalPhoneNumber = '20${phoneNumber.substring(1)}';

    final Uri whatsappUri =
        Uri.parse("https://wa.me/$internationalPhoneNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      emit(PhoneNumberFailure('لا يمكن فتح WhatsApp.'));
    }
  }

  Future<void> pickImageAndExtractPhoneNumber(ImageSource source) async {
    final XFile? imageFile = await _picker.pickImage(source: source);

    if (imageFile == null) {
      emit(PhoneNumberFailure('لم يتم اختيار صورة.'));
      return;
    }

    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      final String recognizedTextStr = recognizedText.text;

      extractPhoneNumber(recognizedTextStr);
    } catch (e) {
      emit(PhoneNumberFailure('حدث خطأ أثناء استخراج النص: $e'));
    } finally {
      textRecognizer.close();
    }
  }
}
