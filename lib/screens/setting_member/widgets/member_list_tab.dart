import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/providers/member_provider.dart';

class MemberListTab extends ConsumerWidget {
  const MemberListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberProvider);

    if (memberState.isLoading && memberState.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (memberState.members.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Belum ada anggota di toko ini.\nKlik tombol '+' untuk mengundang anggota baru.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(memberProvider.notifier).loadData(),
      child: ListView.separated(
        itemCount: memberState.members.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final member = memberState.members[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(member.user.name.isNotEmpty ? member.user.name[0].toUpperCase() : '?'),
            ),
            title: Text(member.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(member.user.email),
            trailing: IconButton(
              icon: const Icon(CupertinoIcons.trash, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluarkan Anggota'),
                    content: Text(
                        'Anda yakin ingin mengeluarkan ${member.user.name} dari toko?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Ya, Keluarkan', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm ?? false) {
                  await ref.read(memberProvider.notifier).removeMember(member.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}