import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/services/profile_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class FormUploadLogo extends StatefulWidget {
  const FormUploadLogo({Key? key}) : super(key: key);

  @override
  State<FormUploadLogo> createState() => _FormUploadLogoState();
}

class _FormUploadLogoState extends State<FormUploadLogo> {
  ProfileServices profileServices = ProfileServices();
  XFile? _imageValue;
  ImagePicker picker = ImagePicker();

  void getImage(XFile? image) {
    setState(() {
      _imageValue = image;
    });
  }

  Future<void> submit() async {
    context.loaderOverlay.show();
    FormData body = FormData.fromMap({
      'image': await MultipartFile.fromFile(_imageValue!.path),
    });
    var resp = await profileServices.uploadLogo(body);
    if (resp!.statusCode == 201) {
      context.loaderOverlay.hide();
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
          "Upload Logo",
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ButtonPrimary(
                  label: "Upload",
                  onTap: () => _imageValue != null ? submit() : null),
            )
          ],
        ),
      ),
    );
  }
}
