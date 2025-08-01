// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _email = TextEditingController();

  Future<void> submit() async {
    if (_email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.loaderOverlay.show();

    try {
      // Implementasi logika reset password disini
      await Future.delayed(Duration(seconds: 2)); // Simulasi proses

      context.loaderOverlay.hide();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link reset password telah dikirim ke email Anda'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      context.loaderOverlay.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderOverlay(
        overlayOpacity: 0.2,
        overlayColor: Colors.black12,
        useDefaultLoading: false,
        overlayWidget: Center(
          child: SpinKitDoubleBounce(
            color: Colors.black,
            size: 50.0,
          ),
        ),
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Heading 1: Lupa Password dengan tanda tanya - rata kiri
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Heading 2: Instruksi - rata kiri
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Masukkan Email anda untuk reset password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Field Email
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: AppColor.secondary),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColor.light),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColor.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Tombol Kirim
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Kirim',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // Tombol Kembali
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    side: BorderSide(color: AppColor.primary),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}