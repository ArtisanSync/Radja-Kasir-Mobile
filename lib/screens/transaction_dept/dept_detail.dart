import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/dept/dept.dart';
import 'package:kasir/models/dept/order_detail.dart';
import 'package:kasir/services/dept_services.dart';

class DeptDetail extends StatefulWidget {
  const DeptDetail({
    required this.id,
    super.key,
  });

  final String id;
  @override
  State<DeptDetail> createState() => _DeptDetailState();
}

class _DeptDetailState extends State<DeptDetail> {
  DeptServices deptServices = DeptServices();
  Dept dept = Dept();
  bool loading = false;
  bool loadingPaid = false;

  Future<void> fetch() async {
    setState(() {
      loading = true;
    });
    var resp = await deptServices.detail(widget.id);
    var data = Dept.fromMap(resp.data['data']);
    if (resp!.statusCode == 200) {
      setState(() {
        dept = data;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Kasbon Detil",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => fetch(),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dept.paid == true
                        ? Container(
                            color: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Center(
                                child: Text(
                              "LUNAS",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          )
                        : const SizedBox(),
                    const Divider(height: 1),
                    DeptGeneral(dept: dept),
                    const Divider(height: 1),
                    DetpOrderDetail(dept: dept)
                  ],
                ),
              ),
      ),
      floatingActionButton: dept.paid == false
          ? FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              elevation: 0,
              onPressed: () async {
                if (!loading) {
                  setState(() {
                    loadingPaid = true;
                  });
                  if (await confirm(
                    context,
                    title: const Text('Lunas'),
                    content: const Text('Selesaikan tagihan ini!'),
                    textOK: const Text('Yes'),
                    textCancel: const Text('No'),
                  )) {
                    var resp = await deptServices.paid(widget.id);
                    if (resp!.statusCode == 201) {
                      Navigator.pop(context);
                    }
                    setState(() {
                      loadingPaid = false;
                    });
                  }
                } else {
                  return null;
                }
              },
              child: loading ? Icon(Icons.timelapse) : Icon(Icons.check_circle))
          : SizedBox(),
    );
  }
}

class DetpOrderDetail extends StatelessWidget {
  const DetpOrderDetail({
    super.key,
    required this.dept,
  });

  final Dept dept;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('List Item'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dept.orderDetails!.length,
            itemBuilder: (BuildContext context, index) {
              OrderDetail item = dept.orderDetails![index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item.productName}"),
                    Row(
                      children: [
                        Text(
                          "Qty: ${item.quantity}",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "U. Price: ${CurrencyFormat.convertToIdr(item.unitPrice ?? 0, 0)}",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Total: ${CurrencyFormat.convertToIdr(item.total ?? 0, 0)}",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DeptGeneral extends StatelessWidget {
  const DeptGeneral({
    super.key,
    required this.dept,
  });

  final Dept dept;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No. Pemesanan',
            style: TextStyle(color: AppColor.textPrimary),
          ),
          Text("${dept.order!.invNumber}"),
          const SizedBox(height: 10),
          const Text(
            'Pelanggan',
            style: TextStyle(color: AppColor.textPrimary),
          ),
          Text("${dept.customerName}"),
          const SizedBox(height: 10),
          const Text(
            'No. Tlp',
            style: TextStyle(color: AppColor.textPrimary),
          ),
          Text("${dept.phone}"),
          const SizedBox(height: 10),
          const Text(
            'Total Tagihan',
            style: TextStyle(color: AppColor.textPrimary),
          ),
          Text(CurrencyFormat.convertToIdr(dept.total ?? 0, 0)),
        ],
      ),
    );
  }
}
