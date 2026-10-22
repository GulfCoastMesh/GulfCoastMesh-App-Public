import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/tcp_meshcore_transport.dart';
import '../l10n/l10n.dart';
import '../models/connection_profile.dart';
import '../services/connection_profile_service.dart';
import '../storage/support_prompt_store.dart';
import '../theme/app_colors.dart';
import '../utils/dialog_utils.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/device_tile.dart';
import 'home_screen.dart';

/// Screen for scanning and connecting to MeshCore devices.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _changedNavigation = false;
  late final MeshCoreConnector _connector;
  late final VoidCallback _connectionListener;
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  Future<void>? _discoveryFuture;
  int _discoveryGeneration = 0;
  bool _discoveryTransitionInProgress = false;

  MeshCoreTransportKind _selectedTransport = MeshCoreTransportKind.ble;

  /// USB serial exists on Android (OTG) and desktop, but not iOS or web.
  static bool get _usbSupported => !kIsWeb && !Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _connector = Provider.of<MeshCoreConnector>(context, listen: false);

    _connectionListener = () {
      if (_connector.isConnected && !_changedNavigation) {
        _changedNavigation = true;
        if (mounted) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } else if (!_connector.shouldKeepHub &&
          _connector.state == MeshCoreConnectionState.disconnected) {
        _changedNavigation = false;
      }
    };

    _connector.addListener(_connectionListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybeShowSupportPrompt());
      unawaited(_maybeAutoConnect());
    });

    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      setState(() {
        _bluetoothState = state;
      });
      if (_bluetoothState != BluetoothAdapterState.on) {
        unawaited(_stopBluetoothDiscovery());
      }
    }, onError: (Object error) => _showConnectionError(error));
  }

  @override
  void dispose() {
    _connector.removeListener(_connectionListener);
    unawaited(_bluetoothStateSubscription?.cancel());
    super.dispose();
  }

  Future<void> _maybeAutoConnect() async {
    if (!mounted) return;
    final profileService = context.read<ConnectionProfileService>();
    final connected = await profileService.tryLaunchAutoConnect(_connector);
    if (connected || !mounted) return;

    // Only worth interrupting the user if they actually asked for
    // auto-connect and it could not find anything.
    final error = profileService.lastAutoConnectError;
    if (error == null || profileService.autoConnectProfiles.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _maybeShowSupportPrompt() async {
    final store = SupportPromptStore();
    if (store.hasShownPrompt()) return;
    final firstLaunch = await store.loadOrInitFirstLaunch();
    if (DateTime.now().difference(firstLaunch) < const Duration(hours: 24)) {
      return;
    }
    await store.markPromptShown();
    if (!mounted) return;
    await showSupportPromptDialog(context);
  }

  bool get _bluetoothUnavailable =>
      _selectedTransport == MeshCoreTransportKind.ble &&
      _bluetoothState == BluetoothAdapterState.off;

  void _showConnectionError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.scanner_connectionFailed(error.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _runDiscovery(MeshCoreTransportKind kind, int generation) async {
    try {
      await _connector.startDiscovery(kind);
    } catch (error) {
      if (generation == _discoveryGeneration) _showConnectionError(error);
    } finally {
      if (mounted && generation == _discoveryGeneration) {
        setState(() => _discoveryFuture = null);
      }
    }
  }

  Future<void> _stopDiscovery({MeshCoreTransportKind? switchTo}) async {
    if (_discoveryTransitionInProgress) return;
    setState(() => _discoveryTransitionInProgress = true);
    try {
      await _connector.stopDiscovery(_selectedTransport);
      // A canceled discovery can finish later (for example USB enumeration).
      // Its completion must not clear a newer scan or show a stale error.
      _discoveryGeneration++;
      if (mounted) {
        setState(() {
          _discoveryFuture = null;
          if (switchTo != null) _selectedTransport = switchTo;
        });
      }
    } catch (error) {
      _showConnectionError(error);
    } finally {
      if (mounted) {
        setState(() => _discoveryTransitionInProgress = false);
      }
    }
  }

  Future<void> _stopBluetoothDiscovery() async {
    if (_selectedTransport == MeshCoreTransportKind.ble) {
      await _stopDiscovery();
      return;
    }
    try {
      await _connector.stopDiscovery(MeshCoreTransportKind.ble);
    } catch (error) {
      _showConnectionError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(context.l10n.scanner_title),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: Consumer2<MeshCoreConnector, ConnectionProfileService>(
          builder: (context, connector, profiles, child) {
            return Column(
              children: [
                if (_bluetoothUnavailable) _bluetoothOffWarning(context),
                _buildStatusBar(context, connector, profiles),
                _buildTransportSelector(context),
                Expanded(child: _buildBody(context, connector, profiles)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          connector.state ==
                              MeshCoreConnectionState.disconnected
                          ? () => _startDemo(context, connector)
                          : null,
                      icon: const Icon(Icons.science_outlined),
                      label: Text(context.l10n.demo_explore),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<MeshCoreConnector>(
        builder: (context, connector, child) => _buildFab(context, connector),
      ),
    );
  }

  Widget _buildTransportSelector(BuildContext context) {
    // Web has Bluetooth only; raw TCP and USB backends are native-only.
    if (kIsWeb) return const SizedBox.shrink();
    final l10n = context.l10n;
    final segments = <ButtonSegment<MeshCoreTransportKind>>[
      ButtonSegment(
        value: MeshCoreTransportKind.ble,
        label: Text(l10n.scanner_transportBluetooth),
        icon: const Icon(Icons.bluetooth),
      ),
      if (_usbSupported)
        ButtonSegment(
          value: MeshCoreTransportKind.usb,
          label: Text(l10n.scanner_transportUsb),
          icon: const Icon(Icons.usb),
        ),
      ButtonSegment(
        value: MeshCoreTransportKind.tcp,
        label: Text(l10n.scanner_transportNetwork),
        icon: const Icon(Icons.lan_outlined),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SegmentedButton<MeshCoreTransportKind>(
        segments: segments,
        selected: {_selectedTransport},
        showSelectedIcon: false,
        onSelectionChanged: _discoveryTransitionInProgress
            ? null
            : (selection) {
                final next = selection.first;
                if (next == _selectedTransport) return;
                unawaited(_stopDiscovery(switchTo: next));
              },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MeshCoreConnector connector,
    ConnectionProfileService profileService,
  ) {
    final saved = profileService.profiles
        .where((profile) => profile.transportKind == _selectedTransport)
        .toList();
    final discovered = connector
        .discoveredDevicesFor(_selectedTransport)
        .where(
          // A device already saved is shown once, in the saved section.
          (device) => !saved.any((profile) => profile.address == device.id),
        )
        .toList();

    if (saved.isEmpty && discovered.isEmpty) {
      return _buildEmptyState(context, connector);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (saved.isNotEmpty) ...[
          _sectionHeader(context, context.l10n.scanner_savedConnections),
          ...saved.map(
            (profile) => _buildProfileTile(context, connector, profile),
          ),
        ],
        if (discovered.isNotEmpty) ...[
          if (saved.isNotEmpty) const Divider(height: 24),
          ...discovered.map(
            (device) => DeviceTile(
              device: device,
              onTap: () => _connectToDevice(context, connector, device),
              onLongPress: () => _editProfileForDevice(context, device),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context,
    MeshCoreConnector connector,
    ConnectionProfile profile,
  ) {
    final l10n = context.l10n;
    final isActive =
        connector.isConnected &&
        connector.deviceId == profile.address &&
        connector.activeTransportKind == profile.transportKind;

    return ListTile(
      leading: Icon(_iconFor(profile.transportKind)),
      title: Text(profile.name),
      subtitle: Text(
        profile.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profile.autoConnect)
            Tooltip(
              message: l10n.scanner_autoConnect,
              child: const Icon(Icons.autorenew, size: 18),
            ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                size: 18,
                color: context.appColors.connected,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showProfileMenu(context, profile),
          ),
        ],
      ),
      onTap: isActive
          ? null
          : () => _connectToDevice(context, connector, profile.toDevice()),
    );
  }

  IconData _iconFor(MeshCoreTransportKind kind) {
    switch (kind) {
      case MeshCoreTransportKind.ble:
        return Icons.bluetooth;
      case MeshCoreTransportKind.usb:
        return Icons.usb;
      case MeshCoreTransportKind.tcp:
        return Icons.lan_outlined;
    }
  }

  Widget _buildEmptyState(BuildContext context, MeshCoreConnector connector) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final isScanning = connector.state == MeshCoreConnectionState.scanning;

    final (IconData icon, String text) = switch (_selectedTransport) {
      MeshCoreTransportKind.ble => (
        Icons.bluetooth,
        isScanning ? l10n.scanner_searchingDevices : l10n.scanner_tapToScan,
      ),
      MeshCoreTransportKind.usb => (
        Icons.usb,
        isScanning
            ? l10n.scanner_searchingUsbDevices
            : l10n.scanner_usbTapToRefresh,
      ),
      MeshCoreTransportKind.tcp => (
        Icons.lan_outlined,
        l10n.scanner_networkNoDiscovery,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context, MeshCoreConnector connector) {
    final l10n = context.l10n;

    if (_selectedTransport == MeshCoreTransportKind.tcp) {
      return FloatingActionButton.extended(
        onPressed: () => _editProfile(context, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.scanner_addNetworkDevice),
      );
    }

    final isScanning = connector.state == MeshCoreConnectionState.scanning;
    final isBle = _selectedTransport == MeshCoreTransportKind.ble;

    return FloatingActionButton.extended(
      onPressed:
          _bluetoothUnavailable ||
              _discoveryTransitionInProgress ||
              (_discoveryFuture != null && !isScanning)
          ? null
          : () {
              if (isScanning) {
                unawaited(_stopDiscovery());
              } else if (_discoveryFuture == null) {
                setState(() {
                  _discoveryFuture = _runDiscovery(
                    _selectedTransport,
                    ++_discoveryGeneration,
                  );
                });
              }
            },
      icon: isScanning
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          : Icon(isBle ? Icons.bluetooth_searching : Icons.refresh),
      label: Text(
        isScanning
            ? l10n.scanner_stop
            : (isBle ? l10n.scanner_scan : l10n.scanner_refresh),
      ),
    );
  }

  Widget _buildStatusBar(
    BuildContext context,
    MeshCoreConnector connector,
    ConnectionProfileService profileService,
  ) {
    String statusText;
    Color statusColor;

    final l10n = context.l10n;
    final appColors = context.appColors;
    switch (connector.state) {
      case MeshCoreConnectionState.scanning:
        statusText = l10n.scanner_scanning;
        statusColor = appColors.connecting;
        break;
      case MeshCoreConnectionState.connecting:
        statusText = l10n.scanner_connecting;
        statusColor = appColors.connecting;
        break;
      case MeshCoreConnectionState.connected:
        statusText = l10n.scanner_connectedTo(connector.deviceDisplayName);
        statusColor = appColors.connected;
        break;
      case MeshCoreConnectionState.disconnecting:
        statusText = l10n.scanner_disconnecting;
        statusColor = appColors.connecting;
        break;
      case MeshCoreConnectionState.disconnected:
        statusText = profileService.isAutoConnecting
            ? l10n.scanner_autoConnecting
            : l10n.scanner_notConnected;
        statusColor = profileService.isAutoConnecting
            ? appColors.connecting
            : appColors.disconnected;
        break;
    }

    // Which transport carried the session is not obvious once connected, and
    // it changes what a failure means — surface it alongside the state.
    final transportLabel = connector.isConnected
        ? _transportLabel(context, connector.activeTransportKind)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: statusColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
            ),
          ),
          if (transportLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              transportLabel,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  String? _transportLabel(BuildContext context, MeshCoreTransportKind? kind) {
    final l10n = context.l10n;
    return switch (kind) {
      MeshCoreTransportKind.ble => l10n.scanner_transportBluetooth,
      MeshCoreTransportKind.usb => l10n.scanner_transportUsb,
      MeshCoreTransportKind.tcp => l10n.scanner_transportNetwork,
      null => null,
    };
  }

  Future<void> _startDemo(
    BuildContext context,
    MeshCoreConnector connector,
  ) async {
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.science_outlined),
        title: Text(context.l10n.demo_startTitle),
        content: Text(context.l10n.demo_startMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.demo_start),
          ),
        ],
      ),
    );
    if (start == true) await connector.enterDemoMode();
  }

  Future<void> _showProfileMenu(
    BuildContext context,
    ConnectionProfile profile,
  ) async {
    final l10n = context.l10n;
    final profileService = context.read<ConnectionProfileService>();

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.autorenew),
              title: Text(l10n.scanner_autoConnect),
              subtitle: Text(l10n.scanner_autoConnectSubtitle),
              value: profile.autoConnect,
              onChanged: (value) {
                unawaited(profileService.setAutoConnect(profile.id, value));
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.scanner_editConnection),
              onTap: () {
                Navigator.pop(sheetContext);
                unawaited(_editProfile(context, profile));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.scanner_deleteConnection),
              onTap: () {
                Navigator.pop(sheetContext);
                unawaited(_confirmDelete(context, profile));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ConnectionProfile profile,
  ) async {
    final l10n = context.l10n;
    final profileService = context.read<ConnectionProfileService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.scanner_deleteConnection),
        content: Text(l10n.scanner_deleteConnectionConfirm(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.scanner_deleteConnection),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await profileService.removeProfile(profile.id);
    }
  }

  /// Offers to save a discovered device as a named profile.
  Future<void> _editProfileForDevice(
    BuildContext context,
    MeshCoreDevice device,
  ) async {
    final profileService = context.read<ConnectionProfileService>();
    final existing = profileService.profileForDevice(device);
    await _editProfile(
      context,
      existing ??
          ConnectionProfile(
            id: '${device.transportKind.name}:${device.id}',
            name: device.displayName,
            transportKind: device.transportKind,
            address: device.id,
          ),
      addressEditable: false,
    );
  }

  /// Creates or edits a profile. A null [profile] starts a new network device,
  /// which is the only kind that can be typed in by hand.
  Future<void> _editProfile(
    BuildContext context,
    ConnectionProfile? profile, {
    bool addressEditable = true,
  }) async {
    final l10n = context.l10n;
    final profileService = context.read<ConnectionProfileService>();
    final isNew = profile == null;
    final kind = profile?.transportKind ?? MeshCoreTransportKind.tcp;

    final nameController = TextEditingController(text: profile?.name ?? '');
    final addressController = TextEditingController(
      text: profile?.address ?? '',
    );
    var autoConnect = profile?.autoConnect ?? false;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            isNew ? l10n.scanner_addNetworkDevice : l10n.scanner_editConnection,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.scanner_profileName,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.scanner_profileNameRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  enabled: addressEditable,
                  decoration: InputDecoration(
                    labelText: l10n.scanner_networkAddress,
                    hintText: kind == MeshCoreTransportKind.tcp
                        ? l10n.scanner_networkAddressHint
                        : null,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return l10n.scanner_networkAddressInvalid;
                    }
                    if (kind == MeshCoreTransportKind.tcp &&
                        parseTcpEndpoint(text) == null) {
                      return l10n.scanner_networkAddressInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.scanner_autoConnect),
                  subtitle: Text(
                    l10n.scanner_autoConnectSubtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: autoConnect,
                  onChanged: (value) =>
                      setDialogState(() => autoConnect = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.common_save),
            ),
          ],
        ),
      ),
    );

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    nameController.dispose();
    addressController.dispose();

    if (saved != true) return;

    await profileService.saveProfile(
      (profile ??
              ConnectionProfile(
                id: '${kind.name}:$address',
                name: name,
                transportKind: kind,
                address: address,
              ))
          .copyWith(name: name, address: address, autoConnect: autoConnect),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.scanner_savedConnection(name))));
  }

  Future<void> _connectToDevice(
    BuildContext context,
    MeshCoreConnector connector,
    MeshCoreDevice device,
  ) async {
    final profileService = context.read<ConnectionProfileService>();
    try {
      await connector.connect(device, displayName: device.displayName);
      await profileService.recordConnection(device);
      if (!context.mounted) return;
      if (connector.backgroundKeepAliveFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.scanner_backgroundBleMayDrop)),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      final message = context.l10n.scanner_connectionFailed(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _bluetoothOffWarning(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: errorColor.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(Icons.bluetooth_disabled, size: 24, color: errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.scanner_bluetoothOff,
                  style: TextStyle(
                    color: errorColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.scanner_bluetoothOffMessage,
                  style: TextStyle(
                    color: errorColor.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!kIsWeb && Platform.isAndroid)
            TextButton(
              onPressed: () => FlutterBluePlus.turnOn(),
              child: Text(context.l10n.scanner_enableBluetooth),
            ),
        ],
      ),
    );
  }
}
