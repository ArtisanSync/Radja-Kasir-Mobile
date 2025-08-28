import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key, required this.getFile});

  final Function(XFile?) getFile;
  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = image;
          widget.getFile(image);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> checkPermission(BuildContext context) async {
    try {
      // Periksa permission kamera
      var cameraStatus = await Permission.camera.request();
      
      // Periksa permission galeri (penyimpanan)
      var galleryStatus = Platform.isAndroid 
          ? await Permission.storage.request() 
          : await Permission.photos.request();
      
      if (cameraStatus.isGranted && 
          (galleryStatus.isGranted || galleryStatus.isLimited)) {
        // Tampilkan dialog pilihan sumber
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Ambil dari Galeri'),
                    onTap: () {
                      Navigator.of(context).pop();
                      pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Ambil Foto'),
                    onTap: () {
                      Navigator.of(context).pop();
                      pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Tampilkan pesan jika izin tidak diberikan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Aplikasi membutuhkan izin kamera dan galeri untuk mengambil gambar'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => checkPermission(context),
      child: Container(
        width: double.infinity,
        color: _imageFile != null ? Colors.grey[200] : Colors.blue[700],
        padding: EdgeInsets.symmetric(vertical: _imageFile != null ? 0 : 40),
        child: _imageFile != null
            ? Image.file(
                File(_imageFile!.path),
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
}
