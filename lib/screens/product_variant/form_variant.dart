import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/services/product_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../components/input_dropdown.dart';

class FormProductVariant extends StatefulWidget {
  const FormProductVariant({
    this.productId,
    super.key,
  });

  final String? productId;

  @override
  State<FormProductVariant> createState() => _FormProductVariantState();
}

class _FormProductVariantState extends State<FormProductVariant> {
  final _formProductVariantKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _capitalPrice = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _tax = TextEditingController();
  final TextEditingController _dicRp = TextEditingController();
  final TextEditingController _dicPercent = TextEditingController();
  final TextEditingController _qtyType = TextEditingController();

  final ProductServices productServices = ProductServices();

  String? selectQtyType;
  bool showQtyType = false;

  Future<void> submit(BuildContext context) async {
    context.loaderOverlay.show();

    Map<String, dynamic> body = {
      "product_id": widget.productId,
      "name": _name.text,
      "quantity": _quantity.text,
      "qty_type": _qtyType.text,
      "price": _price.text,
      "capital_price": _capitalPrice.text,
      "tax": _tax.text,
      "dic_rp": _dicRp.text,
      "dic_percent": _dicPercent.text,
    };

    try {
      final res = await productServices.storeVariant(body);
      context.loaderOverlay.hide();
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
      context.loaderOverlay.hide();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _quantity.text = '0';
      _capitalPrice.text = '0';
      _price.text = '0';
      _tax.text = '0';
      _dicPercent.text = '0';
      _dicRp.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Variasi Produk",
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
            key: _formProductVariantKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                    label: "Nama variasi",
                    validate: true,
                    controller: _name,
                    type: TextInputType.text,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                    label: "Stok",
                    validate: true,
                    controller: _quantity,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 15),
                showQtyType
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextInput(
                          label: "Tipe Stok",
                          validate: false,
                          controller: _qtyType,
                          type: TextInputType.text,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InputDropDown(
                          val: selectQtyType,
                          lists: const [
                            'PCS',
                            'KTN',
                            'DUS',
                            'PAK',
                            'BAL',
                            'LAINNYA'
                          ],
                          onSelect: (val) {
                            setState(() {
                              if (val == 'LAINNYA') {
                                showQtyType = true;
                              } else {
                                selectQtyType = val;
                                _qtyType.text = val;
                              }
                            });
                          },
                        ),
                      ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                      label: "Harga Jual",
                      validate: true,
                      controller: _price,
                      type: TextInputType.number),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                    label: "Harga Modal",
                    validate: true,
                    controller: _capitalPrice,
                    type: TextInputType.number,
                  ),
                ),
                // const SizedBox(height: 15),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: TextInput(
                //     label: "Pajak (%)",
                //     validate: true,
                //     controller: _tax,
                //     type: TextInputType.number,
                //   ),
                // ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [Text("Atur Potongan Harga")],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                    label: "Discount (Rp)",
                    validate: true,
                    controller: _dicRp,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                    label: "Discount (%)",
                    validate: true,
                    controller: _dicPercent,
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ButtonPrimary(
                    label: "Tambah",
                    onTap: () {
                      if (_formProductVariantKey.currentState!.validate()) {
                        submit(context);
                      } else {
                        const snackBar = SnackBar(
                          content: Text('Nama atau produk gambar kosong. '),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
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

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.label,
    required this.validate,
    required this.type,
    required TextEditingController controller,
  }) : _controller = controller;

  final TextEditingController _controller;
  final String label;
  final bool validate;
  final TextInputType type;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      validator: validate
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label harus terisi !';
              }
              return null;
            }
          : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColor.secondary, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColor.light),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColor.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
      ),
    );
  }
}
