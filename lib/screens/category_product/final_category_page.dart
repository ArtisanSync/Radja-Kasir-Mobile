import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kasir/providers/category_provider.dart';
import 'package:kasir/services/store_services.dart';
import 'package:kasir/components/category_card.dart';
import 'package:kasir/components/category_form_dialog.dart';
import 'package:kasir/components/empty_state_widget.dart';
import 'package:kasir/core/use_store.dart';

class FinalCategoryPage extends StatefulWidget {
  const FinalCategoryPage({Key? key}) : super(key: key);

  @override
  State<FinalCategoryPage> createState() => _FinalCategoryPageState();
}

class _FinalCategoryPageState extends State<FinalCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final StoreServices _storeServices = StoreServices();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Check if store data exists, if not initialize it
    final store = await Store.getStore();
    if (store == null || store['id'] == null) {
      await _storeServices.initializeStore();
    }

    // Load categories
    if (mounted) {
      context.read<CategoryProvider>().loadCategories();
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        title: 'Tambah Kategori',
        confirmButtonText: 'Tambah',
        onConfirm: (name) async {
          final provider = context.read<CategoryProvider>();
          final success = await provider.createCategory(name);

          if (success && mounted) {
            Navigator.of(context).pop();
            _showSuccessSnackBar('Kategori berhasil ditambahkan');
          } else if (mounted && provider.error != null) {
            _showErrorSnackBar(provider.error!);
          }
        },
      ),
    );
  }

  void _showEditDialog(String categoryId, String currentName) {
    showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        title: 'Edit Kategori',
        confirmButtonText: 'Simpan',
        initialName: currentName,
        onConfirm: (name) async {
          final provider = context.read<CategoryProvider>();
          final success = await provider.updateCategory(categoryId, name);

          if (success && mounted) {
            Navigator.of(context).pop();
            _showSuccessSnackBar('Kategori berhasil diperbarui');
          } else if (mounted && provider.error != null) {
            _showErrorSnackBar(provider.error!);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(
      String categoryId, String categoryName, int productCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[600],
            ),
            const SizedBox(width: 8),
            const Text('Hapus Kategori'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus kategori "$categoryName"?'),
            if (productCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kategori ini memiliki $productCount produk. Pastikan untuk memindahkan produk ke kategori lain terlebih dahulu.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          Consumer<CategoryProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isSubmitting
                  ? null
                  : () async {
                      final success = await provider.deleteCategory(categoryId);

                      if (success && mounted) {
                        Navigator.of(context).pop();
                        _showSuccessSnackBar('Kategori berhasil dihapus');
                      } else if (mounted && provider.error != null) {
                        _showErrorSnackBar(provider.error!);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: provider.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Hapus'),
            ),
          ),
        ],
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
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Coba Lagi',
          textColor: Colors.white,
          onPressed: () {
            context.read<CategoryProvider>().clearError();
            _initializeData();
          },
        ),
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
          'Kategori Produk',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<CategoryProvider>(
            builder: (context, provider, _) => IconButton(
              onPressed: provider.isLoading
                  ? null
                  : () {
                      provider.refresh();
                    },
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

          // Show error state
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
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.clearError();
                        _initializeData();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
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
                        onRefresh: () async {
                          await _initializeData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return CategoryCard(
                              name: category.name,
                              productCount: category.productCount,
                              onEdit: () => _showEditDialog(
                                category.id!,
                                category.name,
                              ),
                              onDelete: () => _showDeleteDialog(
                                category.id!,
                                category.name,
                                category.productCount,
                              ),
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
