import 'package:flutter/material.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/product_services.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final ProductServices productServices = ProductServices();
  String debugInfo = 'Tap Test to run debug';

  Future<void> runDebugTest() async {
    setState(() {
      debugInfo = 'Running tests...';
    });

    StringBuffer buffer = StringBuffer();

    try {
      // Test 1: Check stored data
      buffer.writeln('=== STORED DATA TEST ===');
      final user = await Store.getUser();
      final store = await Store.getStore();
      final token = await Store.getToken();

      buffer.writeln('User: ${user?.toString() ?? 'NULL'}');
      buffer.writeln('Store: ${store?.toString() ?? 'NULL'}');
      buffer
          .writeln('Token: ${token?.toString().substring(0, 20) ?? 'NULL'}...');
      buffer.writeln('');

      // Test 2: Test Product List
      buffer.writeln('=== PRODUCT LIST TEST ===');
      final productResponse = await productServices.listProduct();
      buffer.writeln('Products Response:');
      buffer.writeln('Success: ${productResponse['success']}');
      buffer.writeln('Message: ${productResponse['message']}');
      buffer.writeln(
          'Data: ${productResponse['data']?.toString().substring(0, 100) ?? 'NULL'}...');
      buffer.writeln('');

      // Test 3: Test Category List
      buffer.writeln('=== CATEGORY LIST TEST ===');
      final categoryResponse = await productServices.listCategory();
      buffer.writeln('Categories Response:');
      buffer.writeln('Success: ${categoryResponse['success']}');
      buffer.writeln('Message: ${categoryResponse['message']}');
      buffer.writeln(
          'Data: ${categoryResponse['data']?.toString().substring(0, 100) ?? 'NULL'}...');
      buffer.writeln('');

      // Test 4: Test Units
      buffer.writeln('=== UNITS TEST ===');
      final unitsResponse = await productServices.getUnits();
      buffer.writeln('Units Response:');
      buffer.writeln('Success: ${unitsResponse['success']}');
      buffer.writeln('Message: ${unitsResponse['message']}');
      buffer.writeln(
          'Data: ${unitsResponse['data']?.toString().substring(0, 100) ?? 'NULL'}...');
    } catch (e) {
      buffer.writeln('ERROR: $e');
    }

    setState(() {
      debugInfo = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: runDebugTest,
              child: const Text('Run Debug Test'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    debugInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
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
