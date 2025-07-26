import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/button_light.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/product_variant/form_variant.dart';
import 'package:kasir/services/product_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'form/select_category.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({
    required this.id,
    super.key,
  });

  final String id;

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  ProductServices productServices = ProductServices();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _brand = TextEditingController();

  ImagePicker picker = ImagePicker();
  XFile? _imageValue;

  final _formProductKey = GlobalKey<FormState>();
  bool loading = false;
  String? imageOld;
  Map<String, dynamic> product = {};
  String? categoryId;
  String? categoryLable;

  Future<void> fetch() async {
    var resp = await productServices.detailProduct(widget.id);
    print(resp);
    setState(() {
      _name.text = resp['data']['name'];
      _code.text = resp['data']['code'];
      _brand.text = resp['data']['brand'];
      imageOld = resp['data']['image'];
      categoryId = resp['data']['category'];
      categoryLable = resp['data']['category'];
    });
  }

  Future<void> update() async {
    context.loaderOverlay.show();
    try {
      Map<String, dynamic> body = {
        "name": _name.text,
        "code": _code.text,
        "brand": _brand.text
      };
      var resp = await productServices.updateProduct(body, widget.id);
      context.loaderOverlay.hide();
      print(resp);
      Navigator.pop(context);
    } catch (e) {
      context.loaderOverlay.hide();
    }
  }

  Future<void> uploadPhoto() async {
    context.loaderOverlay.show();
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(_imageValue!.path),
    });

    var resp = await productServices.uploadPhotoProduct(widget.id, formData);
    context.loaderOverlay.hide();
    print(resp);
    if (resp!.statusCode == 201) {
      setState(() {
        _imageValue = null;
      });
      fetch();
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
          "Edit Produk",
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
          child: Form(
            key: _formProductKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              child: imageOld != null
                                  ? Image.network(
                                      imageOld!,
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: 100,
                                    )
                                  : (_imageValue != null
                                      ? Image.file(
                                          File(_imageValue!.path),
                                          fit: BoxFit.cover,
                                          height: 200,
                                          width: 100,
                                        )
                                      : const Center(
                                          child: Icon(Icons.image, size: 40))),
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
                                setState(() {
                                  imageOld = null;
                                });
                                imageOld = null;
                                var image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                setState(() {
                                  _imageValue = image;
                                });
                                if (_imageValue != null) {
                                  uploadPhoto();
                                }
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
                  const SizedBox(height: 30),
                  TextInput(
                    label: 'Nama Produk',
                    validate: true,
                    type: TextInputType.text,
                    controller: _name,
                  ),
                  const SizedBox(height: 10),

                  TextInput(
                    label: "Kode",
                    validate: false,
                    type: TextInputType.text,
                    controller: _code,
                  ),
                  const SizedBox(height: 10),
                  TextInput(
                    label: "Brand",
                    validate: false,
                    type: TextInputType.text,
                    controller: _brand,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          categoryId != null
                              ? Text('$categoryLable')
                              : const Text('Pilih Kategori'),
                          const Icon(Icons.chevron_right),
                        ],
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
                        context.loaderOverlay.show();
                        var resp = await productServices.changeCategoryProduct(widget.id, {"category_id" : result['id'] as String});
                        context.loaderOverlay.hide();
                        if(resp!.statusCode == 201){
                          setState(() {
                            categoryId = result['id'] as String;
                            categoryLable = result['name'] as String;
                          });
                        }
                      }
                    },
                  ),
                  Text("Data kategory otomatis tersimpan.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12.sp),),
                  const SizedBox(height: 20),
                  ButtonPrimary(
                    label: "Simpan",
                    onTap: () {
                      if (_formProductKey.currentState!.validate()) {
                        return update();
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  ButtonLight(
                      label: "Batal",
                      onTap: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
