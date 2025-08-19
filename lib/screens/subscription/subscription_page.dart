import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/subscription_model.dart';
import 'package:kasir/providers/subscription_providers.dart';
import 'package:lottie/lottie.dart';

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

  void _showPaymentDialog(BuildContext context, SubscriptionPackage package, bool isNewUser) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isNewUser) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.gift,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Promo: Bayar 1 bulan, dapat 3 bulan!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Payment gateway akan segera tersedia.',
                style: TextStyle(
                  fontSize: 12,
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
                  const SnackBar(
                    content: Text('Payment gateway dalam pengembangan'),
                    backgroundColor: Colors.orange,
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
          ? _buildLoadingState()
          : subscriptionState.error != null
              ? _buildErrorState(context, theme, subscriptionState.error!)
              : _buildContent(context, theme, subscriptionState),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Loading.json',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text('Memuat paket langganan...'),
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
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, SubscriptionState state) {
    final hasActiveSubscription = state.hasActiveSubscription;
    final isNewUser = state.currentSubscription == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Subscription Info
          if (hasActiveSubscription && state.currentSubscription != null) ...[
            _buildCurrentSubscriptionCard(context, theme, state.currentSubscription!),
            const SizedBox(height: 24),
          ],

          // New User Promo Banner
          if (isNewUser) ...[
            _buildPromoBanner(context, theme),
            const SizedBox(height: 24),
          ],

          // Package List
          Text(
            hasActiveSubscription ? 'Upgrade Paket' : 'Pilih Paket',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...state.packages.map((package) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPackageCard(
              context,
              theme,
              package,
              isCurrentPackage: state.currentSubscription?.packageId == package.id,
              isNewUser: isNewUser,
            ),
          )),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context, ThemeData theme, UserSubscription subscription) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Langganan Aktif',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            subscription.package.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
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
              const SizedBox(width: 4),
              Text(
                'Berakhir: ${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: subscription.isExpiring
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subscription.isExpiring
                      ? '${subscription.daysLeft} hari lagi'
                      : 'Aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: subscription.isExpiring ? Colors.orange : Colors.green,
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

  Widget _buildPromoBanner(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.gift,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo Pengguna Baru!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bayar 1 bulan, dapat akses 3 bulan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    ThemeData theme,
    SubscriptionPackage package,
    {bool isCurrentPackage = false, bool isNewUser = false}
  ) {
    final isBasic = package.name.toLowerCase() == 'basic';
    final isPremium = package.name.toLowerCase() == 'premium';
    final isEnterprise = package.name.toLowerCase() == 'enterprise';

    return GestureDetector(
      onTap: isCurrentPackage
          ? null
          : () => _showPaymentDialog(context, package, isNewUser),
      child: Container(
        decoration: BoxDecoration(
          gradient: isCurrentPackage
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPackage
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isCurrentPackage ? 2 : 1,
          ),
        ),
        child: ModernCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.displayName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULER',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBasic
                            ? 'Untuk usaha kecil'
                            : isPremium
                                ? 'Untuk usaha berkembang'
                                : 'Untuk perusahaan besar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (isCurrentPackage)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: theme.colorScheme.primary,
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
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '/bulan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // New User Promo
              if (isNewUser) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.gift,
                        size: 16,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Bayar 1 bulan, dapat 3 bulan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Features
              Text(
                'Fitur Utama:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildFeatureItem(
                theme,
                CupertinoIcons.building_2_fill,
                '${package.maxStores} Toko',
                true,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                theme,
                CupertinoIcons.person_3_fill,
                '${package.maxMembers} Member',
                true,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                theme,
                CupertinoIcons.person_2_fill,
                '${package.maxUsers} User',
                true,
              ),

              // Additional Features based on package
              if (isPremium || isEnterprise) ...[
                const SizedBox(height: 8),
                _buildFeatureItem(
                  theme,
                  CupertinoIcons.chart_bar_fill,
                  'Laporan Lanjutan',
                  true,
                ),
              ],
              if (isEnterprise) ...[
                const SizedBox(height: 8),
                _buildFeatureItem(
                  theme,
                  CupertinoIcons.shield_fill,
                  'Priority Support',
                  true,
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(
                  theme,
                  CupertinoIcons.cloud_fill,
                  'Backup Otomatis',
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
                      : () => _showPaymentDialog(context, package, isNewUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentPackage
                        ? theme.colorScheme.surfaceVariant
                        : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCurrentPackage ? 'Paket Aktif' : 'Pilih Paket',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
          included ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
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
}