import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/admin_models.dart';
import 'package:kasir/providers/admin_providers.dart';

class SubscriberDetailPage extends ConsumerStatefulWidget {
  final AdminSubscriber subscriber;

  const SubscriberDetailPage({
    Key? key,
    required this.subscriber,
  }) : super(key: key);

  @override
  ConsumerState<SubscriberDetailPage> createState() => _SubscriberDetailPageState();
}

class _SubscriberDetailPageState extends ConsumerState<SubscriberDetailPage> {
  bool _isLoading = false;

  // Package options sesuai backend
  final List<Map<String, dynamic>> _availablePackages = [
    {
      'id': 'STANDARD',
      'name': 'STANDARD',
      'displayName': 'Paket Standard',
      'price': 75000,
      'maxMembers': 3,
      'maxStores': 1,
      'features': ['Invoice', 'Reports']
    },
    {
      'id': 'PRO', 
      'name': 'PRO',
      'displayName': 'Paket Pro',
      'price': 150000,
      'maxMembers': 5,
      'maxStores': 3,
      'features': ['Invoice', 'Reports', 'Backup', 'Analytics']
    },
    {
      'id': 'BUSINESS',
      'name': 'BUSINESS', 
      'displayName': 'Paket Bisnis',
      'price': 250000,
      'maxMembers': 7,
      'maxStores': 5,
      'features': ['Invoice', 'Reports', 'Backup', 'API Access', 'Analytics', 'Priority Support']
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detail ${widget.subscriber.name}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(context, theme),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memproses...'),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(theme),
          const SizedBox(height: 16),
          _buildSubscriptionCard(theme),
          const SizedBox(height: 16),
          if (widget.subscriber.totalStores > 0)
            _buildStoreManagementCard(theme),
          const SizedBox(height: 16),
          _buildStatsCard(theme),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  _getInitials(widget.subscriber.name),
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
                      widget.subscriber.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.subscriber.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.subscriber.businessName != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.subscriber.businessName!,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                widget.subscriber.isActive ? CupertinoIcons.checkmark_circle : CupertinoIcons.xmark_circle,
                color: widget.subscriber.isActive ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.subscriber.isActive ? 'Pengguna Aktif' : 'Pengguna Tidak Aktif',
                style: TextStyle(
                  color: widget.subscriber.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.calendar, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'Informasi Subscription',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.subscriber.currentSubscription != null) ...[
            _buildSubscriptionInfo(theme),
            const SizedBox(height: 16),
            _buildSubscriptionActions(),
          ] else
            _buildNoSubscriptionInfo(theme),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfo(ThemeData theme) {
    final subscription = widget.subscriber.currentSubscription!;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paket',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    subscription.package.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
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
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harga Paket',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    CurrencyFormat.convertToIdr(subscription.package.price, 0),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sisa Hari',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${widget.subscriber.daysLeft} hari',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: widget.subscriber.daysLeft <= 7 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Limit Paket',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(CupertinoIcons.building_2_fill, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Text('Max Toko: ${subscription.package.maxStores}'),
                  const SizedBox(width: 16),
                  Icon(CupertinoIcons.person_3_fill, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text('Max Member: ${subscription.package.maxMembers}'),
                ],
              ),
            ],
          ),
        ),
        if (widget.subscriber.isExpiringSoon) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.alarm, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Subscription akan berakhir dalam ${widget.subscriber.daysLeft} hari',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoSubscriptionInfo(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.xmark_circle, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            'Tidak Ada Subscription Aktif',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showExtendDialog(),
                icon: const Icon(CupertinoIcons.time, size: 18),
                label: const Text('Perpanjang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showChangePackageDialog(),
                icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 18),
                label: const Text('Ganti Paket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreManagementCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.building_2_fill, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'Manajemen Toko (${widget.subscriber.totalStores})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.info_circle, color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Informasi Toko & Member',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('Total Toko: ${widget.subscriber.totalStores}'),
                    ),
                    Expanded(
                      child: Text('Total Member: ${widget.subscriber.totalMembers}'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Total Produk: ${widget.subscriber.totalProducts}'),
                    ),
                    Expanded(
                      child: Text('Pembayaran: ${widget.subscriber.successfulPayments}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.chart_bar_alt_fill, color: Colors.purple.shade600),
              const SizedBox(width: 8),
              Text(
                'Statistik Pengguna',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Toko',
                  widget.subscriber.totalStores.toString(),
                  CupertinoIcons.building_2_fill,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Member',
                  widget.subscriber.totalMembers.toString(),
                  CupertinoIcons.person_3_fill,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Produk',
                  widget.subscriber.totalProducts.toString(),
                  CupertinoIcons.cube_box_fill,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pembayaran Sukses',
                  widget.subscriber.successfulPayments.toString(),
                  CupertinoIcons.money_dollar_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
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
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dialog Functions
  Future<void> _showExtendDialog() async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perpanjang Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Perpanjang subscription untuk ${widget.subscriber.name}:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Hari',
                prefixIcon: const Icon(CupertinoIcons.calendar),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                await _extendSubscription(days);
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

  Future<void> _showChangePackageDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Paket Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih paket baru untuk ${widget.subscriber.name}:'),
            const SizedBox(height: 16),
            ..._availablePackages.map((package) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPackageColor(package['name']).withOpacity(0.2),
                  child: Icon(
                    CupertinoIcons.cube_box,
                    color: _getPackageColor(package['name']),
                    size: 20,
                  ),
                ),
                title: Text(
                  package['displayName'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CurrencyFormat.convertToIdr(package['price'], 0)),
                    Text(
                      '${package['maxStores']} Toko • ${package['maxMembers']} Member',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: widget.subscriber.currentSubscription?.package.name == package['name']
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
                onTap: widget.subscriber.currentSubscription?.package.name != package['name']
                    ? () async {
                        Navigator.pop(context);
                        await _changeSubscription(package['name']);
                      }
                    : null,
              ),
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

  // API Functions
  Future<void> _extendSubscription(int days) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(subscribersProvider.notifier)
          .extendUserSubscription(widget.subscriber.id, days);

      if (success) {
        _showSuccessSnackBar('Subscription berhasil diperpanjang $days hari');
        await ref.read(subscribersProvider.notifier).loadSubscribers();
        Navigator.pop(context);
      } else {
        final error = ref.read(subscribersProvider).error;
        _showErrorSnackBar(error ?? 'Gagal memperpanjang subscription');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeSubscription(String packageName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref
          .read(adminServicesProvider)
          .changeUserSubscription(widget.subscriber.id, packageName);

      if (result['success'] == true) {
        _showSuccessSnackBar('Paket subscription berhasil diubah');
        await ref.read(subscribersProvider.notifier).loadSubscribers();
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Gagal mengubah paket');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper Functions
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
    switch (packageName) {
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