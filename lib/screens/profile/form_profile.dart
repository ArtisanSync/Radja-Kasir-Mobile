import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/services/profile_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../models/profile_model.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({
    required this.profile,
    Key? key,
  }) : super(key: key);

  final Profile profile;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  ProfileServices profileServices = ProfileServices();
  TextEditingController name = TextEditingController();
  TextEditingController storeType = TextEditingController();
  TextEditingController address = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      name.text = widget.profile.store!;
      storeType.text = widget.profile.storeType!;
      address.text = widget.profile.address!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Update Profile",
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
              SizedBox(height: 20.sp),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
                child: TextInput(label: "Nama Usaha", controller: name),
              ),
              SizedBox(height: 5.sp),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
                child: TextInput(label: "Jenis Usaha", controller: storeType),
              ),
              SizedBox(height: 5.sp),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
                child: TextInput(label: "Alamat", controller: address),
              ),
              SizedBox(height: 20.sp),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonPrimary(
                  label: "Update",
                  onTap: () async {
                    context.loaderOverlay.show();
                    var resp = await profileServices.update({
                      "name": name.text,
                      "address": address.text,
                      "store_type": storeType.text
                    });
                    context.loaderOverlay.hide();
                    if (resp!.statusCode == 201) {
                      Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
