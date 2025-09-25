import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kasir/providers/member_provider.dart';

class InvitationListTab extends ConsumerWidget {
  const InvitationListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberProvider);

    if (memberState.isLoading && memberState.invitations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (memberState.invitations.isEmpty) {
      return const Center(child: Text("Tidak ada undangan yang terkirim."));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(memberProvider.notifier).loadData(),
      child: ListView.separated(
        itemCount: memberState.invitations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final invite = memberState.invitations[index];
          return ListTile(
            leading: const Icon(CupertinoIcons.mail_solid),
            title: Text(invite.invitedName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(invite.invitedEmail),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(invite.status,
                    style: TextStyle(color: _getStatusColor(invite.status), fontWeight: FontWeight.bold)),
                Text('Kadaluarsa: ${DateFormat.yMd().format(invite.expiresAt)}'),
                if (invite.status == 'PENDING')
                  SizedBox(
                    height: 24,
                    child: TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Batalkan', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        await ref.read(memberProvider.notifier).revokeInvitation(invite.id);
                      },
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return Colors.orange;
      case 'ACCEPTED': return Colors.green;
      case 'REVOKED': return Colors.red;
      default: return Colors.grey;
    }
  }
}