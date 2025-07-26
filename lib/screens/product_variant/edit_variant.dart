import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/components/input_dropdown.dart';
import 'package:kasir/screens/product_variant/form_variant.dart';
import 'package:kasir/services/product_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class VariantEditPage extends StatefulWidget {
  const VariantEditPage({
    required this.id,
    super.key,
  });

  final int id;
  @override
  State<VariantEditPage> createState() => _VariantEditPageState();
}

class _VariantEditPageState extends State<VariantEditPage> {
  final _formVariantKey = GlobalKey<FormState>();

  ProductServices productServices = ProductServices();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _capitalPrice = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _tax = TextEditingController();
  final TextEditingController _dicRp = TextEditingController();
  final TextEditingController _dicPercent = TextEditingController();
  final TextEditingController _qtyType = TextEditingController();
  String? selectQtyType;
  bool showQtyType = false;

  Future<void> fetch() async {
    var resp = await productServices.detailVariant(widget.id);
    print(resp);
    if (resp!.statusCode == 200) {
      setState(() {
        _name.text = resp.data['data']['name'];
        _quantity.text = resp.data['data']['quantity'].toString();
        _capitalPrice.text = resp.data['data']['capital_price'].toString();
        _price.text = resp.data['data']['price'].toString();
        _tax.text = resp.data['data']['tax'].toString();
        _dicRp.text = resp.data['data']['dic_rp'].toString();
        _dicPercent.text = resp.data['data']['dic_percent'].toString();
      });
    }
  }

  Future<void> update() async {
    context.loaderOverlay.show();
    Map<String, dynamic> body = {
      "name": _name.text,
      "quantity": _quantity.text,
      "qty_type": _qtyType.text,
      "price": _price.text,
      "capital_price": _capitalPrice.text,
      "tax": _tax.text,
      "dic_rp": _dicRp.text,
      "dic_percent": _dicPercent.text,
    };
    var resp = await productServices.updateVariant(widget.id, body);
    if (resp!.statusCode == 201) {
      Navigator.pop(context);
    }
    context.loaderOverlay.hide();
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
          "Edit Variasi",
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
            key: _formVariantKey,
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
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInput(
                    label: "Pajak (%)",
                    validate: true,
                    controller: _tax,
                    type: TextInputType.number,
                  ),
                ),
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
                    label: "Simpan",
                    onTap: () {
                      if (_formVariantKey.currentState!.validate()) {
                        update();
                      } else {
                        const snackBar = SnackBar(
                          content:
                              Text('Tidak dapat diproses, isi inputan wajib.'),
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
