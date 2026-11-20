import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/widgets/custom_app_bar.dart';
import 'package:trusttunnel/widgets/scaffold_wrapper.dart';

class AppVpnScreen extends StatefulWidget {
  const AppVpnScreen({super.key});

  @override
  State<AppVpnScreen> createState() => _AppVpnScreenState();
}

class _Rules {
  _Rules(Map data)
    : enabled = data['enabled'] as bool,
      bypass = data['bypass'] as bool,
      packages = Set<String>.from(data['packages'] as List),
      revision = data['revision'] as String;

  final bool enabled;
  final bool bypass;
  final Set<String> packages;
  final String revision;

  bool matches(_Rules other) =>
      enabled == other.enabled &&
      (!enabled ||
          (bypass == other.bypass && setEquals(packages, other.packages)));
}

class _App {
  _App(Map data)
    : name = data['label'] as String,
      package = data['package'] as String,
      uid = data['uid'] as int,
      system = data['system'] as bool;

  final String name;
  final String package;
  final int uid;
  final bool system;
}

class _AppVpnScreenState extends State<AppVpnScreen>
    with WidgetsBindingObserver {
  static const _methods = MethodChannel('trusttunnel/app_vpn');
  static const _changes = EventChannel('trusttunnel/app_vpn_changes');
  late final StreamSubscription<dynamic> _events;
  Timer? _packageRefresh;
  int _statusRequest = 0;
  int _catalogRequest = 0;
  _Rules? _saved;
  _Rules? _applied;
  Set<String> _effective = {};
  String? _storageError;
  String? _serviceError;
  String _state = 'DISCONNECTED';
  List<List<_App>>? _groups;
  bool _catalogFailed = false;
  bool _busy = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _events = _changes.receiveBroadcastStream().listen((event) {
      if (event == 'packages') {
        _packageRefresh?.cancel();
        _packageRefresh = Timer(
          const Duration(milliseconds: 200),
          _loadCatalog,
        );
      } else {
        _loadStatus();
      }
    }, onError: (_) => _loadStatus());
    _loadStatus();
    _loadCatalog();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatus();
      _loadCatalog();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _packageRefresh?.cancel();
    _searchController.dispose();
    _events.cancel();
    super.dispose();
  }

  void _display(Map snapshot) {
    _saved = snapshot['rules'] is Map ? _Rules(snapshot['rules'] as Map) : null;
    _applied = snapshot['applied'] is Map
        ? _Rules(snapshot['applied'] as Map)
        : null;
    _effective = Set<String>.from(snapshot['effective'] as List? ?? const []);
    _storageError = snapshot['storageError'] as String?;
    _serviceError = snapshot['error'] as String?;
    _state = snapshot['state'] as String;
  }

  Future<void> _loadStatus() async {
    final request = ++_statusRequest;
    try {
      final snapshot = await _methods.invokeMapMethod<String, dynamic>(
        'status',
      );
      if (mounted && request == _statusRequest && snapshot != null)
        setState(() => _display(snapshot));
    } on PlatformException catch (error) {
      if (mounted && request == _statusRequest)
        setState(() => _storageError = error.code);
    }
  }

  Future<void> _loadCatalog() async {
    final request = ++_catalogRequest;
    try {
      final data = await _methods.invokeListMethod<dynamic>('catalog') ?? [];
      final byUid = <int, List<_App>>{};
      for (final item in data.cast<Map>()) {
        final app = _App(item);
        (byUid[app.uid] ??= []).add(app);
      }
      int compare(_App a, _App b) {
        final label = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return label == 0 ? a.package.compareTo(b.package) : label;
      }

      final groups = byUid.values.toList();
      for (final group in groups) {
        group.sort(compare);
      }
      groups.sort((a, b) => compare(a.first, b.first));
      if (mounted && request == _catalogRequest)
        setState(() {
          _groups = groups;
          _catalogFailed = false;
        });
    } on PlatformException {
      if (mounted && request == _catalogRequest)
        setState(() {
          _groups = null;
          _catalogFailed = true;
        });
    }
  }

  String _message(String reason) {
    final ln = context.ln;
    return switch (reason) {
      'empty' => ln.appVpnEmpty,
      'group' => ln.appVpnSharedError,
      'storage' || 'version' => ln.appVpnStorageError,
      'write' => ln.appVpnWriteError,
      'changed' => ln.appVpnChanged,
      'package' || 'self' => ln.appVpnPackageError,
      'inactive' => ln.appVpnInactive,
      _ => ln.appVpnOperationError,
    };
  }

  Future<void> _command(String method, [Map<String, Object?>? args]) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _methods.invokeMethod<void>(method, args);
    } on PlatformException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_message(error.code))));
    } finally {
      if (mounted) {
        await _loadStatus();
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  void _save({bool? enabled, bool? bypass, Set<String>? packages}) {
    final current = _saved;
    if (current == null) return;
    _command('save', {
      'enabled': enabled ?? current.enabled,
      'bypass': bypass ?? current.bypass,
      'packages': (packages ?? current.packages).toList(),
      'revision': current.revision,
    });
  }

  Future<void> _repair() async {
    final ln = context.ln;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(ln.appVpnReset),
        content: Text(ln.appVpnResetDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(ln.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(ln.appVpnReset),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _command('repair');
  }

  String _mode(_Rules rules) {
    if (!rules.enabled) return context.ln.appVpnOff;
    return rules.bypass ? context.ln.appVpnExclude : context.ln.appVpnInclude;
  }

  Iterable<Widget> _connection(_Rules? saved) sync* {
    final applied = _applied;
    final ln = context.ln;
    final state = switch (_state) {
      'CONNECTED' => ln.appVpnConnected,
      'DISCONNECTED' => ln.appVpnDisconnected,
      _ => ln.appVpnTransition,
    };
    yield ListTile(
      title: Text(state),
      subtitle: applied == null ? null : Text(ln.appVpnInUse(_mode(applied))),
    );
    if (applied != null && applied.enabled && _effective.isNotEmpty) {
      yield ExpansionTile(
        title: Text(ln.appVpnActivePackages(_effective.length)),
        children: [
          for (final name in _effective.toList()..sort())
            ListTile(dense: true, title: Text(name)),
        ],
      );
    }
    if (_serviceError case final reason?) {
      yield ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(_message(reason)),
      );
    }
    if (saved != null && applied != null && !saved.matches(applied)) {
      yield ListTile(
        title: Text(ln.appVpnPending),
        subtitle: Text(ln.appVpnReconnectHint),
      );
      yield Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () => _command('reconnect', {'revision': saved.revision}),
            child: Text(ln.appVpnReconnect),
          ),
        ),
      );
    }
  }

  Widget _entry(_Rules rules, List<String> names, String title, String detail) {
    final all = names.every(rules.packages.contains);
    final any = names.any(rules.packages.contains);
    return CheckboxListTile(
      value: all ? true : (any ? null : false),
      tristate: true,
      title: Text(title),
      subtitle: Text(detail),
      onChanged: _busy
          ? null
          : (_) {
              final updated = {...rules.packages};
              if (all) {
                updated.removeAll(names);
              } else {
                updated.addAll(names);
              }
              _save(packages: updated);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ln = context.ln;
    final saved = _saved;
    final groups = _groups;
    final controls = <Widget>[
      if (_storageError case final reason?) ...[
        ListTile(title: Text(_message(reason))),
        if (reason == 'storage' || reason == 'version')
          TextButton(
            onPressed: _busy ? null : _repair,
            child: Text(ln.appVpnReset),
          )
        else
          TextButton(onPressed: _loadStatus, child: Text(ln.appVpnRetry)),
      ] else if (saved == null)
        const LinearProgressIndicator(),
      if (saved != null) ...[
        SwitchListTile(
          title: Text(ln.appVpnEnable),
          value: saved.enabled,
          onChanged: _busy ? null : (v) => _save(enabled: v),
        ),
        if (saved.enabled) ...[
          RadioGroup<bool>(
            groupValue: saved.bypass,
            onChanged: (v) {
              if (v != null && !_busy) _save(bypass: v);
            },
            child: Column(
              children: [
                RadioListTile<bool>(
                  enabled: !_busy,
                  value: false,
                  title: Text(ln.appVpnInclude),
                ),
                RadioListTile<bool>(
                  enabled: !_busy,
                  value: true,
                  title: Text(ln.appVpnExclude),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(ln.appVpnChosen(saved.packages.length)),
            subtitle: Text(ln.appVpnLockdown),
          ),
        ],
      ],
      ..._connection(saved),
    ];
    final visible = <List<_App>>[];
    final missing = <String>[];
    if (saved != null && saved.enabled) {
      if (_catalogFailed) {
        controls.add(
          TextButton(onPressed: _loadCatalog, child: Text(ln.appVpnRetryApps)),
        );
      } else if (groups == null) {
        controls.add(const LinearProgressIndicator());
      } else {
        final installed = <String>{};
        for (final group in groups) {
          installed.addAll(group.map((a) => a.package));
          if (group.any(
            (a) =>
                a.name.toLowerCase().contains(_query) ||
                a.package.toLowerCase().contains(_query),
          ))
            visible.add(group);
        }
        missing.addAll(
          saved.packages.where(
            (p) => !installed.contains(p) && p.toLowerCase().contains(_query),
          ),
        );
        missing.sort();
        if (!saved.packages.any(installed.contains)) {
          controls.add(
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                saved.bypass ? ln.appVpnNoExclusions : ln.appVpnEmpty,
              ),
            ),
          );
        }
        controls.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: ln.appVpnSearch,
              ),
              onChanged: (s) => setState(() => _query = s.trim().toLowerCase()),
            ),
          ),
        );
        if (visible.isEmpty && missing.isEmpty)
          controls.add(ListTile(title: Text(ln.appVpnNoMatches)));
      }
    }
    return ScaffoldWrapper(
      child: Scaffold(
        appBar: CustomAppBar(title: ln.appVpnTitle, leadingIconType: AppBarLeadingIconType.back),
        body: ListView.builder(
          itemCount: controls.length + visible.length + missing.length,
          itemBuilder: (context, index) {
            if (index < controls.length) return controls[index];
            final row = index - controls.length;
            if (row < visible.length) {
              final group = visible[row];
              final names = group.map((a) => a.package).toList();
              final parts = [
                if (group.any((a) => a.system)) ln.appVpnSystemApp,
                if (group.length > 1) ln.appVpnSharedUid,
                ...names,
              ];
              return _entry(
                saved!,
                names,
                group.map((a) => a.name).join(' · '),
                parts.join('\n'),
              );
            }
            final name = missing[row - visible.length];
            return _entry(saved!, [name], name, ln.appVpnMissing);
          },
        ),
      ),
    );
  }
}
