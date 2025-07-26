import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/dept_model.dart';
import 'package:kasir/screens/transaction_dept/dept_detail.dart';
import 'package:kasir/services/dept_services.dart';

import '../../components/builder_menu.dart';
import '../../components/nav_drawer.dart';

class DeptPage extends StatefulWidget {
  const DeptPage({Key? key}) : super(key: key);

  @override
  State<DeptPage> createState() => _DeptPageState();
}

class _DeptPageState extends State<DeptPage> {
  DeptServices deptServices = DeptServices();
  bool loading = false;
  List<Datum> depts = [];

  Future<void> fetch() async {
    setState(() {
      loading = true;
    });
    var resp = await deptServices.list();
    var data = DeptModel.fromJson(resp.data);
    if (resp!.statusCode == 200) {
      setState(() {
        depts = data.data!;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Kasbon",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => fetch(),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                shrinkWrap: true,
                itemCount: depts.length,
                separatorBuilder: (BuildContext context, int) =>
                    Divider(height: 0),
                itemBuilder: (context, index) {
                  if (depts.isNotEmpty) {
                    var dept = depts[index];
                    return InkWell(
                      onTap: () {
                        Route detail = MaterialPageRoute(
                          builder: (context) => DeptDetail(
                            id: dept.id.toString(),
                          ),
                        );

                        Navigator.push(context, detail).then(
                          (value) => fetch(),
                        );
                      },
                      child: Stack(alignment: Alignment.bottomLeft, children: [
                        ContainerDept(dept: dept),
                        dept.paid == true
                            ? Positioned(
                                bottom: 15.sp,
                                left: 10.sp,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.withOpacity(0.4),
                                      size: 30.sp,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "LUNAS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.withOpacity(0.5)),
                                    )
                                  ],
                                ),
                              )
                            : const SizedBox()
                      ]),
                    );
                  }
                },
              ),
      ),
    );
  }
}

class ContainerDept extends StatelessWidget {
  const ContainerDept({
    super.key,
    required this.dept,
  });

  final Datum dept;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                '${dept.customerName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'tlp, ${dept.phone}',
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${dept.created}',
                style: TextStyle(fontSize: 10.sp),
              ),
              Text(
                CurrencyFormat.convertToIdr(dept.total ?? 0, 0),
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          )
        ],
      ),
    );
  }
}
