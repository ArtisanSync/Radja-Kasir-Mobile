import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/screens/transaction/components/select_customer_dept.dart';
import 'package:kasir/services/dept_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ActionDept extends StatefulWidget {
  const ActionDept({
    required this.order,
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> order;

  @override
  State<ActionDept> createState() => _ActionDeptState();
}

class _ActionDeptState extends State<ActionDept> {
  DeptServices deptServices = DeptServices();
  Map<String, dynamic>? customer;

  Future<void> submit() async {
    context.loaderOverlay.show();

    if (customer != null) {
      Map<String, dynamic> body = {
        "order_id": widget.order['id'],
        "customer_id": customer!['id'],
        "customer_name": customer!['name'],
        "phone": customer!['phone'],
        "total": widget.order['total']
      };
      var resp = await deptServices.store(body);
      if (resp!.statusCode == 201) {
        context.loaderOverlay.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kasbon berhasil di simpan.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MyHomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi Kesalahan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      context.loaderOverlay.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelanggan belum dipilih silahkan pilih pelanggan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 0.5, color: AppColor.textPrimary),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informasi pemesanan",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Total Tagihan",
                        style: TextStyle(
                            fontSize: 12.sp, color: AppColor.textPrimary),
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(
                            widget.order['total'] ?? 0, 0),
                        style: TextStyle(fontSize: 16.sp),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    Route detail = MaterialPageRoute(
                      builder: (context) => SelectCustomerDept(),
                    );

                    var res = await Navigator.push(context, detail);
                    if (res != null) {
                      setState(() {
                        customer = res;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 0.5, color: AppColor.textPrimary),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${customer != null ? customer!['name'] : 'Pilih pelanggan'}",
                        ),
                        Icon(Icons.people_sharp, color: AppColor.textPrimary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                customer != null
                    ? CustomerDetail(customer: customer)
                    : const SizedBox(),
                const SizedBox(height: 20),
                ButtonPrimary(
                  label: "Simpan",
                  onTap: () => submit(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerDetail extends StatelessWidget {
  const CustomerDetail({
    super.key,
    required this.customer,
  });

  final Map<String, dynamic>? customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 0.3, color: AppColor.textPrimary),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detail Pelanggan",
            style: TextStyle(fontSize: 10.sp),
          ),
          const SizedBox(height: 10),
          Text(
            '${customer!['name'] ?? '-'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${customer!['whatsapp'] ?? '-'}',
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
