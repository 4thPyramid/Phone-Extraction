import 'package:extract_phone/cubit/phone_number_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PhoneNumberExtractorApp());
}

class PhoneNumberExtractorApp extends StatelessWidget {
  const PhoneNumberExtractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'استخراج رقم الهاتف',
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      ),
      home: BlocProvider(
        create: (context) => PhoneNumberCubit(),
        child: const PhoneNumberExtractorScreen(),
      ),
    );
  }
}

class PhoneNumberExtractorScreen extends StatefulWidget {
  const PhoneNumberExtractorScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PhoneNumberExtractorScreenState createState() =>
      _PhoneNumberExtractorScreenState();
}

class _PhoneNumberExtractorScreenState extends State<PhoneNumberExtractorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'استخراج رقم الهاتف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'النصوص'),
            Tab(icon: Icon(Icons.phone_android), text: 'النتائج'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextInputTab(context),
          _buildResultsTab(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImageSource? source = await showDialog<ImageSource?>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('اختر مصدر الصورة',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.camera_alt,
                          color: Colors.blue, size: 30),
                      title:
                          const Text('كاميرا', style: TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.pop(context, ImageSource.camera);
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: const Icon(Icons.photo_album,
                          color: Colors.green, size: 30),
                      title: const Text('معرض الصور',
                          style: TextStyle(fontSize: 16)),
                      onTap: () {
                        Navigator.pop(context, ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (source == null) return;

          await context
              .read<PhoneNumberCubit>()
              .pickImageAndExtractPhoneNumber(source);

          _tabController.animateTo(1);
        },
        child: const Icon(Icons.image, size: 28),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildTextInputTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أدخل النص:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'أدخل النص هنا',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                BlocProvider.of<PhoneNumberCubit>(context)
                    .extractPhoneNumber(_textController.text);
                _tabController.animateTo(1);
              },
              icon: const Icon(Icons.search),
              label: const Text('استخراج رقم الهاتف'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<PhoneNumberCubit, PhoneNumberState>(
        builder: (context, state) {
          if (state is PhoneNumberSuccess) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'رقم الهاتف المستخرج:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.phoneNumber,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            BlocProvider.of<PhoneNumberCubit>(context)
                                .callPhoneNumber(state.phoneNumber);
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('اتصال'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            BlocProvider.of<PhoneNumberCubit>(context)
                                .openWhatsApp(state.phoneNumber);
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('واتساب'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (state is PhoneNumberFailure) {
            return Center(
              child: Text(
                state.error,
                style: const TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
            );
          } else {
            return const Center(
              child: Text(
                'أدخل نصًا يحتوي على رقم هاتف لاستخراجه.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }
}
