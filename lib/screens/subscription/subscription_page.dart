import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/subscription_model.dart';
import 'package:kasir/providers/subscription_providers.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadAll();
    });
  }

  void _showPaymentDialog(BuildContext context, SubscriptionPackage package) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                CupertinoIcons.creditcard,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Konfirmasi Pembayaran'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paket: ${package.displayName}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Harga: ${CurrencyFormat.convertToIdr(package.price, 0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment gateway akan segera tersedia.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Lanjutkan'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment gateway akan segera tersedia'),
                    backgroundColor: theme.colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Pilih Paket Langganan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: subscriptionState.isLoading
          ? _buildLoadingState(theme)
          : subscriptionState.error != null
              ? _buildErrorState(context, theme, subscriptionState.error!)
              : _buildContent(context, theme, subscriptionState),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat paket langganan...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
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
                ref.read(subscriptionProvider.notifier).loadAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ThemeData theme, SubscriptionState state) {
    final hasActiveSubscription = state.hasActiveSubscription;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(subscriptionProvider.notifier).loadAll();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Subscription Info
            if (hasActiveSubscription && state.currentSubscription != null) ...[
              _buildCurrentSubscriptionCard(
                  context, theme, state.currentSubscription!),
              const SizedBox(height: 24),
            ],

            // Package List Header
            Text(
              hasActiveSubscription ? 'Upgrade Paket' : 'Pilih Paket Langganan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih paket yang sesuai dengan kebutuhan bisnis Anda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Package Cards
            if (state.packages.isEmpty)
              _buildEmptyState(theme)
            else
              ...state.packages.map((package) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPackageCard(
                      context,
                      theme,
                      package,
                      isCurrentPackage:
                          state.currentSubscription?.packageId == package.id,
                    ),
                  )),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(
      BuildContext context, ThemeData theme, UserSubscription subscription) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Langganan Aktif',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subscription.package.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Berakhir: ${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: subscription.isExpiring
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: subscription.isExpiring
                        ? Colors.orange.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  subscription.isExpiring ? 'Segera Berakhir' : 'Aktif',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color:
                        subscription.isExpiring ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCleanDisplayName(String displayName) {
    return displayName.replaceAllMapped(
      RegExp(r'\(Hemat (\d+\.?\d*)\%\)'),
      (match) {
        final percentStr = match.group(1);
        if (percentStr != null) {
          final percent = double.tryParse(percentStr) ?? 0;
          final roundedPercent = percent.round();
          return '(Hemat ${roundedPercent}%)';
        }
        return match.group(0) ?? '';
      },
    );
  }

  Widget _buildPackageCard(
      BuildContext context, ThemeData theme, SubscriptionPackage package,
      {bool isCurrentPackage = false}) {
    final isPro = package.name.toLowerCase() == 'pro';
    final isBusiness = package.name.toLowerCase() == 'business';

    Color primaryColor = theme.colorScheme.primary;
    if (isPro) {
      primaryColor = Colors.purple;
    } else if (isBusiness) {
      primaryColor = Colors.orange;
    }

    return GestureDetector(
      onTap:
          isCurrentPackage ? null : () => _showPaymentDialog(context, package),
      child: Container(
        decoration: BoxDecoration(
          gradient: isCurrentPackage
              ? LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.05),
                    primaryColor.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPackage
                ? primaryColor
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isCurrentPackage ? 2 : 1,
          ),
        ),
        child: ModernCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getCleanDisplayName(package.displayName),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        if (isPro) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'POPULER',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isCurrentPackage)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormat.convertToIdr(package.price, 0),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/${package.duration} bulan',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Features
              Text(
                'Fitur yang Anda Dapatkan:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                theme,
                CupertinoIcons.person_2_fill,
                '${package.maxMembers} Member Tim',
                true,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                theme,
                CupertinoIcons.building_2_fill,
                '${package.maxStores} Toko',
                true,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                theme,
                CupertinoIcons.cube_box_fill,
                'Manajemen Stok Tak Terbatas',
                true,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                theme,
                CupertinoIcons.chart_bar_fill,
                'Laporan Penjualan',
                true,
              ),

              // Additional Features based on package
              if (isPro || isBusiness) ...[
                const SizedBox(height: 8),
                _buildFeatureItem(
                  theme,
                  CupertinoIcons.cloud_fill,
                  'Backup Cloud Otomatis',
                  true,
                ),
              ],
              if (isBusiness) ...[
                const SizedBox(height: 8),
                _buildFeatureItem(
                  theme,
                  CupertinoIcons.phone_fill,
                  'Support Priority 24/7',
                  true,
                ),
              ],

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCurrentPackage
                      ? null
                      : () => _showPaymentDialog(context, package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentPackage
                        ? theme.colorScheme.surfaceVariant
                        : primaryColor,
                    foregroundColor: isCurrentPackage
                        ? theme.colorScheme.onSurfaceVariant
                        : Colors.white,
                    disabledBackgroundColor: theme.colorScheme.surfaceVariant,
                    disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isCurrentPackage ? 0 : 2,
                  ),
                  child: Text(
                    isCurrentPackage ? 'Paket Aktif' : 'Pilih Paket',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCurrentPackage
                          ? theme.colorScheme.onSurfaceVariant
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String text,
    bool included,
  ) {
    return Row(
      children: [
        Icon(
          included
              ? CupertinoIcons.checkmark_circle_fill
              : CupertinoIcons.xmark_circle_fill,
          size: 20,
          color: included ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: included
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              decoration: included ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.square_stack,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Paket',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paket langganan belum tersedia saat ini',
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
}
