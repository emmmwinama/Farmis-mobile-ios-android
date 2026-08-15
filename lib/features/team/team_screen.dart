import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/team_member.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import '../../shared/widgets/farmio_summary_bar.dart';
import 'team_provider.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Team',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(teamProvider),
          ),
        ],
      ),
      floatingActionButton: team.maybeWhen(
        data: (data) => FloatingActionButton.extended(
          onPressed: () => _showInviteForm(context, ref, data.roles),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Invite'),
        ),
        orElse: () => null,
      ),
      body: team.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(teamProvider),
        ),
        data: (data) {
          if (data.members.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No team members yet. Invite someone to share access to this farm.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: FarmioColors.textMuted),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(teamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: data.members.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TeamSummary(members: data.members),
                  );
                }
                return _MemberCard(member: data.members[index - 1]);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showInviteForm(
    BuildContext context,
    WidgetRef ref,
    List<String> roles,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteForm(ref: ref, roles: roles),
    );
  }
}

class _TeamSummary extends StatelessWidget {
  final List<TeamMember> members;
  const _TeamSummary({required this.members});

  @override
  Widget build(BuildContext context) {
    final active = members.where((m) => m.status == 'active').length;
    final invited = members.where((m) => m.status == 'invited').length;
    final roles = {...members.map((m) => m.role)}.length;

    return FarmioSummaryBar(
      stats: [
        FarmioSummaryStat(label: 'Members', value: '${members.length}'),
        FarmioSummaryStat(
            label: 'Active', value: '$active', color: Colors.greenAccent),
        FarmioSummaryStat(
          label: 'Invited',
          value: '$invited',
          color: invited > 0 ? Colors.orangeAccent : null,
        ),
        FarmioSummaryStat(label: 'Roles', value: '$roles'),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TeamMember member;
  const _MemberCard({required this.member});

  Color get _statusColor {
    switch (member.status) {
      case 'active':
        return FarmioColors.success;
      case 'invited':
        return FarmioColors.warning;
      default:
        return FarmioColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = member.user?.name.isNotEmpty == true
        ? member.user!.name
        : member.inviteEmail ?? 'Pending invite';
    final email = member.user?.email ?? member.inviteEmail ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FarmioColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: FarmioColors.infoBg,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(
                color: FarmioColors.info,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: FarmioColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    )),
                Text(email,
                    style: const TextStyle(
                        fontSize: 12, color: FarmioColors.textMuted)),
                const SizedBox(height: 6),
                Text(member.role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: FarmioColors.primary,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(member.status,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                )),
          ),
        ],
      ),
    );
  }
}

class _InviteForm extends StatefulWidget {
  final WidgetRef ref;
  final List<String> roles;
  const _InviteForm({required this.ref, required this.roles});

  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  final _emailCtrl = TextEditingController();
  String? _role;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _role = widget.roles.isNotEmpty ? widget.roles.first : null;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Email is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.ref.read(teamRepositoryProvider).inviteMember(
            email: _emailCtrl.text.trim(),
            role: _role,
          );
      widget.ref.invalidate(teamProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      final data = e.response?.data;
      setState(() => _error = data is Map<String, dynamic>
          ? data['error'] as String? ?? 'Could not send invite.'
          : 'Could not send invite.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Invite team member',
                style: TextStyle(
                  color: FarmioColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: widget.roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                FarmioErrorBanner(message: _error!),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _invite,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send invite'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load team',
                style: TextStyle(
                    color: FarmioColors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: FarmioColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
