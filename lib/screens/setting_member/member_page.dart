import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/providers/member_provider.dart';
import 'package:kasir/screens/setting_member/widgets/invitation_list_tab.dart';
import 'package:kasir/screens/setting_member/widgets/invite_member_sheet.dart';
import 'package:kasir/screens/setting_member/widgets/member_list_tab.dart';

class MemberPage extends ConsumerWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const NavDrawer(currentRoute: 'member'),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Pengaturan Anggota",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Anggota (${memberState.members.length})'),
              Tab(text: 'Undangan (${memberState.invitations.length})'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MemberListTab(),
            InvitationListTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const InviteMemberSheet(),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}