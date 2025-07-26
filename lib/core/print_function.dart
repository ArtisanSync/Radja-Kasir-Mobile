import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:image/image.dart' as IMG;

class Print {
  const Print();

  Future<void> base(Map<String, dynamic> order) async {
    final user = await Store.getUser();
    final store = await Store.getStore();
    Uint8List? imageBytesFromNetwork;

    BlueThermalPrinter printer = BlueThermalPrinter.instance;
    bool? isConnected = await printer.isConnected;

    if (order["store"]["logo"] != null &&
        isConnected != null &&
        isConnected == true) {
      debugPrint(order["store"]["logo"]);
      var response = await http.get(Uri.parse(
          order["store"]["logo"].toString().replaceAll("logo//", "logo/")));
      Uint8List bytesNetwork = response.bodyBytes;
      Uint8List resizedData = bytesNetwork.buffer
          .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);
      IMG.Image? img = IMG.decodeImage(resizedData);
      IMG.Image resized = IMG.copyResize(img!, width: 200, height: 200);
      resizedData = IMG.encodeJpg(resized);
      imageBytesFromNetwork = resizedData;
    }

    if (isConnected != null && isConnected == true) {
      printer.printNewLine();
      if (imageBytesFromNetwork != null) {
        printer.printImageBytes(
          imageBytesFromNetwork,
        );
      }
      printer.printNewLine();
      printer.printNewLine();
      printer.printCustom("${order['store']['store'] ?? ''}", 1, 1);
      printer.printCustom("${order['store']['address'] ?? ''}", 0, 1);
      printer.printCustom(
          "Whatsapp: ${order['store']['whatsapp'] ?? ''}", 0, 1);
      printer.printNewLine();
      printer.printLeftRight(
          "Tanggal", DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()), 0);
      printer.printNewLine();
      printer.printCustom("------------------------------------------", 0, 0);
      printer.printCustom("No. Pesanan: ${order['inv_number']}", 0, 0);
      printer.printCustom("Pembayaran: ${order['payment_type']}", 0, 0);
      printer.printCustom("Kasir: ${user['name']}", 0, 0);
      printer.printCustom(
          "PPN: ${CurrencyFormat.convertToIdr(order['ppn'] ?? 0, 0)}", 0, 0);
      printer.printCustom(
          "Sub Total: ${CurrencyFormat.convertToIdr(order['sub_total'] ?? 0, 0)}",
          0,
          0);
      printer.printCustom(
          "Total: ${CurrencyFormat.convertToIdr(order['total'] ?? 0, 0)}",
          0,
          0);
      printer.printCustom("------------------------------------------", 0, 0);
      printer.printCustom(
          "Uang Diterima: ${CurrencyFormat.convertToIdr(order['amount_receive'] ?? 0, 0)}",
          0,
          0);
      printer.printCustom(
          "Kembalian: ${CurrencyFormat.convertToIdr((order['amount_receive'] - order['total']) ?? 0, 0)}",
          0,
          0);
      printer.printCustom("------------------------------------------", 0, 0);
      for (var line in order['items']) {
        printer.printCustom(line['product_name'].toString(), 0, 0);
        printer.printCustom(
            "Qty: ${line['quantity']}, Disc: ${line['discount']}, Total: ${CurrencyFormat.convertToIdr(line['total'] - line['discount'] ?? 0, 0)}",
            0,
            2);
        printer.printCustom("------------------------------------------", 0, 0);
      }
      printer.printCustom(
          "Total: ${CurrencyFormat.convertToIdr(order['total'] ?? 0, 0)}",
          0,
          0);
      printer.printCustom("------------------------------------------", 0, 0);
      printer.printNewLine();
      printer.printCustom("Terima kasih", 1, 1);
      printer.printNewLine();
      printer.printNewLine();
      printer.printNewLine();
    } else {
      print("printer tidak connect");
      return;
    }
  }
}
