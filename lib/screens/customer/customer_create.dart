import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/screens/product_variant/form_variant.dart';
import 'package:kasir/services/customer_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CustomerCreate extends StatefulWidget {
  const CustomerCreate({super.key});

  @override
  State<CustomerCreate> createState() => _CustomerCreateState();
}

class _CustomerCreateState extends State<CustomerCreate> {
  final _formcustomerkey = GlobalKey<FormState>();

  CustomerServices customerServices = CustomerServices();
  TextEditingController name = TextEditingController();
  TextEditingController whatsapp = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController company = TextEditingController();

  Future<void> submit() async {
    context.loaderOverlay.show();
    Map<String, dynamic> body = {
      'name': name.text,
      'whatsapp': whatsapp.text,
      'phone': phone.text,
      'alamat': alamat.text,
      'company': company.text
    };
    var resp = await customerServices.store(body);
    if (resp!.statusCode == 201) {
      Navigator.pop(context);
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Form Pelanggan",
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
        overlayWidget: Center(
          child: SpinKitDoubleBounce(
            color: Colors.black,
            size: 50.0,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formcustomerkey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TextInput(
                    label: "Nama Pelanggan",
                    validate: true,
                    type: TextInputType.text,
                    controller: name,
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                    label: "Whatsapp",
                    validate: true,
                    type: TextInputType.number,
                    controller: whatsapp,
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                    label: "Phone",
                    validate: true,
                    type: TextInputType.number,
                    controller: phone,
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                    label: "Alamat",
                    validate: false,
                    type: TextInputType.text,
                    controller: alamat,
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                    label: "Perusahaan",
                    validate: false,
                    type: TextInputType.text,
                    controller: company,
                  ),
                  const SizedBox(height: 10),
                  ButtonPrimary(
                    label: "Simpan",
                    onTap: () {
                      if (_formcustomerkey.currentState!.validate()) {
                        return submit();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
