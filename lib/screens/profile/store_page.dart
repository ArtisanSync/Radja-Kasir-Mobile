// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/models/profile_model.dart';
import 'package:kasir/screens/profile/form/upload_logo.dart';
import 'package:kasir/screens/profile/form/upload_stamp.dart';
import 'package:kasir/services/profile_services.dart';

import '../../components/image_avatar.dart';
import 'form_profile.dart';

class ProfileStorePage extends StatefulWidget {
  const ProfileStorePage({
    super.key,
  });

  @override
  State<ProfileStorePage> createState() => _ProfileStorePageState();
}

class _ProfileStorePageState extends State<ProfileStorePage> {
  ProfileServices profileServices = ProfileServices();
  late bool _loading = false;
  Profile profile = Profile();

  Future<dynamic> getData() async {
    setState(() {
      _loading = true;
    });
    var resp = await profileServices.profile();
    var data = Profile.fromJson(resp.data['data']);
    if (resp!.statusCode == 200) {
      setState(() {
        profile = data;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Profil Usaha",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Route detail = MaterialPageRoute(
                  builder: (context) => ProfileFormScreen(
                    profile: profile,
                  ),
                );
                Navigator.push(context, detail).then(
                  (value) => getData(),
                );
              },
              icon: Icon(Icons.edit_note_outlined))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => getData(),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListData(label: "Nama User", name: "${profile.name}"),
                        ListData(label: "Email", name: "${profile.email}"),
                        ListData(label: "Nama Usaha", name: "${profile.store}"),
                        ListData(
                            label: "Jenis Usaha", name: "${profile.storeType}"),
                        ListData(label: "Alamat", name: "${profile.address}"),
                        ListData(label: "Email", name: "${profile.email}"),
                        ListData(
                            label: "Whatsapp", name: "${profile.whatsapp}"),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Logo"),
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: IconButton(
                                    onPressed: () {
                                      Route detail = MaterialPageRoute(
                                          builder: (context) =>
                                              FormUploadLogo());
                                      Navigator.push(context, detail).then(
                                        (value) => getData(),
                                      );
                                    },
                                    icon: Icon(Icons.upload)),
                              )
                            ],
                          ),
                          AvatarImageCache(url: profile.logo),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}

class ListData extends StatelessWidget {
  const ListData({
    super.key,
    required this.label,
    required this.name,
  });

  final String label;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '$label',
        style: TextStyle(fontSize: 12),
      ),
      subtitle: Text(
        '$name',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      tileColor: Colors.white,
    );
  }
}
