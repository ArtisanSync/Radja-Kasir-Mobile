import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/screens/transaction/transaction_paid.dart';
import 'package:kasir/services/transaction_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ActionPayCash extends StatefulWidget {
  const ActionPayCash({
    required this.order,
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> order;

  @override
  State<ActionPayCash> createState() => _ActionPayCashState();
}

class _ActionPayCashState extends State<ActionPayCash> {
  TextEditingController payment = TextEditingController();
  TransactionServices transactionServices = TransactionServices();

  void submit() async {
    context.loaderOverlay.show();
    Map<String, dynamic> body = {
      "order_id": widget.order['id'],
      "ref_number": null,
      'discount': 0,
      'is_percent': 0,
      'payment_method': 'cash',
      'amount_receive': payment.text,
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
  void initState() {
    super.initState();
    payment.text = widget.order['total'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pembayaran Tunai",
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Pembayaran"),
                  Text(
                    CurrencyFormat.convertToIdr(widget.order['total'] ?? 0, 0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextFormField(
                controller: payment,
                decoration: const InputDecoration(
                  hintText: 'Uang Diterima',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusColor: Colors.black12,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              payment.text = widget.order['total'].toString();
                            });
                          },
                          child: const Text('Uang Pas'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              payment.text = '50000';
                            });
                          },
                          child: const Text('50.00'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              payment.text = '100000';
                            });
                          },
                          child: const Text('100.000'),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (int.parse(payment.text) > 0) {
                      submit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.black26),
                  child: const Text(
                    'Terima',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
