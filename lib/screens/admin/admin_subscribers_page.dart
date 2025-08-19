import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/providers/admin_providers.dart';
import 'package:kasir/models/admin_models.dart';
import 'package:kasir/helpers/currency_format.dart';

class AdminSubscribersPage extends ConsumerStatefulWidget {
  const AdminSubscribersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminSubscribersPage> createState() => _AdminSubscribersPageState();
}

class _AdminSubscribersPageState extends ConsumerState<AdminSubscribersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscribersProvider.notifier).loadSubscribers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscribersState = ref.watch(subscribersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavDrawer(currentRoute: 'admin_subscribers'),
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const MenuBuilder(),
        title: Text(
          'Kelola Pengguna',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: subscribersState.isLoading 
                ? null 
                : () => ref.read(subscribersProvider.notifier).loadSubscribers(),
            icon: subscribersState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(CupertinoIcons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context, theme, subscribersState),
          Expanded(
            child: _buildSubscribersList(context, theme, subscribersState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ThemeData theme, SubscribersState state) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengguna...',
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(CupertinoIcons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(subscribersProvider.notifier).updateSearch('');
                      setState(() {});
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              ref.read(subscribersProvider.notifier).updateSearch(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Akan Berakhir'),
                  selected: state.expiringOnlyFilter,
                  onSelected: (selected) {
                    ref.read(subscribersProvider.notifier).updateExpiringFilter(selected);
                  },
                  backgroundColor: Colors.red.shade50,
                  selectedColor: Colors.red.shade100,
                  checkmarkColor: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribersList(BuildContext context, ThemeData theme, SubscribersState state) {
    if (state.isLoading && state.subscribers.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null && state.subscribers.isEmpty) {
      return _buildErrorState(context, theme, state.error!);
    }

    final filteredSubscribers = state.filteredSubscribers;

    if (filteredSubscribers.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(subscribersProvider.notifier).loadSubscribers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSubscribers.length,
        itemBuilder: (context, index) {
          return SubscriberCard(
            subscriber: filteredSubscribers[index],
            onTap: () => _showDetailBottomSheet(context, filteredSubscribers[index]),
            onExtend: (userId) => _showExtendDialog(context, userId),
            onDelete: (userId) => _showDeleteDialog(context, userId),
          );
        },
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, AdminSubscriber subscriber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Detail ${subscriber.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailUserInfo(subscriber),
                    const SizedBox(height: 20),
                    _buildDetailSubscription(subscriber),
                    const SizedBox(height: 20),
                    _buildDetailStats(subscriber),
                    const SizedBox(height: 20),
                    _buildManagementActions(context, subscriber),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailUserInfo(AdminSubscriber subscriber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red.shade100,
            child: Text(
              _getInitials(subscriber.name),
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscriber.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subscriber.email,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (subscriber.businessName != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subscriber.businessName!,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSubscription(AdminSubscriber subscriber) {
    if (subscriber.currentSubscription == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Tidak Ada Subscription Aktif'),
        ),
      );
    }

    final subscription = subscriber.currentSubscription!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPackageColor(subscription.package.name).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPackageColor(subscription.package.name).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Subscription Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getPackageColor(subscription.package.name),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(subscription.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  subscription.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subscription.package.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            CurrencyFormat.convertToIdr(subscription.package.price, 0),
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Berakhir', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      _formatDate(subscription.endDate),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sisa Hari', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${subscriber.daysLeft} hari',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: subscriber.daysLeft <= 7 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStats(AdminSubscriber subscriber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Pengguna',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('Toko', subscriber.totalStores.toString(), Colors.blue)),
              Expanded(child: _buildStatItem('Member', subscriber.totalMembers.toString(), Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatItem('Produk', subscriber.totalProducts.toString(), Colors.orange)),
              Expanded(child: _buildStatItem('Pembayaran', subscriber.successfulPayments.toString(), Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementActions(BuildContext context, AdminSubscriber subscriber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kelola Pengguna',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showExtendDialog(context, subscriber.id);
            },
            icon: const Icon(CupertinoIcons.time, size: 18),
            label: const Text('Perpanjang Subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showChangePackageDialog(context, subscriber);
            },
            icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 18),
            label: const Text('Ganti Paket Subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showManageMembersDialog(context, subscriber);
            },
            icon: const Icon(CupertinoIcons.person_2, size: 18),
            label: const Text('Kelola Member Toko'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteDialog(context, subscriber.id);
            },
            icon: const Icon(CupertinoIcons.trash, size: 18),
            label: const Text('Hapus Pengguna'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat pengguna...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(subscribersProvider.notifier).loadSubscribers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_3,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Pengguna',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada pengguna yang terdaftar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePackageDialog(BuildContext context, AdminSubscriber subscriber) async {
    final availablePackages = [
      {'name': 'STANDARD', 'displayName': 'Paket Standard', 'price': 75000},
      {'name': 'PRO', 'displayName': 'Paket Pro', 'price': 150000},
      {'name': 'BUSINESS', 'displayName': 'Paket Bisnis', 'price': 250000},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Paket Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih paket baru untuk ${subscriber.name}:'),
            const SizedBox(height: 16),
            ...availablePackages.map((package) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _getPackageColor(package['name']! as String).withValues(alpha: 0.2),
                child: Icon(
                  CupertinoIcons.cube_box,
                  color: _getPackageColor(package['name']! as String),
                  size: 20,
                ),
              ),
              title: Text(package['displayName']! as String),
              subtitle: Text(CurrencyFormat.convertToIdr((package['price']! as int).toDouble(), 0)),
              trailing: subscriber.currentSubscription?.package.name == package['name']
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aktif',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const Icon(CupertinoIcons.chevron_right),
              onTap: subscriber.currentSubscription?.package.name != package['name']
                  ? () async {
                      Navigator.pop(context);
                      await _changeSubscription(subscriber.id, package['name']! as String);
                    }
                  : null,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManageMembersDialog(BuildContext context, AdminSubscriber subscriber) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kelola Member Toko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pengguna ${subscriber.name} memiliki:'),
            const SizedBox(height: 12),
            Text('• ${subscriber.totalStores} Toko'),
            Text('• ${subscriber.totalMembers} Member'),
            Text('• ${subscriber.totalProducts} Produk'),
            const SizedBox(height: 16),
            const Text('Gunakan API removeStoreMember untuk menghapus member dari toko.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeStoreMember('demo-member-id');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kelola Member'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExtendDialog(BuildContext context, String userId) async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perpanjang Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan jumlah hari untuk memperpanjang subscription:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Hari',
                hintText: 'Contoh: 30',
                prefixIcon: const Icon(CupertinoIcons.calendar),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final days = int.tryParse(controller.text);
              if (days != null && days > 0) {
                Navigator.pop(context);
                final success = await ref.read(subscribersProvider.notifier)
                    .extendUserSubscription(userId, days);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription berhasil diperpanjang'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final error = ref.read(subscribersProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Gagal memperpanjang subscription'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Perpanjang'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: const Text('Apakah Anda yakin ingin menghapus pengguna ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await ref.read(subscribersProvider.notifier).deleteUser(userId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengguna berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(subscribersProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal menghapus pengguna'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeSubscription(String userId, String packageName) async {
    try {
      final result = await ref
          .read(adminServicesProvider)
          .changeUserSubscription(userId, packageName);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paket subscription berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
        await ref.read(subscribersProvider.notifier).loadSubscribers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengubah paket'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeStoreMember(String memberId) async {
    try {
      final result = await ref
          .read(adminServicesProvider)
          .removeStoreMember(memberId);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member berhasil dihapus dari toko'),
            backgroundColor: Colors.green,
          ),
        );
        await ref.read(subscribersProvider.notifier).loadSubscribers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menghapus member'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
    } else {
      return words.first.length >= 2 
          ? words.first.substring(0, 2).toUpperCase()
          : words.first[0].toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'trial':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPackageColor(String packageName) {
    switch (packageName.toUpperCase()) {
      case 'STANDARD':
        return Colors.blue;
      case 'PRO':
        return Colors.orange;
      case 'BUSINESS':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SubscriberCard extends StatelessWidget {
  final AdminSubscriber subscriber;
  final VoidCallback onTap;
  final Function(String) onExtend;
  final Function(String) onDelete;

  const SubscriberCard({
    Key? key,
    required this.subscriber,
    required this.onTap,
    required this.onExtend,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        radius: 22,
                        child: Text(
                          _getInitials(subscriber.name),
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (subscriber.isExpiringSoon)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscriber.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subscriber.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subscriber.businessName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subscriber.businessName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => onExtend(subscriber.id),
                        icon: Icon(
                          CupertinoIcons.time,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        tooltip: 'Perpanjang',
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      IconButton(
                        onPressed: () => onDelete(subscriber.id),
                        icon: Icon(
                          CupertinoIcons.trash,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        tooltip: 'Hapus',
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              if (subscriber.currentSubscription != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPackageColor(subscriber.currentSubscription!.package.name).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPackageColor(subscriber.currentSubscription!.package.name).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_seal,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subscriber.currentSubscription!.package.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(subscriber.currentSubscription!.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subscriber.currentSubscription!.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Berakhir: ${_formatDate(subscriber.currentSubscription!.endDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Sisa: ${subscriber.daysLeft} hari',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subscriber.daysLeft <= 7 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              Row(
                children: [
                  _buildStatItem(
                    CupertinoIcons.building_2_fill,
                    subscriber.totalStores.toString(),
                    'Toko',
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    CupertinoIcons.person_3_fill,
                    subscriber.totalMembers.toString(),
                    'Member',
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    CupertinoIcons.cube_box_fill,
                    subscriber.totalProducts.toString(),
                    'Produk',
                    Colors.orange,
                  ),
                  // ✅ CLEAN - DIHAPUS SELURUH "TAP DETAIL" CONTAINER
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
    } else {
      return words.first.length >= 2 
          ? words.first.substring(0, 2).toUpperCase()
          : words.first[0].toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'trial':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPackageColor(String packageName) {
    switch (packageName.toUpperCase()) {
      case 'STANDARD':
        return Colors.blue;
      case 'PRO':
        return Colors.orange;
      case 'BUSINESS':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}