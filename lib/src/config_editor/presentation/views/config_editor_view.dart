import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';
import 'package:vendervpn/src/config_editor/presentation/adapter/config_editor_adapter.dart';
import 'package:vendervpn/src/config_editor/presentation/views/widgets/editor_fields.dart';

/// Edits a local (imported) node: server, credentials, transport and TLS.
/// Cloud nodes are not editable.
class ConfigEditorView extends ConsumerStatefulWidget {
  const ConfigEditorView({super.key, required this.config});

  static const path = '/config-editor';

  final Config? config;

  @override
  ConsumerState<ConfigEditorView> createState() => _ConfigEditorViewState();
}

class _ConfigEditorViewState extends ConsumerState<ConfigEditorView> {
  EditableNode? _initial;
  EditableNode? _draft;
  bool _showSecret = false;

  static const _networks = ['tcp', 'ws', 'grpc', 'h2', 'xhttp', 'kcp', 'quic'];
  static const _tcpHeaders = ['none', 'http'];
  static const _udpHeaders = [
    'none',
    'srtp',
    'utp',
    'wechat-video',
    'dtls',
    'wireguard',
  ];
  static const _grpcModes = ['gun', 'multi'];
  static const _xhttpModes = ['auto', 'packet-up', 'stream-up', 'stream-one'];
  static const _fingerprints = [
    '',
    'chrome',
    'firefox',
    'safari',
    'ios',
    'android',
    'edge',
    '360',
    'qq',
    'random',
    'randomized',
  ];
  static const _ssMethods = [
    'aes-128-gcm',
    'aes-256-gcm',
    'chacha20-poly1305',
    'chacha20-ietf-poly1305',
    'xchacha20-poly1305',
    'xchacha20-ietf-poly1305',
    '2022-blake3-aes-128-gcm',
    '2022-blake3-aes-256-gcm',
    '2022-blake3-chacha20-poly1305',
    'none',
  ];
  static const _vmessCiphers = [
    'auto',
    'aes-128-gcm',
    'chacha20-poly1305',
    'none',
    'zero',
  ];
  static const _flows = ['', 'xtls-rprx-vision', 'xtls-rprx-vision-udp443'];

