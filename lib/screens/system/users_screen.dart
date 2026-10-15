import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../generated/pi_control.pb.dart';
import '../../services/admin_service.dart';
import '../../ui/ui.dart';
import '../../widgets/command_result.dart';

final _usersProvider = FutureProvider.autoDispose<UserList>(
  (ref) => ref.watch(adminServiceProvider).listUsers(),
);

/// Groups a new user is often added to on a Raspberry Pi
const _commonGroups = ['video', 'audio', 'gpio', 'i2c', 'spi', 'dialout', 'plugdev', 'docker'];

Future<bool> _userAction(BuildContext context, WidgetRef ref, UserRequest request, String success) async {
  try {
    final result = await ref.read(adminServiceProvider).user(request);
    ref.invalidate(_usersProvider);
    if (context.mounted) return reportCommand(context, result, success: success);
  } catch (e) {
    if (context.mounted) showToast(context, describeError(e), tone: Tone.danger);
  }
  return false;
}

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  bool _showSystem = false;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(_usersProvider);

    return PageScaffold(
      title: 'Users & groups',
      actions: [
        IconButton(
          tooltip: _showSystem ? 'Hide system accounts' : 'Show system accounts',
          icon: Icon(_showSystem ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _showSystem = !_showSystem),
        ),
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(_usersProvider)),
      ],
      floatingActionButton: list.valueOrNull == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _tab == 0 ? _createUser(list.value!) : _createGroup(),
              icon: Icon(_tab == 0 ? Icons.person_add_alt : Icons.group_add_outlined),
              label: Text(_tab == 0 ? 'New user' : 'New group'),
            ),
      body: AsyncView<UserList>(
        value: list,
        onRetry: () => ref.invalidate(_usersProvider),
        data: (data) {
          final users = data.users.where((u) => _showSystem || !u.isSystem).toList();
          final groups = data.groups.where((g) => _showSystem || !g.isSystem || g.members.isNotEmpty).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          return PageList(
            onRefresh: () async => ref.invalidate(_usersProvider),
            children: [
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 0, icon: const Icon(Icons.person_outline), label: Text('Users · ${users.length}')),
                  ButtonSegment(value: 1, icon: const Icon(Icons.group_outlined), label: Text('Groups · ${groups.length}')),
                ],
                selected: {_tab},
                onSelectionChanged: (v) => setState(() => _tab = v.first),
              ),
              const Gap(Insets.lg),
              if (_tab == 0)
                ResponsiveGrid(
                  minItemWidth: 360,
                  maxColumns: 2,
                  children: [
                    for (final u in users)
                      _UserCard(
                        user: u,
                        isAgentUser: u.name == data.agentUser,
                        onTap: () => _userSheet(u, data),
                      ),
                  ],
                )
              else
                TileGroup(
                  children: [
                    for (final g in groups)
                      ActionTile(
                        icon: Icons.group_outlined,
                        tone: g.isSystem ? Tone.neutral : Tone.primary,
                        title: g.name,
                        subtitle: g.members.isEmpty ? 'GID ${g.gid} · no extra members' : 'GID ${g.gid} · ${g.members.join(', ')}',
                        trailing: g.isSystem
                            ? null
                            : IconButton(
                                tooltip: 'Delete group',
                                icon: Icon(Icons.delete_outline, color: context.cs.error),
                                onPressed: () async {
                                  if (await showConfirmDialog(
                                    context,
                                    title: 'Delete group ${g.name}?',
                                    message: 'Members stay, they just leave the group.',
                                    confirmLabel: 'Delete',
                                    destructive: true,
                                  )) {
                                    if (!context.mounted) return;
                                    await _userAction(
                                      context,
                                      ref,
                                      UserRequest()
                                        ..op = UserOp.GROUP_DELETE
                                        ..group = g.name,
                                      'Group ${g.name} deleted',
                                    );
                                  }
                                },
                              ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createGroup() async {
    final name = await showTextPrompt(
      context,
      title: 'New group',
      label: 'Group name',
      hint: 'media',
      confirmLabel: 'Create',
      validator: (v) => RegExp(r'^[a-z_][a-z0-9_-]{0,31}$').hasMatch(v) ? null : 'Lowercase letters, digits, - and _',
    );
    if (name == null || !mounted) return;
    await _userAction(
      context,
      ref,
      UserRequest()
        ..op = UserOp.GROUP_CREATE
        ..group = name,
      'Group $name created',
    );
  }

  Future<void> _createUser(UserList data) async {
    final request = await Navigator.push<UserRequest>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _NewUserPage(
          groups: data.groups.map((g) => g.name).toSet(),
          shells: data.shells,
          existing: data.users.map((u) => u.name).toSet(),
        ),
      ),
    );
    if (request == null || !mounted) return;
    await _userAction(context, ref, request, 'User ${request.username} created');
  }

  void _userSheet(SystemUser u, UserList data) {
    final protected = u.name == 'root' || u.name == data.agentUser;
    UserRequest req(UserOp op) => UserRequest()
      ..op = op
      ..username = u.name;

    showActionSheet(
      context,
      title: u.name,
      subtitle: [if (u.fullName.isNotEmpty) u.fullName, 'UID ${u.uid}', u.home].join(' · '),
      actions: [
        SheetAction(
          icon: Icons.password,
          label: 'Set password',
          onTap: () async {
            final pw = await showTextPrompt(
              context,
              title: 'New password for ${u.name}',
              label: 'Password',
              obscure: true,
              confirmLabel: 'Set',
              validator: (v) => v.length < 6 ? 'At least 6 characters' : null,
            );
            if (pw == null || !mounted) return;
            await _userAction(context, ref, req(UserOp.USER_SET_PASSWORD)..password = pw, 'Password changed');
          },
        ),
        SheetAction(
          icon: Icons.group_add_outlined,
          label: 'Add to group',
          onTap: () async {
            final candidates = data.groups.map((g) => g.name).where((g) => !u.groups.contains(g)).toList()..sort();
            final g = await showTextPrompt(
              context,
              title: 'Add ${u.name} to a group',
              label: 'Group',
              suggestions: [for (final c in [..._commonGroups, 'sudo']) if (candidates.contains(c)) c],
              confirmLabel: 'Add',
            );
            if (g == null || g.isEmpty || !mounted) return;
            await _userAction(context, ref, req(UserOp.USER_ADD_GROUP)..group = g, '${u.name} added to $g');
          },
        ),
        if (u.groups.length > 1)
          SheetAction(
            icon: Icons.group_remove_outlined,
            label: 'Remove from group',
            onTap: () async {
              final g = await showChoiceSheet<String>(
                context,
                title: 'Remove ${u.name} from',
                value: '',
                choices: [for (final g in u.groups.skip(1)) (g, g)],
              );
              if (g == null || !mounted) return;
              await _userAction(context, ref, req(UserOp.USER_REMOVE_GROUP)..group = g, '${u.name} removed from $g');
            },
          ),
        SheetAction(
          icon: Icons.terminal,
          label: 'Change shell',
          subtitle: u.shell,
          onTap: () async {
            final shell = await showChoiceSheet<String>(
              context,
              title: 'Login shell of ${u.name}',
              value: u.shell,
              choices: [for (final s in {...data.shells, '/usr/sbin/nologin'}) (s, s)],
            );
            if (shell == null || shell == u.shell || !mounted) return;
            await _userAction(context, ref, req(UserOp.USER_SET_SHELL)..shell = shell, 'Shell changed');
          },
        ),
        SheetAction(
          icon: Icons.badge_outlined,
          label: 'Change full name',
          onTap: () async {
            final name = await showTextPrompt(context, title: 'Full name', label: 'Name', initial: u.fullName, confirmLabel: 'Save');
            if (name == null || !mounted) return;
            await _userAction(context, ref, req(UserOp.USER_SET_FULL_NAME)..fullName = name, 'Name changed');
          },
        ),
        if (!protected)
          SheetAction(
            icon: u.locked ? Icons.lock_open : Icons.lock_outline,
            label: u.locked ? 'Unlock account' : 'Lock account',
            subtitle: u.locked ? null : 'Blocks password login',
            tone: Tone.warning,
            onTap: () => _userAction(
              context,
              ref,
              req(u.locked ? UserOp.USER_UNLOCK : UserOp.USER_LOCK),
              u.locked ? '${u.name} unlocked' : '${u.name} locked',
            ),
          ),
        if (!protected)
          SheetAction(
            icon: Icons.person_remove_outlined,
            label: 'Delete user',
            destructive: true,
            onTap: () => _deleteUser(u),
          ),
      ],
    );
  }

  Future<void> _deleteUser(SystemUser u) async {
    var removeHome = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          icon: Icon(Icons.person_remove_outlined, color: dialogContext.cs.error),
          title: Text('Delete ${u.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The account is removed. This cannot be undone.'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: removeHome,
                onChanged: (v) => setState(() => removeHome = v ?? false),
                title: Text('Also delete ${u.home}'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: dialogContext.cs.error, foregroundColor: dialogContext.cs.onError),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await _userAction(
      context,
      ref,
      UserRequest()
        ..op = UserOp.USER_DELETE
        ..username = u.name
        ..removeHome = removeHome,
      '${u.name} deleted',
    );
  }
}

class _UserCard extends StatelessWidget {
  final SystemUser user;
  final bool isAgentUser;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.isAgentUser, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final u = user;
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: u.uid == 0 ? context.cs.errorContainer : context.cs.primaryContainer,
            child: Text(
              u.name.substring(0, 1).toUpperCase(),
              style: context.tt.titleMedium?.copyWith(
                color: u.uid == 0 ? context.cs.onErrorContainer : context.cs.onPrimaryContainer,
              ),
            ),
          ),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: context.tt.titleMedium),
                Text(
                  [if (u.fullName.isNotEmpty) u.fullName, 'UID ${u.uid}', u.shell.split('/').last].join(' · '),
                  style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                ),
                const Gap(Insets.sm),
                Wrap(
                  spacing: Insets.xs,
                  runSpacing: Insets.xs,
                  children: [
                    if (isAgentUser) const StatusPill('You', tone: Tone.primary, icon: Icons.phone_android),
                    if (u.canSudo) const StatusPill('sudo', tone: Tone.warning, icon: Icons.admin_panel_settings_outlined),
                    if (u.locked) const StatusPill('Locked', tone: Tone.danger, icon: Icons.lock_outline),
                    if (!u.hasPassword && !u.locked && !u.isSystem) const StatusPill('No password', tone: Tone.neutral),
                    if (u.isSystem) const StatusPill('System'),
                    for (final g in u.groups.skip(1).where((g) => g != 'sudo').take(4)) StatusPill(g),
                    if (u.groups.length > 5) StatusPill('+${u.groups.length - 5}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewUserPage extends StatefulWidget {
  final Set<String> groups;
  final List<String> shells;
  final Set<String> existing;

  const _NewUserPage({required this.groups, required this.shells, required this.existing});

  @override
  State<_NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<_NewUserPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _fullName = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _sudo = false;
  String _shell = '/bin/bash';
  final Set<String> _groups = {};

  @override
  void dispose() {
    for (final c in [_name, _fullName, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = _commonGroups.where(widget.groups.contains).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('New user'),
        actions: [
          TextButton(
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              Navigator.pop(
                context,
                UserRequest()
                  ..op = UserOp.USER_CREATE
                  ..username = _name.text.trim()
                  ..fullName = _fullName.text.trim()
                  ..password = _password.text
                  ..sudo = _sudo
                  ..shell = _shell
                  ..groups.addAll(_groups),
              );
            },
            child: const Text('Create'),
          ),
          const Gap(Insets.sm),
        ],
      ),
      body: ContentWidth(
        maxWidth: 640,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(Insets.page),
            children: [
              TextFormField(
                controller: _name,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'User name', hintText: 'alice', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (!RegExp(r'^[a-z_][a-z0-9_-]{0,31}$').hasMatch(t)) return 'Lowercase letters, digits, - and _';
                  if (widget.existing.contains(t)) return 'This user exists already';
                  return null;
                },
              ),
              const Gap(Insets.md),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full name (optional)', prefixIcon: Icon(Icons.badge_outlined)),
              ),
              const Gap(Insets.md),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                validator: (v) => (v ?? '').length < 6 ? 'At least 6 characters' : null,
              ),
              const Gap(Insets.md),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Repeat password', prefixIcon: Icon(Icons.lock_outline)),
                validator: (v) => v != _password.text ? 'The passwords do not match' : null,
              ),
              const Gap(Insets.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Administrator (sudo)'),
                subtitle: const Text('Can run commands as root'),
                value: _sudo,
                onChanged: (v) => setState(() => _sudo = v),
              ),
              if (available.isNotEmpty) ...[
                const SectionHeader(title: 'Groups', subtitle: 'Hardware access and more'),
                Wrap(
                  spacing: Insets.xs,
                  runSpacing: Insets.xs,
                  children: [
                    for (final g in available)
                      FilterChip(
                        label: Text(g),
                        selected: _groups.contains(g),
                        onSelected: (v) => setState(() => v ? _groups.add(g) : _groups.remove(g)),
                      ),
                  ],
                ),
              ],
              const Gap(Insets.md),
              DropdownButtonFormField<String>(
                initialValue: widget.shells.contains(_shell) ? _shell : null,
                decoration: const InputDecoration(labelText: 'Login shell', prefixIcon: Icon(Icons.terminal)),
                items: [for (final s in widget.shells) DropdownMenuItem(value: s, child: Text(s))],
                onChanged: (v) => setState(() => _shell = v ?? '/bin/bash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
