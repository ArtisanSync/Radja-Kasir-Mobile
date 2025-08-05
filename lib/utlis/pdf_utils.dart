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
RECEIPT
=======
Store: ${order['store']?['name'] ?? 'Unknown Store'}
Receipt Code: ${order['code'] ?? 'N/A'}
Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}

Items:
${order['items']?.map((item) => '- ${item['name'] ?? 'Item'} x${item['qty'] ?? 1} = Rp ${CurrencyFormat.convertToIdr(item['total'] ?? 0, 0)}').join('\n') ?? 'No items'}

Subtotal: Rp ${CurrencyFormat.convertToIdr(order['sub_total'] ?? 0, 0)}
Tax: Rp ${CurrencyFormat.convertToIdr(order['tax'] ?? 0, 0)}
Total: Rp ${CurrencyFormat.convertToIdr(order['grand_total'] ?? 0, 0)}

Payment Method: ${order['payment_method'] ?? 'Unknown'}
Status: ${order['status'] ?? 'Unknown'}

Note: PDF generation temporarily disabled for compatibility.
Thank you for your purchase!
''';

    await file.writeAsString(receiptContent);
    return XFile(file.path);
  }

  static Future<XFile> generateInvoice(Map<String, dynamic> order) async {
    // Temporarily disabled: PDF generation requires printing package
    // For now, return a simple text file similar to receipt
    
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final File file = File('$tempPath/invoice_${DateTime.now().millisecondsSinceEpoch}.txt');
    
    String invoiceContent = '''
INVOICE
=======
Store: ${order['store']?['name'] ?? 'Unknown Store'}
Invoice Number: ${order['code'] ?? 'N/A'}
Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}

Bill To:
${order['customer']?['name'] ?? 'Customer'}
${order['customer']?['address'] ?? ''}

Items:
${order['items']?.map((item) => '- ${item['name'] ?? 'Item'} x${item['qty'] ?? 1} @ Rp ${CurrencyFormat.convertToIdr(item['price'] ?? 0, 0)} = Rp ${CurrencyFormat.convertToIdr(item['total'] ?? 0, 0)}').join('\n') ?? 'No items'}

Subtotal: Rp ${CurrencyFormat.convertToIdr(order['sub_total'] ?? 0, 0)}
Tax: Rp ${CurrencyFormat.convertToIdr(order['tax'] ?? 0, 0)}
TOTAL: Rp ${CurrencyFormat.convertToIdr(order['grand_total'] ?? 0, 0)}

Payment Terms: ${order['payment_method'] ?? 'Cash'}
Status: ${order['status'] ?? 'Pending'}

Note: PDF generation temporarily disabled for compatibility.
''';

    await file.writeAsString(invoiceContent);
    return XFile(file.path);
  }
}
