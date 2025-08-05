import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart'; // Temporarily disabled
import 'package:share_plus/share_plus.dart';

import '../helpers/currency_format.dart';

class PDFUtils {
  static Future<XFile> generateReceipt(Map<String, dynamic> order) async {
    // Temporarily disabled: PDF generation requires printing package
    // For now, return a simple text file
    
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final File file = File('$tempPath/receipt_${DateTime.now().millisecondsSinceEpoch}.txt');
    
    String receiptContent = '''
Receipt - ${order['code'] ?? 'N/A'}
Store: ${order['store']?['name'] ?? 'Unknown Store'}
Date: ${DateTime.now().toString()}
Amount: ${order['grand_total'] ?? '0'}

Note: PDF generation temporarily disabled for compatibility.
''';

    await file.writeAsString(receiptContent);
    return XFile(file.path);
  }
          // return pw.Column(
          //   children: [
          //     pw.Icon(
          //       pw.IconData(
          //         Icons.check_circle.codePoint,
          //       ),
          //       size: 80,
          //       font: iconFonts,
          //       color: PdfColor.fromInt(Colors.green[700]!.value),
          //     ),
          //     pw.SizedBox(height: 20),
          //     pw.Text(
          //       "Berhasil",
          //       style: pw.TextStyle(
          //         fontSize: 18.sp,
          //         color: PdfColor.fromInt(AppColor.textPrimary.value),
          //         fontWeight: pw.FontWeight.bold,
          //       ),
          //     ),
          //     pw.Text(
          //       CurrencyFormat.convertToIdr(order['total'] ?? 0, 0),
          //       style: pw.TextStyle(
          //         fontSize: 22.sp,
          //         color: PdfColor.fromInt(AppColor.textPrimary.value),
          //         fontWeight: pw.FontWeight.bold,
          //       ),
          //     ),
          //     pw.SizedBox(height: 30),
          //     pw.Row(
          //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //       children: [
          //         pw.Text("No. invoice", style: pw.TextStyle(fontSize: 14.sp)),
          //         pw.Text("${order['inv_number']}",
          //             style: pw.TextStyle(fontSize: 14.sp)),
          //       ],
          //     ),
          //     pw.SizedBox(height: 10),
          //     pw.Row(
          //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //       children: [
          //         pw.Text("Pembayaran", style: pw.TextStyle(fontSize: 14.sp)),
          //         pw.Text("${order['payment_type']}",
          //             style: pw.TextStyle(fontSize: 14.sp)),
          //       ],
          //     ),
          //     pw.SizedBox(height: 10),
          //     pw.Row(
          //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //       children: [
          //         pw.Text("Total tagihan",
          //             style: pw.TextStyle(fontSize: 14.sp)),
          //         pw.Text(CurrencyFormat.convertToIdr(order['total'] ?? 0, 0),
          //             style: pw.TextStyle(fontSize: 14.sp)),
          //       ],
          //     ),
          //     pw.SizedBox(height: 10),
          //     pw.Row(
          //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //       children: [
          //         pw.Text("Diterima", style: pw.TextStyle(fontSize: 14.sp)),
          //         pw.Text(
          //             CurrencyFormat.convertToIdr(
          //                 order['amount_receive'] ?? 0, 0),
          //             style: pw.TextStyle(fontSize: 14.sp)),
          //       ],
          //     ),
          //     pw.SizedBox(height: 10),
          //     pw.Row(
          //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //       children: [
          //         pw.Text("Kembalian",
          //             style: pw.TextStyle(
          //                 fontSize: 14.sp, fontWeight: pw.FontWeight.bold)),
          //         pw.Text(
          //             CurrencyFormat.convertToIdr(
          //                 order != null
          //                     ? (order['amount_receive'] - order["total"])
          //                     : 0,
          //                 0),
          //             style: pw.TextStyle(
          //                 fontSize: 14.sp, fontWeight: pw.FontWeight.bold)),
          //       ],
          //     ),
          //     pw.SizedBox(height: 30),
          //     pw.Text(
          //       "Dokumen ini dicetak dengan aplikasi, Radjakasir",
          //       style: pw.TextStyle(
          //         fontSize: 12.sp,
          //         color: PdfColor.fromInt(AppColor.textPrimary.value),
          //       ),
          //     ),
          //   ],
          // );
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  netImage != null
                      ? pw.Image(netImage, width: 40.sp)
                      : pw.SizedBox(),
                ],
              ),
              pw.Center(
                child: pw.Text(
                  order['store']['store'],
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10.sp),
                ),
              ),
              pw.Center(
                child: pw.Text(order['store']['address'],
                    style: pw.TextStyle(fontSize: 7.sp)),
              ),
              pw.Center(
                child: pw.Text("Whatsapp: ${order['store']['whatsapp']}",
                    style: pw.TextStyle(fontSize: 7.sp)),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Tanggal", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.Text(DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(fontSize: 7.sp))
                ],
              ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Text("No. Pesanan :", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.SizedBox(width: 10.sp),
                  pw.Text(
                    order['inv_number'],
                    style: pw.TextStyle(fontSize: 7.sp),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text("Pembayaran :", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.SizedBox(width: 10.sp),
                  pw.Text(
                    order['payment_type'],
                    style: pw.TextStyle(fontSize: 7.sp),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text("Kasir :", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.SizedBox(width: 10.sp),
                  pw.Text(
                    order['store']['name'],
                    style: pw.TextStyle(fontSize: 7.sp),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text("PPN :", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.SizedBox(width: 10.sp),
                  pw.Text(
                    CurrencyFormat.convertToIdr(order['ppn'] ?? 0, 0),
                    style: pw.TextStyle(fontSize: 7.sp),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text("Sub Total :", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.SizedBox(width: 10.sp),
                  pw.Text(
                    CurrencyFormat.convertToIdr(order['sub_total'] ?? 0, 0),
                    style: pw.TextStyle(fontSize: 7.sp),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text("Total :", style: pw.TextStyle(fontSize: 7.sp)),
                  pw.SizedBox(width: 10.sp),
                  pw.Text(
                    CurrencyFormat.convertToIdr(order['total'] ?? 0, 0),
                    style: pw.TextStyle(fontSize: 7.sp),
                  ),
                ],
              ),
              pw.Divider(),
              pw.ListView.builder(
                itemCount: order['items'].length,
                itemBuilder: (context, int index) {
                  var item = order['items'][index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item['product_name'],
                              style: pw.TextStyle(fontSize: 7.sp),
                            ),
                            pw.Text(
                              "DISC: ${CurrencyFormat.convertToIdr(item['discount'] ?? 0, 00)}",
                              style: pw.TextStyle(fontSize: 7.sp),
                            ),
                          ]),
                      pw.Row(children: [
                        pw.Text(
                          "QTY: ${item['quantity']}",
                          style: pw.TextStyle(fontSize: 7.sp),
                        ),
                        pw.SizedBox(
                          width: 20,
                        ),
                        pw.Text(
                          "Total: ${CurrencyFormat.convertToIdr(item['total'] - item['discount'] ?? 0, 0)}",
                          style: pw.TextStyle(fontSize: 7.sp),
                        ),
                      ])
                    ],
                  );
                },
              ),
              pw.Divider(),
              pw.Center(
                child: pw.Text("Terima Kasih, ${order['store']['store']}",
                    style: pw.TextStyle(fontSize: 7.sp)),
              )
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
        "${output.path}/receipt${DateFormat("ddMMMMyyyyhms").format(DateTime.now())}.pdf");
    await file.writeAsBytes(await pdf.save());

    return XFile(file.path);
  }
}
