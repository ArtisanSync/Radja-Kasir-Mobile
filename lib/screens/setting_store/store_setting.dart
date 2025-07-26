import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/services/setting_store_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../components/builder_menu.dart';
import '../../components/nav_drawer.dart';

class StoreSetting extends StatefulWidget {
  const StoreSetting({Key? key}) : super(key: key);

  @override
  State<StoreSetting> createState() => _StoreSettingState();
}

class _StoreSettingState extends State<StoreSetting> {
  final _formStoreSetting = GlobalKey<FormState>();
  TextEditingController ppn = TextEditingController();
  StoreSettingServices storeSettingServices = StoreSettingServices();

  int? settingId;

  Future<void> fetchData() async {
    context.loaderOverlay.show();
    var response = await storeSettingServices.lists();
    setState(() {
      settingId = response.data['data']['setting_id'];
      ppn.text = response.data['data']['ppn'].toString();
    });
    context.loaderOverlay.hide();
  }

  Future<void> submit() async {
    context.loaderOverlay.show();
    Map<String, dynamic> body = {
      "ppn": ppn.text.trim()
    };
    var response = await storeSettingServices.store(settingId!, body);
    context.loaderOverlay.hide();
    if(response.statusCode == 201){
      fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pengaturan Toko",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const MenuBuilder(),
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
          key: _formStoreSetting,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInput(
                  label: "Pajak Pertambahan Nilai - PPN (%)",
                  controller: ppn,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonPrimary(
                  label: "Simpan Pengaturan",
                  onTap: () => submit(),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
