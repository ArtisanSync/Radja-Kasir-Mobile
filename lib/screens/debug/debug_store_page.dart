import 'package:flutter/material.dart';
import 'package:kasir/core/use_store.dart';

class DebugStorePage extends StatefulWidget {
  const DebugStorePage({Key? key}) : super(key: key);

  @override
  State<DebugStorePage> createState() => _DebugStorePageState();
}

class _DebugStorePageState extends State<DebugStorePage> {
  String? token;
  dynamic user;
  dynamic store;
  dynamic subscribe;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
    });

    try {
      token = await Store.getToken();
      user = await Store.getUser();
      store = await Store.getStore();
      subscribe = await Store.getSubscribe();
    } catch (e) {
      debugPrint('Error loading store data: $e');
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Store Information'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard('Token', token?.toString() ?? 'Not found'),
                  const SizedBox(height: 16),
                  _buildCard('User', user?.toString() ?? 'Not found'),
                  const SizedBox(height: 16),
                  _buildCard('Store', store?.toString() ?? 'Not found'),
                  const SizedBox(height: 16),
                  _buildCard('Subscribe', subscribe?.toString() ?? 'Not found'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Refresh Data'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
