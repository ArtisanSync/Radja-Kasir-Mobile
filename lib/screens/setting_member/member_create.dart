// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_light.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/components/input_validation.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/user_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class MemberCreate extends StatefulWidget {
  const MemberCreate({Key? key}) : super(key: key);

  @override
  State<MemberCreate> createState() => _MemberCreateState();
}

class _MemberCreateState extends State<MemberCreate> {
  final _formMemberKey = GlobalKey<FormState>();
  UserServices userServices = UserServices();
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  Future<void> submit() async {
    context.loaderOverlay.show();
    Map<String, dynamic> body = {
      "name": _name.text,
      "email": _email.text,
      "password": _password.text
    };
    var resp = await userServices.store(body);
    context.loaderOverlay.hide();
    if (resp!.statusCode == 201) {
      Navigator.pop(context);
    }

    if (resp!.statusCode == 400) {
      const snackBar = SnackBar(
        content: Text('Email telah terdaftar'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void reset() {
    _name.clear();
    _email.clear();
    _password.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Tambah Member",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: LoaderOverlay(
        overlayOpacity: 0.2,
        overlayColor: Colors.black12,
        useDefaultLoading: false,
        overlayWidget: const Center(
          child: SpinKitDoubleBounce(
            color: Colors.black,
            size: 50.0,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formMemberKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputValidation(
                      label: "Name", controller: _name, validate: true),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputValidation(
                    label: "Email",
                    controller: _email,
                    validate: true,
                    type: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputValidation(
                    label: "Password",
                    controller: _password,
                    validate: true,
                    type: TextInputType.visiblePassword,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ButtonPrimary(
                    label: "Simpan",
                    onTap: () {
                      if (_formMemberKey.currentState!.validate()) {
                        submit();
                      } else {
                        const snackBar = SnackBar(
                          content: Text('Data tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ButtonLight(
                    label: "Kembali",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