  bool get _isDirty => _draft != null && _draft != _initial;

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    if (config != null) {
      Future.microtask(() {
        if (mounted) ref.read(configEditorProvider.notifier).load(config);
      });
    }
  }

  void _update(EditableNode Function(EditableNode node) change) {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _draft = change(draft));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    FocusScope.of(context).unfocus();
    final error = await ref.read(configEditorProvider.notifier).save(draft);
    if (!mounted) return;
    if (error != null) {
      CoreUtils.showSnackBar(
        context,
        true,
        title: 'Not saved',
        message: error,
      );
      return;
    }
    setState(() => _initial = draft);
    CoreUtils.showSnackBar(
      context,
      false,
      title: 'Saved',
      message: 'Node settings updated.',
    );
    context.pop();
  }

  Future<void> _copyLink() async {
    final draft = _draft;
    if (draft == null) return;
    final result = await ref
        .read(configEditorProvider.notifier)
        .shareLink(draft);
    if (!mounted) return;
    await result.fold(
      (failure) async => CoreUtils.showSnackBar(
        context,
        true,
        title: 'Copy failed',
        message: failure.message,
      ),
      (link) async {
        await Clipboard.setData(ClipboardData(text: link));
        if (!mounted) return;
        CoreUtils.showSnackBar(
          context,
          false,
          title: 'Copied',
          message: 'Share link copied to the clipboard.',
        );
      },
    );
  }

  Future<void> _confirmDiscard() async {
    final textColor = Colours.classicAdabtiveTextColor(context);
    final discard = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(ctx).bottom + 12,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colours.cardSurface(ctx),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colours.subtleBorder(ctx)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colours.pastelRoseBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colours.pastelRoseFg,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discard changes?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Your edits to this node will be lost.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colours.subtitleGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colours.pastelRoseFg,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Discard',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(
                      'Keep editing',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    if (discard == true && mounted) {
      setState(() => _initial = _draft);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(configEditorProvider);
    final textColor = Colours.classicAdabtiveTextColor(context);

    // The first loaded node becomes both the baseline and the draft.
    if (_draft == null && state is ConfigEditorReady) {
      _initial = state.node;
      _draft = state.node;
    }
    final isSaving = state is ConfigEditorSaving;
    final draft = _draft;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: Colours.scaffoldBg(context),
        appBar: AppBar(
          backgroundColor: Colours.scaffoldBg(context),
          surfaceTintColor: Colors.transparent,
          foregroundColor: textColor,
          title: const Text(
            'Edit node',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          actions: [
            if (draft != null)
              IconButton(
                tooltip: 'Copy share link',
                onPressed: isSaving ? null : _copyLink,
                icon: const Icon(Icons.copy_rounded, size: 20),
              ),
            if (draft != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: isSaving || !_isDirty ? null : _save,
                  child:
                      isSaving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colours.orbViolet,
                            ),
                          )
                          : const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                ),
              ),
          ],
        ),
        body: SafeArea(child: _buildBody(state, draft)),
      ),
    );
  }

  Widget _buildBody(ConfigEditorState state, EditableNode? draft) {
    if (widget.config == null) {
      return const EditorMessage(
        icon: Icons.error_outline_rounded,
        message: 'No node was selected for editing.',
      );
    }
    if (state is ConfigEditorLoadFailed) {
      return EditorMessage(
        icon: Icons.error_outline_rounded,
        message: state.message,
      );
    }
    if (draft == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colours.orbViolet),
      );
    }

    final p = draft.protocol;
    return AbsorbPointer(
      absorbing: state is ConfigEditorSaving,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          EditorSection(
            title: 'General',
            trailing: EditorChip(label: p.label),
            children: [
              EditorTextField(
                fieldKey: 'remark',
                label: 'Name',
                initialValue: draft.remark,
                onChanged: (v) => _update((n) => n.copyWith(remark: v)),
              ),
              EditorTextField(
                fieldKey: 'address',
                label: 'Address',
                hint: 'example.com or 1.2.3.4',
                initialValue: draft.address,
                keyboardType: TextInputType.url,
                onChanged: (v) => _update((n) => n.copyWith(address: v.trim())),
              ),
              EditorTextField(
                fieldKey: 'port',
                label: 'Port',
                initialValue: '${draft.port}',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged:
                    (v) => _update((n) => n.copyWith(port: int.tryParse(v) ?? 0)),
              ),
            ],
          ),
          EditorSection(
            title: p.isHysteria ? 'Authentication' : 'Credentials',
            children: [
              if (p.usesUserId)
                EditorTextField(
                  fieldKey: 'userId',
                  label: 'UUID',
                  initialValue: draft.userId,
                  onChanged:
                      (v) => _update((n) => n.copyWith(userId: v.trim())),
                ),
              if (p.usesAlterId)
                EditorTextField(
                  fieldKey: 'alterId',
                  label: 'Alter ID',
                  initialValue: '${draft.alterId}',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged:
                      (v) => _update(
                        (n) => n.copyWith(alterId: int.tryParse(v) ?? 0),
                      ),
                ),
              if (p.usesAlterId)
                EditorDropdown(
                  label: 'Security',
                  value: draft.cipher,
                  options: _vmessCiphers,
                  onChanged: (v) => _update((n) => n.copyWith(cipher: v)),
                ),
              if (p.usesFlow)
                EditorDropdown(
                  label: 'Flow',
                  value: draft.flow,
                  options: _flows,
                  onChanged: (v) => _update((n) => n.copyWith(flow: v)),
                ),
              if (p.usesFlow)
                EditorTextField(
                  fieldKey: 'encryption',
                  label: 'Encryption',
                  initialValue: draft.encryption,
                  onChanged:
                      (v) => _update((n) => n.copyWith(encryption: v.trim())),
                ),
              if (p.usesMethod)
                EditorDropdown(
                  label: 'Method',
                  value: draft.method,
                  options: _ssMethods,
                  onChanged: (v) => _update((n) => n.copyWith(method: v)),
                ),
              if (p.usesUsername)
                EditorTextField(
                  fieldKey: 'username',
                  label: 'Username (optional)',
                  initialValue: draft.username,
                  onChanged: (v) => _update((n) => n.copyWith(username: v)),
                ),
              if (p.usesSecret)
                EditorTextField(
                  fieldKey: 'secret',
                  label:
                      p.isHysteria
                          ? 'Auth'
                          : p.secretOptional
                          ? 'Password (optional)'
                          : 'Password',
                  initialValue: draft.secret,
                  obscureText: !_showSecret,
                  suffix: IconButton(
                    icon: Icon(
                      _showSecret
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                      color: Colours.subtitleGrey,
                    ),
                    onPressed: () => setState(() => _showSecret = !_showSecret),
                  ),
                  onChanged: (v) => _update((n) => n.copyWith(secret: v)),
                ),
            ],
          ),
          if (p.hasTransport) _transportSection(draft),
          if (p.hasTransport || p.isHysteria) _tlsSection(draft),
        ],
      ),
    );
  }

  Widget _transportSection(EditableNode draft) {
    final network = draft.network;
    final showHost = network != 'kcp' && network != 'quic';
    final showPath =
        network == 'ws' ||
        network == 'h2' ||
        network == 'xhttp' ||
        (network == 'tcp' && draft.headerType == 'http');
    return EditorSection(
      title: 'Transport',
      children: [
        EditorDropdown(
          label: 'Network',
          value: network,
          options: _networks,
          onChanged:
              (v) => _update(
                (n) => n.copyWith(
                  network: v,
                  headerType: 'none',
                  transportMode: '',
                ),
              ),
        ),
        if (network == 'tcp')
          EditorDropdown(
            label: 'Header type',
            value: draft.headerType,
            options: _tcpHeaders,
            onChanged: (v) => _update((n) => n.copyWith(headerType: v)),
          ),
        if (network == 'kcp' || network == 'quic')
          EditorDropdown(
            label: 'Header type',
            value: draft.headerType,
            options: _udpHeaders,
            onChanged: (v) => _update((n) => n.copyWith(headerType: v)),
          ),
        if (network == 'grpc') ...[
          EditorTextField(
            fieldKey: 'serviceName',
            label: 'Service name',
            initialValue: draft.serviceName,
            onChanged: (v) => _update((n) => n.copyWith(serviceName: v.trim())),
          ),
          EditorDropdown(
            label: 'Mode',
            value: draft.transportMode.isEmpty ? 'gun' : draft.transportMode,
            options: _grpcModes,
            onChanged: (v) => _update((n) => n.copyWith(transportMode: v)),
          ),
        ],
        if (network == 'xhttp')
          EditorDropdown(
            label: 'Mode',
            value: draft.transportMode.isEmpty ? 'auto' : draft.transportMode,
            options: _xhttpModes,
            onChanged: (v) => _update((n) => n.copyWith(transportMode: v)),
          ),
        if (showHost)
          EditorTextField(
            fieldKey: 'host-$network',
            label: 'Host',
            initialValue: draft.host,
            onChanged: (v) => _update((n) => n.copyWith(host: v.trim())),
          ),
        if (showPath)
          EditorTextField(
            fieldKey: 'path-$network',
            label: 'Path',
            hint: '/',
            initialValue: draft.path,
            onChanged: (v) => _update((n) => n.copyWith(path: v.trim())),
          ),
      ],
    );
  }

  Widget _tlsSection(EditableNode draft) {
    final p = draft.protocol;
    final securityOptions = [
      if (!p.isHysteria) 'none',
      'tls',
      if (p.supportsReality) 'reality',
    ];
    final security = draft.security;
    final secured = security == 'tls' || security == 'reality';
    return EditorSection(
      title: 'Security',
      children: [
        EditorDropdown(
          label: 'TLS',
          value: security,
          options: securityOptions,
          onChanged: (v) => _update((n) => n.copyWith(security: v)),
        ),
        if (secured) ...[
          EditorTextField(
            fieldKey: 'sni',
            label: 'SNI',
            initialValue: draft.sni,
            onChanged: (v) => _update((n) => n.copyWith(sni: v.trim())),
          ),
          EditorDropdown(
            label: 'Fingerprint',
            value: draft.fingerprint,
            options: _fingerprints,
            onChanged: (v) => _update((n) => n.copyWith(fingerprint: v)),
          ),
        ],
        if (security == 'tls' && !p.isHysteria)
          EditorTextField(
            fieldKey: 'alpn',
            label: 'ALPN',
            hint: 'h2,http/1.1',
            initialValue: draft.alpn,
            onChanged: (v) => _update((n) => n.copyWith(alpn: v.trim())),
          ),
        if (security == 'reality') ...[
          EditorTextField(
            fieldKey: 'publicKey',
            label: 'Public key',
            initialValue: draft.publicKey,
            onChanged: (v) => _update((n) => n.copyWith(publicKey: v.trim())),
          ),
          EditorTextField(
            fieldKey: 'shortId',
            label: 'Short ID',
            initialValue: draft.shortId,
            onChanged: (v) => _update((n) => n.copyWith(shortId: v.trim())),
          ),
          EditorTextField(
            fieldKey: 'spiderX',
            label: 'SpiderX',
            initialValue: draft.spiderX,
            onChanged: (v) => _update((n) => n.copyWith(spiderX: v.trim())),
          ),
        ],
      ],
    );
  }
}
