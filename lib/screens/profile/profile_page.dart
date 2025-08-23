import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/screens/profile/business_profile_page.dart';
import 'package:kasir/screens/subscription/subscription_page.dart';
import 'package:kasir/screens/profile/invite_member_page.dart';
import 'package:kasir/core/use_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic _user = {};
  bool _isLoading = true;
  bool _isMember = false;

  Future<void> getUserStore() async {
    setState(() => _isLoading = true);
    try {
      final user = await Store.getUser();
      setState(() {
        _user = user ?? {};
        _isMember = user?['is_member'] == true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    getUserStore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavDrawer(currentRoute: 'profile'),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Profil",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // User profile header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  color: theme.colorScheme.surface,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            _getInitials(_user['name'] ?? ''),
                            style: const TextStyle(color: Colors.white, fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_user['name'] ?? 'User'}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${_user['email'] ?? ''}",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Business Profile Menu
                _buildMenuItem(
                  context: context,
                  icon: CupertinoIcons.building_2_fill,
                  title: 'Profil usaha',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BusinessProfilePage()),
                  ),
                ),
                
                const SizedBox(height: 3),
                
                // Subscription Menu
                _buildMenuItem(
                  context: context,
                  icon: CupertinoIcons.creditcard,
                  title: 'Langganan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                  ),
                ),
                
                const SizedBox(height: 3),
                
                // Invite Member Menu (Hide for members)
                if (!_isMember)
                  _buildMenuItem(
                    context: context,
                    icon: CupertinoIcons.person_add,
                    title: 'Undang Anggota',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InviteMemberPage()),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0].toUpperCase()}${nameParts.last[0].toUpperCase()}';
    } else {
      return nameParts.first.isNotEmpty 
          ? nameParts.first[0].toUpperCase() 
          : 'U';
    }
  }
}