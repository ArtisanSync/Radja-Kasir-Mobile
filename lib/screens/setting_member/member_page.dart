import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/models/member_model.dart';
import 'package:kasir/screens/setting_member/member_create.dart';
import 'package:kasir/services/user_services.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  UserServices userServices = UserServices();
  List<ListMember> member = [];
  bool btnAdd = false;
  int countAdd = 0;

  void refresh() {
    getSubs();
    fetchData();
  }

  Future<void> getSubs() async {
    var store = await Store.getSubscribe();
    setState(() {
      btnAdd = store['add_member']!['enable'];
      countAdd = store['add_member']!['count'];
    });
  }

  Future<void> fetchData() async {
    var resp = await userServices.lists();
    var data = Member.fromJson(resp.data);

    if (resp!.statusCode == 200) {
      setState(() {
        member = data.data!;
      });
    }
  }

  Future<void> delete(int id) async {
    var resp = await userServices.destroy(id);
    if (resp!.statusCode == 201) {
      refresh();
    }
  }

  @override
  void initState() {
    fetchData();
    getSubs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pengaturan Member",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    Container(height: 1, color: Colors.grey[300]),
                itemCount: member.length,
                itemBuilder: (context, index) {
                  ListMember user = member[index];
                  if (member.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.name}",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("${user.email}"),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.red[50],
                            child: IconButton(
                              onPressed: () async {
                                if (await confirm(
                                  context,
                                  title: const Text('Confirm'),
                                  content: const Text(
                                      'Apakah anda ingin menghapus data ini?'),
                                  textOK: const Text('Yes'),
                                  textCancel: const Text('No'),
                                )) {
                                  delete(user.id as int);
                                }
                                return print('pressedCancel');
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red[800],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: btnAdd == true && member.length < countAdd
          ? FloatingActionButton(
              onPressed: () {
                Route detail = MaterialPageRoute(
                  builder: (context) => const MemberCreate(),
                );

                Navigator.push(context, detail).then(
                  (value) => refresh(),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : const SizedBox(),
    );
  }
}
