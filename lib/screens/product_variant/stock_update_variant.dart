import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/components/text_input.dart';
import 'package:kasir/services/product_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class UpdateStockVariant extends StatefulWidget {
  const UpdateStockVariant({
    required this.variant,
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> variant;

  @override
  State<UpdateStockVariant> createState() => _UpdateStockVariantState();
}

class _UpdateStockVariantState extends State<UpdateStockVariant> {
  ProductServices productServices = ProductServices();

  TextEditingController quantity = TextEditingController();
  TextEditingController capital_price = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController disc_rp = TextEditingController();
  TextEditingController disc_percent = TextEditingController();

  Future<void> submit(BuildContext context) async {
    Map<String, dynamic> body = {
      "quantity": quantity.text,
      "capital_price": capital_price.text,
      "price": price.text,
      "tax": tax.text,
    };
    var resp =
        await productServices.updateStock(context, body, widget.variant['id']);
    if (resp!.statusCode == 201) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      quantity.text = widget.variant['quantity'].toString();
      capital_price.text = widget.variant['capital_price'].toString();
      price.text = widget.variant['price'].toString();
      tax.text = widget.variant['tax'].toString();
      disc_rp.text = widget.variant['disc_rp'].toString();
      disc_percent.text = widget.variant['quantity'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Update Stok",
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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInput(
                  label: "Quantity",
                  controller: quantity,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInput(
                    label: "Harga modal",
                    controller: capital_price,
                    type: TextInputType.number),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInput(
                    label: "Harga jual",
                    controller: price,
                    type: TextInputType.number),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInput(
                    label: "Pajak",
                    controller: tax,
                    type: TextInputType.number),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonPrimary(
                    label: "Update", onTap: () => submit(context)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
