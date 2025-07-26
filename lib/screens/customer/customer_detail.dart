import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_light.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/screens/product/form_product.dart';
import 'package:kasir/services/customer_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({
    required this.id,
    super.key,
  });

  final String id;
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _formcustomerkey = GlobalKey<FormState>();

  CustomerServices customerServices = CustomerServices();
  TextEditingController name = TextEditingController();
  TextEditingController whatsapp = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController company = TextEditingController();

  Future<void> fetch() async {
    context.loaderOverlay.show();
    var resp = await customerServices.detail(widget.id);
    if (resp!.statusCode == 200) {
      Map<String, dynamic> data = resp!.data['data'] as Map<String, dynamic>;
      setState(() {
        name.text = data['name'].toString();
        whatsapp.text = data['whatsapp'].toString();
        phone.text = data['phone'].toString();
        alamat.text = data['alamat'].toString();
        company.text = data['company'].toString();
      });
    }
    context.loaderOverlay.hide();
  }

  Future<void> submit() async {
    context.loaderOverlay.show();

    Map<String, dynamic> body = {
      "name": name.text,
      "whatsapp": whatsapp.text,
      "phone": phone.text,
      "alamat": alamat.text,
      "company": company.text,
    };
    var resp = await customerServices.update(widget.id, body);
    context.loaderOverlay.hide();
    if (resp!.statusCode == 201) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Pelanggan",
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
                  ),
                  const SizedBox(height: 10),
                  ButtonLight(
                    label: "Hapus",
                    onTap: () async {
                      if (await confirm(context)) {
                        context.loaderOverlay.show();
                        final resp = await customerServices.destroy(widget.id);
                        context.loaderOverlay.hide();
                        if (resp!.statusCode == 201) {
                          Navigator.pop(context);
                        }
                      } else {
                        print("update");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
