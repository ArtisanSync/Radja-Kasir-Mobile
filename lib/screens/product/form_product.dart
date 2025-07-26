import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/input_dropdown.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/product/form/select_category.dart';
import 'package:kasir/services/product_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class FormProduct extends StatefulWidget {
  const FormProduct({super.key});

  @override
  State<FormProduct> createState() => _FormProductState();
}

class _FormProductState extends State<FormProduct> {
  ProductServices productServices = ProductServices();
  ImagePicker picker = ImagePicker();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _brand = TextEditingController();
  final TextEditingController _capitalPrice = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _discRp = TextEditingController();
  final TextEditingController _discPercent = TextEditingController();
  final TextEditingController _stock = TextEditingController();
  final TextEditingController _tax = TextEditingController();
  final TextEditingController _qtyType = TextEditingController();

  final _formProductKey = GlobalKey<FormState>();
  XFile? _imageValue;
  bool loading = false;
  bool showQtyType = false;
  String? categoryId;
  String? categoryLable;
  String? selectQtyType;

  // Pick Image
  void getImage(XFile? image) {
    setState(() {
      _imageValue = image;
    });
  }

  Future<void> submit(BuildContext context) async {
    context.loaderOverlay.show();

    final store = await Store.getStore();

    FormData formData = FormData.fromMap({
      'store_id': store['id'],
      'image': await MultipartFile.fromFile(_imageValue!.path),
      "name": _name.text,
      "category_id": categoryId,
      "code": _code.text,
      "brand": _brand.text,
      "variant": {
        "name": "general",
        "quantity": _stock.text,
        "qty_type": _qtyType.text,
        "capital_price": _capitalPrice.text,
        "price": _price.text,
        "disc_rp": _discRp.text,
        "disc_percent": _discPercent.text,
        "tax": _tax.text,
      }
    });

    try {
      var res = await productServices.storeProduct(formData);
      context.loaderOverlay.show();
      Navigator.pop(context);
      print(res);
    } catch (e) {
      context.loaderOverlay.show();
      const snackBar = SnackBar(
        content: Text('Terjadi kesalahan ! coba lagi. '),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e);
    }
  }

  void initDataState() {
    setState(() {
      _capitalPrice.text = '0';
      _price.text = '0';
      _discPercent.text = '0';
      _discRp.text = '0';
      _tax.text = '0';
      _stock.text = '1';
    });
  }

  @override
  void initState() {
    super.initState();
    initDataState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Tambah Produk",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _imageValue != null
                              ? Image.file(
                                  File(_imageValue!.path),
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: 100,
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                  ),
                                ),
                        )
                      ],
                    ),
                    Positioned(
                      left: (MediaQuery.of(context).size.width / 2) - -60,
                      top: 10,
                      child: CircleAvatar(
                        radius: 30,
                        child: IconButton(
                          onPressed: () async {
                            var image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            setState(() {
                              _imageValue = image;
                            });
                          },
                          icon: const Icon(
                            Icons.camera,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Form(
                key: _formProductKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextInput(
                                controller: _name,
                                label: "Nama produk",
                                validate: true,
                              ),
                              const SizedBox(height: 10),
                              TextInput(
                                controller: _code,
                                label: "Kode produk",
                                validate: false,
                              ),
                              const SizedBox(height: 10),
                              TextInput(
                                controller: _brand,
                                label: "Brand/Merk",
                                validate: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                border: const Border.fromBorderSide(
                                  BorderSide(width: 1, color: AppColor.light),
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  categoryId != null
                                      ? Text('$categoryLable')
                                      : const Text('Pilih Kategori'),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectCategory(),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                categoryId = result['id'] as String;
                                categoryLable = result['name'] as String;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Atur Harga'),
                          const SizedBox(height: 10),
                          TextInput(
                            label: "Modal",
                            validate: false,
                            controller: _capitalPrice,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          TextInput(
                            label: "Harga jual",
                            validate: false,
                            controller: _price,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          TextInput(
                            label: "Discount (%)",
                            validate: false,
                            controller: _discPercent,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          TextInput(
                            label: "Discount (Rp)",
                            validate: false,
                            controller: _discRp,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          // TextInput(
                          //   label: "Pajak (%)",
                          //   validate: false,
                          //   controller: _tax,
                          //   type: TextInputType.number,
                          // )
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Atur Stok'),
                          const SizedBox(height: 10),
                          TextInput(
                            label: "Jumlah",
                            validate: false,
                            controller: _stock,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          showQtyType
                              ? const SizedBox()
                              : const Text(
                                  'Satuan \n(Pilih lainnya untuk input manual satuan)'),
                          const SizedBox(height: 10),
                          showQtyType
                              ? TextInput(
                                  label: "Tipe",
                                  validate: false,
                                  controller: _qtyType,
                                )
                              : InputDropDown(
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
                                )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_formProductKey.currentState!.validate() &&
                              _imageValue != null) {
                            submit(context);
                          } else {
                            const snackBar = SnackBar(
                              content: Text('Nama atau produk gambar kosong. '),
                              backgroundColor: Colors.red,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              )
            ],
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
    this.type,
    required TextEditingController controller,
  }) : _controller = controller;

  final TextEditingController _controller;
  final String label;
  final bool validate;
  final TextInputType? type;

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
      keyboardType: type ?? TextInputType.text,
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
