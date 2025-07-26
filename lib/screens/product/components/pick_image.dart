// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key, required this.getFile});

  final Function(XFile?) getFile;
  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  final ImagePicker picker = ImagePicker();
  late String imagePath = '';

  Future<void> checkPermission(BuildContext context) async {
    // var storageStatus = await Permission.photos.request();
    var cameraStatus = await Permission.camera.request();

    // if (storageStatus.isGranted && cameraStatus.isGranted) {
    //   // Permissions granted, you can access storage and camera here
    //   print('Storage and Camera permissions granted');
    // } else {
    //   // Handle denied or permanently denied permissions
    //   if (storageStatus.isDenied || cameraStatus.isDenied) {
    //     print('Storage or Camera permission denied');
    //     openAppSettings();
    //   } else if (storageStatus.isPermanentlyDenied ||
    //       cameraStatus.isPermanentlyDenied) {
    //     print('Storage or Camera permission permanently denied');
    //     openAppSettings(); // Opens app settings for the user to enable permissions
    //   }
    // }
    if (cameraStatus.isGranted) {
      // Permissions granted, you can access storage and camera here
      print('Storage and Camera permissions granted');
      pickGallery(context);
    } else {
      // Handle denied or permanently denied permissions
      if (cameraStatus.isDenied) {
        print('Storage or Camera permission denied');
        openAppSettings();
      } else if (cameraStatus.isPermanentlyDenied) {
        print('Storage or Camera permission permanently denied');
        openAppSettings(); // Opens app settings for the user to enable permissions
      }
    }
  }

  Future<void> pickGallery(BuildContext context) async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    Navigator.pop(context);
    setState(() {
      imagePath = image!.path;
      widget.getFile(image);
    });
  }

  Future<void> pickCamera(BuildContext context) async {
    var image = await picker.pickImage(source: ImageSource.camera);
    Navigator.pop(context);
    setState(() {
      imagePath = image!.path;
      widget.getFile(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        checkPermission(context);
      },
      child: Container(
        width: double.infinity,
        color: imagePath.isNotEmpty ? Colors.grey[200] : Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: imagePath.isNotEmpty ? 0 : 40),
        child: imagePath.isNotEmpty
            ? Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                height: 250,
              )
            : Column(
                children: [
                  Icon(
                    Icons.camera,
                    color: Colors.white,
                    size: 80,
                  ),
                  Text(
                    'Ambil Gambar',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          content: Container(
            height: 130,
            width: double.minPositive,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ambil Gambar',
                  style: TextStyle(
                      fontSize: 22,
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        // await checkPermission(context);
                        var image =
                            await picker.pickImage(source: ImageSource.gallery);
                        // Navigator.pop(context);
                        setState(() {
                          imagePath = image!.path;
                          widget.getFile(image);
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: AppColor.light),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: AppColor.light),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 22,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
