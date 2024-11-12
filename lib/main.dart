import 'package:extract_phone/cubit/phone_number_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(PhoneNumberExtractorApp());
}

class PhoneNumberExtractorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'استخراج رقم الهاتف',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => PhoneNumberCubit(),
        child: PhoneNumberExtractorScreen(),
      ),
    );
  }
}

class PhoneNumberExtractorScreen extends StatefulWidget {
  @override
  _PhoneNumberExtractorScreenState createState() =>
      _PhoneNumberExtractorScreenState();
}

class _PhoneNumberExtractorScreenState
    extends State<PhoneNumberExtractorScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استخراج رقم الهاتف'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'أدخل النص هنا',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<PhoneNumberCubit>(context)
                    .extractPhoneNumber(_textController.text);
              },
              child: const Text('استخراج رقم الهاتف'),
            ),
            const SizedBox(height: 16),
            BlocBuilder<PhoneNumberCubit, PhoneNumberState>(
              builder: (context, state) {
                if (state is PhoneNumberSuccess) {
                  return Column(
                    children: [
                      Text(
                        'رقم الهاتف المستخرج: ${state.phoneNumber}',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<PhoneNumberCubit>(context)
                              .callPhoneNumber(state.phoneNumber);
                        },
                        child: const Text('الاتصال بالرقم'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<PhoneNumberCubit>(context)
                              .openWhatsApp(state.phoneNumber);
                        },
                        child: const Text('تحدث على واتساب'),
                      ),
                    ],
                  );
                } else if (state is PhoneNumberFailure) {
                  return Text(
                    state.error,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  );
                } else {
                  return const Text(
                    'أدخل نصًا يحتوي على رقم هاتف لاستخراجه.',
                    style: TextStyle(fontSize: 16),
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<PhoneNumberCubit>()
                    .pickImageAndExtractPhoneNumber();
              },
              child: Text('اختيار صورة'),
            ),
          ],
        ),
      ),
    );
  }
}
