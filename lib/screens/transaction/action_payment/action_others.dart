import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/product/form_product.dart';
import 'package:kasir/screens/transaction/transaction_paid.dart';
import 'package:kasir/services/transaction_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ActionPayOthers extends StatefulWidget {
  const ActionPayOthers({
    required this.order,
    required this.type,
    super.key,
  });

  final Map<String, dynamic> order;
  final Map<String, dynamic> type;
  @override
  State<ActionPayOthers> createState() => _ActionPayOthersState();
}

class _ActionPayOthersState extends State<ActionPayOthers> {
  final TextEditingController ref = TextEditingController();
  TransactionServices transactionServices = TransactionServices();

  void submit() async {
    context.loaderOverlay.show();
    Map<String, dynamic> body = {
      "order_id": widget.order['id'],
      "ref_number": ref.text,
      'discount': 0,
      'is_percent': 0,
      'payment_method': widget.type['value'],
      'amount_receive': widget.order['total'],
      'amount_order': widget.order['total']
    };
    var resp = await transactionServices.payment(widget.order['id'], body);
    if (resp!.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (contect) => TransactionPaidScreen(
                  id: widget.order['id'],
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "${widget.type['label']}",
          style: const TextStyle(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Total',
                style: TextStyle(fontSize: 12.sp),
              ),
              Text(
                CurrencyFormat.convertToIdr(widget.order['total'] ?? 0, 0),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextInput(label: "Referensi", validate: false, controller: ref),
              const Text("*Tidak wajib diisi"),
              const SizedBox(height: 30),
              ButtonPrimary(label: "Submit", onTap: () => submit())
            ],
          ),
        ),
      ),
    );
  }
}
