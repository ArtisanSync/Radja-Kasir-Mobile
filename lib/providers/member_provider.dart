import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/models/member_model.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:kasir/services/invite_services.dart';

class MemberState {
  final List<MemberModel> members;
  final List<InvitationModel> invitations;
  final bool isLoading;
  final String? error;

  const MemberState({
    this.members = const [],
    this.invitations = const [],
    this.isLoading = false,
    this.error,
  });

  MemberState copyWith({
    List<MemberModel>? members,
    List<InvitationModel>? invitations,
    bool? isLoading,
    String? error,
  }) {
    return MemberState(
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class MemberNotifier extends StateNotifier<MemberState> {
  // [PERBAIKAN] Ganti MemberService menjadi InviteServices
  final InviteServices _inviteService;
  final String? _storeId;

  MemberNotifier(this._inviteService, this._storeId) : super(const MemberState()) {
    if (_storeId != null) {
      loadData();
    }
  }

  Future<void> loadData() async {
    if (_storeId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // [PERBAIKAN] Panggil fungsi dari _inviteService
      final memberRes = await _inviteService.getStoreMembers(_storeId!);
      final inviteRes = await _inviteService.getStoreInvitations(_storeId!);

      if (memberRes['success'] == true && inviteRes['success'] == true) {
        final members = (memberRes['data'] as List).map((e) => MemberModel.fromJson(e)).toList();
        final invitations = (inviteRes['data'] as List).map((e) => InvitationModel.fromJson(e)).toList();
        state = state.copyWith(members: members, invitations: invitations, isLoading: false);
      } else {
        state = state.copyWith(error: memberRes['message'] ?? inviteRes['message'], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<bool> inviteMember({required String name, required String email}) async {
    if (_storeId == null) return false;
    state = state.copyWith(isLoading: true);
    final result = await _inviteService.inviteMember(storeId: _storeId!, name: name, email: email);
    if (result['success'] == true) {
      await loadData();
      return true;
    } else {
      state = state.copyWith(error: result['message'], isLoading: false);
      return false;
    }
  }

  Future<bool> removeMember(String memberId) async {
    if (_storeId == null) return false;
    final result = await _inviteService.removeMember(storeId: _storeId!, memberId: memberId);
    if (result['success'] == true) {
      await loadData();
      return true;
    } else {
      state = state.copyWith(error: result['message']);
      return false;
    }
  }

  Future<bool> revokeInvitation(String inviteId) async {
    final result = await _inviteService.revokeInvitation(inviteId);
    if (result['success'] == true) {
      await loadData();
      return true;
    } else {
      state = state.copyWith(error: result['message']);
      return false;
    }
  }
}

final inviteServiceProvider = Provider((ref) => InviteServices());

final memberProvider = StateNotifierProvider.autoDispose<MemberNotifier, MemberState>((ref) {
  final storeId = ref.watch(storeProvider.select((s) => s.currentStore?.id));
  final service = ref.watch(inviteServiceProvider);
  return MemberNotifier(service, storeId);
});