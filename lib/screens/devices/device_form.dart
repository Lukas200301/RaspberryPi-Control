import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/ssh_connection.dart';
import '../../providers/app_providers.dart';
import '../../services/ssh_service.dart';
import '../../theme/app_theme.dart';
import '../../ui/ui.dart';

enum _Auth { password, key }

/// Adds a device or edits [device]. Resolves to the saved device.
Future<SSHConnection?> showDeviceForm(
  BuildContext context, {
  SSHConnection? device,
  String? host,
  int? port,
  String? name,
}) {
  return Navigator.push<SSHConnection>(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _DeviceForm(device: device, host: host, port: port, name: name),
    ),
  );
}

class _DeviceForm extends ConsumerStatefulWidget {
  final SSHConnection? device;
  final String? host;
  final int? port;
  final String? name;

  const _DeviceForm({this.device, this.host, this.port, this.name});

  @override
  ConsumerState<_DeviceForm> createState() => _DeviceFormState();
}

class _DeviceFormState extends ConsumerState<_DeviceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.device?.name ?? widget.name ?? '');
  late final _host = TextEditingController(text: widget.device?.host ?? widget.host ?? '');
  late final _port = TextEditingController(text: '${widget.device?.port ?? widget.port ?? 22}');
  late final _user = TextEditingController(text: widget.device?.username ?? 'pi');
  late final _password = TextEditingController(text: widget.device?.password ?? '');
  late final _key = TextEditingController(text: widget.device?.privateKey ?? '');
  late final _passphrase = TextEditingController(text: widget.device?.passphrase ?? '');
  late final _group = TextEditingController(text: widget.device?.group ?? '');
  late _Auth _auth = (widget.device?.usesKey ?? false) ? _Auth.key : _Auth.password;
  bool _obscure = true;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  bool get _editing => widget.device != null;

  @override
  void dispose() {
    for (final c in [_name, _host, _port, _user, _password, _key, _passphrase, _group]) {
      c.dispose();
    }
    super.dispose();
  }

  SSHConnection _build() {
    final host = _host.text.trim();
    return SSHConnection(
      id: widget.device?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim().isEmpty ? host : _name.text.trim(),
      host: host,
      port: int.tryParse(_port.text.trim()) ?? 22,
      username: _user.text.trim(),
      password: _password.text,
      privateKey: _auth == _Auth.key ? _key.text.trim() : '',
      passphrase: _auth == _Auth.key ? _passphrase.text : '',
      group: _group.text.trim(),
      isFavorite: widget.device?.isFavorite ?? false,
      lastConnected: widget.device?.lastConnected,
      agentVersion: widget.device?.agentVersion,
    );
  }

  Future<void> _loadKey() async {
    final file = await FilePicker.pickFile();
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _key.text = utf8.decode(bytes, allowMalformed: true).trim());
  }

  Future<void> _test() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final watch = Stopwatch()..start();
    try {
      final client = await SSHService.openClient(_build(), keepAliveInterval: null);
      final out = utf8.decode(await client.run('uname -srm'));
      client.close();
      setState(() {
        _testOk = true;
        _testResult = 'Connected in ${watch.elapsedMilliseconds} ms · ${out.trim()}';
      });
    } catch (e) {
      final text = e.toString().toLowerCase();
      setState(() {
        _testOk = false;
        _testResult = text.contains('auth')
            ? 'Login failed: check the username, password or key'
            : text.contains('timed out') || text.contains('timeout')
            ? 'No answer from the device'
            : text.contains('refused')
            ? 'Connection refused: is SSH enabled and the port right?'
            : describeError(e);
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final device = _build();
    final notifier = ref.read(connectionListProvider.notifier);
    if (_editing) {
      await notifier.updateConnection(device);
    } else {
      await notifier.addConnection(device);
    }
    if (mounted) Navigator.pop(context, device);
  }

  @override
  Widget build(BuildContext context) {
    final groups = {
      for (final d in ref.watch(connectionListProvider))
        if (d.group.isNotEmpty) d.group,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit device' : 'Add device'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
          const Gap(Insets.sm),
        ],
      ),
      body: ContentWidth(
        maxWidth: 640,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(Insets.page),
            children: [
              const SectionHeader(title: 'Device'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Living room Pi',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const Gap(Insets.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _host,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Host or IP',
                        hintText: 'raspberrypi.local',
                        prefixIcon: Icon(Icons.dns_outlined),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const Gap(Insets.md),
                  Expanded(
                    child: TextFormField(
                      controller: _port,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Port'),
                      validator: (v) {
                        final p = int.tryParse((v ?? '').trim());
                        return p == null || p < 1 || p > 65535 ? '1–65535' : null;
                      },
                    ),
                  ),
                ],
              ),
              const Gap(Insets.md),
              TextFormField(
                controller: _group,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Group (optional)',
                  hintText: 'Home, Office, Lab…',
                  prefixIcon: const Icon(Icons.folder_outlined),
                  suffixIcon: groups.isEmpty
                      ? null
                      : PopupMenuButton<String>(
                          tooltip: 'Existing groups',
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (g) => setState(() => _group.text = g),
                          itemBuilder: (_) => [
                            for (final g in groups) PopupMenuItem(value: g, child: Text(g)),
                          ],
                        ),
                ),
              ),
              const SectionHeader(title: 'Login'),
              TextFormField(
                controller: _user,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
              ),
              const Gap(Insets.md),
              SegmentedButton<_Auth>(
                segments: const [
                  ButtonSegment(value: _Auth.password, icon: Icon(Icons.password), label: Text('Password')),
                  ButtonSegment(value: _Auth.key, icon: Icon(Icons.key), label: Text('SSH key')),
                ],
                selected: {_auth},
                onSelectionChanged: (v) => setState(() => _auth = v.first),
              ),
              const Gap(Insets.md),
              if (_auth == _Auth.password)
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                )
              else ...[
                TextFormField(
                  controller: _key,
                  minLines: 4,
                  maxLines: 8,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: AppTheme.mono(size: 11, color: context.cs.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Private key',
                    hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Paste a key or load it from a file';
                    if (!t.contains('PRIVATE KEY')) return 'This does not look like a private key';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _loadKey,
                    icon: const Icon(Icons.file_open_outlined),
                    label: const Text('Load from file'),
                  ),
                ),
                TextFormField(
                  controller: _passphrase,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Key passphrase (if any)',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const Gap(Insets.md),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (optional fallback)',
                    helperText: 'Used if the server does not accept the key, and to set up sudo',
                    prefixIcon: Icon(Icons.password),
                  ),
                ),
              ],
              const Gap(Insets.xl),
              OutlinedButton.icon(
                onPressed: _testing ? null : _test,
                icon: _testing
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.network_check),
                label: Text(_testing ? 'Testing…' : 'Test connection'),
              ),
              if (_testResult != null) ...[
                const Gap(Insets.md),
                AppCard(
                  accent: _testOk ? context.ac.success : context.cs.error,
                  padding: const EdgeInsets.all(Insets.md),
                  child: Row(
                    children: [
                      Icon(
                        _testOk ? Icons.check_circle : Icons.error_outline,
                        color: _testOk ? context.ac.success : context.cs.error,
                      ),
                      const Gap(Insets.md),
                      Expanded(child: Text(_testResult!)),
                    ],
                  ),
                ),
              ],
              const Gap(Insets.md),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_editing ? 'Save changes' : 'Save device'),
              ),
              const Gap(Insets.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
