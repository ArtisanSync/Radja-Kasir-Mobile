import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kasir/providers/category_provider.dart';
import 'package:kasir/services/debug_category_service.dart';
import 'package:kasir/screens/debug/debug_store_page.dart';
import 'package:kasir/components/category_card.dart';
import 'package:kasir/components/category_form_dialog.dart';
import 'package:kasir/components/empty_state_widget.dart';

class DebugCategoryPage extends StatefulWidget {
  const DebugCategoryPage({Key? key}) : super(key: key);

  @override
  State<DebugCategoryPage> createState() => _DebugCategoryPageState();
}

class _DebugCategoryPageState extends State<DebugCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _debugInfo;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
    // Load categories when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  Future<void> _loadDebugInfo() async {
    final info = await DebugCategoryService.debugStoreInfo();
    setState(() {
      _debugInfo = info;
    });
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Debug Info: ${_debugInfo.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DebugStorePage(),
                    ),
                  );
                },
                child: const Text('Open Debug Store Page'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final result =
                      await DebugCategoryService.initializeStoreData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Initialize Store: ${result['message']}'),
                        backgroundColor:
                            result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                    if (result['success']) {
                      _loadDebugInfo(); // Reload debug info
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Initialize Store Data'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final result = await DebugCategoryService.testCategoryAPI();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('API Test: ${result['message']}'),
                        backgroundColor:
                            result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Test Category API'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        title: 'Tambah Kategori',
        confirmButtonText: 'Tambah',
        onConfirm: (name) async {
          // Use debug service for better error reporting
          final result = await DebugCategoryService.testCreateCategory(name);

          if (result['success'] && mounted) {
            Navigator.of(context).pop();
            context.read<CategoryProvider>().loadCategories(); // Refresh list
            _showSuccessSnackBar('Kategori berhasil ditambahkan');
          } else if (mounted) {
            _showErrorSnackBar(result['message'] ?? 'Unknown error');
          }
        },
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Kategori Produk (Debug)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showDebugDialog,
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
          ),
          Consumer<CategoryProvider>(
            builder: (context, provider, _) => IconButton(
              onPressed: provider.isLoading ? null : provider.refresh,
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          // Show loading state
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat kategori...'),
                ],
              ),
            );
          }

          // Show error state with debug info
          if (provider.error != null && provider.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    if (_debugInfo != null) ...[
                      Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Has Store: ${_debugInfo!['data']?['hasStore'] ?? false}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Store ID: ${_debugInfo!['data']?['storeId'] ?? 'null'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.clearError();
                            provider.loadCategories();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showDebugDialog,
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Debug'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter categories based on search
          final filteredCategories = _searchQuery.isEmpty
              ? provider.categories
              : provider.searchCategories(_searchQuery);

          return Column(
            children: [
              // Search Bar
              if (provider.hasCategories) ...[
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari kategori...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const Divider(height: 1),
              ],

              // Categories List
              Expanded(
                child: filteredCategories.isEmpty
                    ? EmptyStateWidget(
                        icon: _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.category_outlined,
                        title: _searchQuery.isNotEmpty
                            ? 'Kategori Tidak Ditemukan'
                            : 'Belum Ada Kategori',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Coba kata kunci lain atau buat kategori baru'
                            : 'Mulai dengan menambahkan kategori produk pertama Anda',
                        actionText:
                            _searchQuery.isEmpty ? 'Tambah Kategori' : null,
                        onAction:
                            _searchQuery.isEmpty ? _showCreateDialog : null,
                      )
                    : RefreshIndicator(
                        onRefresh: provider.refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return CategoryCard(
                              name: category.name,
                              productCount: category.productCount,
                              onEdit: () {
                                // TODO: Implement edit
                              },
                              onDelete: () {
                                // TODO: Implement delete
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }
}
