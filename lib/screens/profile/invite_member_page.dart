import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/services/user_services.dart';

class InviteMemberPage extends ConsumerStatefulWidget {
  const InviteMemberPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends ConsumerState<InviteMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedRole = 'CASHIER';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? storeId;
  List<dynamic> _members = [];
  UserServices userServices = UserServices();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final store = await Store.getStore();
      if (store != null && store['id'] != null) {
        setState(() => storeId = store['id']);
        await _loadMembers();
      }
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Fetch members
  Future<void> _loadMembers() async {
    var resp = await userServices.getUsers();
    if (resp['success']) {
      setState(() {
        _members = resp['data'];
      });
    }
  }
  
  // Invite new member
  Future<void> _inviteMember() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      final response = await userServices.createMember({
        "storeId": storeId,
        "invitedName": _nameController.text,
        "invitedEmail": _emailController.text,
        "role": _selectedRole,
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Undangan berhasil dikirim'), backgroundColor: Colors.green),
        );

        _nameController.clear();
        _emailController.clear();
        _loadMembers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim undangan'), backgroundColor: Colors.red),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim undangan'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
  
  Future<void> _deleteMember(int id) async {
    try {
      var resp = await userServices.deleteMember(id);
      if (resp['success']) {
        _loadMembers();
      }
    } catch (e) {
      // Handle deletion error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Undang Anggota')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Undang Anggota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invite form card
            ModernCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Undang Anggota Baru',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(CupertinoIcons.person),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(CupertinoIcons.mail),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Peran',
                        prefixIcon: const Icon(CupertinoIcons.person_badge_plus),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CASHIER',
                          child: Text('Kasir'),
                        ),
                        DropdownMenuItem(
                          value: 'MANAGER',
                          child: Text('Manajer'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                    const SizedBox(height: 24),
                    ModernButton(
                      text: 'Kirim Undangan',
                      onPressed: _inviteMember,
                      isLoading: _isSubmitting,
                      icon: const Icon(CupertinoIcons.envelope),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Members list
            Text(
              'Anggota Terdaftar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _members.isEmpty
                ? ModernCard(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.person_3_fill,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada anggota',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Undang anggota untuk membantu mengelola toko Anda',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return ModernCard(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              member['name'][0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(member['name']),
                          subtitle: Text(member['email']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              // Show confirmation dialog and remove member
                              _deleteMember(member['id']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}