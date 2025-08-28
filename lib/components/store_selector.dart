import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/helpers/store.dart';
import 'package:kasir/models/store_model.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:kasir/screens/store/store_list_page.dart';

class StoreSelector extends ConsumerStatefulWidget {
  final Function(String storeId)? onStoreSelected;
  
  const StoreSelector({Key? key, this.onStoreSelected}) : super(key: key);

  @override
  ConsumerState<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends ConsumerState<StoreSelector> {
  String? _currentStoreId;
  String _currentStoreName = 'Pilih Toko';
  
  @override
  void initState() {
    super.initState();
    _loadCurrentStore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStores();
    });
  }
  
  Future<void> _loadCurrentStore() async {
    try {
      final currentStore = await Store.getStore();
      if (currentStore != null && currentStore['id'] != null) {
        setState(() {
          _currentStoreId = currentStore['id'];
          _currentStoreName = currentStore['name'] ?? 'Toko';
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadStores() async {
    await ref.read(storeProvider.notifier).loadMyStores();
  }

  Future<void> _changeStore(StoreModel store) async {
    try {
      await Store.saveStore({
        'id': store.id,
        'name': store.name,
        'description': store.description,
        'address': store.address,
      });

      setState(() {
        _currentStoreId = store.id;
        _currentStoreName = store.name;
      });
      
      if (widget.onStoreSelected != null) {
        widget.onStoreSelected!(store.id);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Beralih ke toko: ${store.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal beralih toko: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _showStorePickerSheet(context, storeState.stores),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.building_2_fill,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _currentStoreName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _showStorePickerSheet(BuildContext context, List<StoreModel> stores) {
    if (stores.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StoreListPage(),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Pilih Toko',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoreListPage(),
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.building_2_fill, size: 16),
                  label: const Text('Kelola Toko'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: stores.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final store = stores[index];
                final isSelected = store.id == _currentStoreId;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      CupertinoIcons.building_2_fill,
                      color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    store.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(store.address),
                  trailing: isSelected 
                    ? Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      _changeStore(store);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}