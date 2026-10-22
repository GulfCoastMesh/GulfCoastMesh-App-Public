import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../widgets/snr_indicator.dart';

const Duration _scanWindow = Duration(seconds: 12);

/// Standalone active discovery tool: broadcasts a zero-hop DISCOVER_REQ and
/// lists any repeaters/rooms that reply, independent of contacts or login.
/// Mirrors the official MeshCore app's "Discover Nearby Nodes" tool.
class DiscoverNodesScreen extends StatefulWidget {
  const DiscoverNodesScreen({super.key});

  @override
  State<DiscoverNodesScreen> createState() => _DiscoverNodesScreenState();
}

class _DiscoverNodesScreenState extends State<DiscoverNodesScreen> {
  final Map<String, DiscoverResponse> _discoveries = {};
  final Map<String, DateTime> _lastSeen = {};
  StreamSubscription<Uint8List>? _frameSubscription;
  Timer? _scanTimer;
  int? _currentTag;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    _frameSubscription = connector.receivedFrames.listen(_onFrame);
  }

  void _onFrame(Uint8List frame) {
    final tag = _currentTag;
    if (tag == null || frame.isEmpty || frame[0] != pushCodeControlData) {
      return;
    }
    final response = parseDiscoverResponseFrame(frame);
    if (response == null || _tagToInt(response.tag) != tag) return;

    setState(() {
      final existing = _discoveries[response.pubkeyHex];
      if (existing == null || response.localSnr >= existing.localSnr) {
        _discoveries[response.pubkeyHex] = response;
      }
      _lastSeen[response.pubkeyHex] = DateTime.now();
    });
  }

  int _tagToInt(Uint8List tag) =>
      tag[0] | (tag[1] << 8) | (tag[2] << 16) | (tag[3] << 24);

  Future<void> _startScan() async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final tag = DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF;
    setState(() {
      _isScanning = true;
      _currentTag = tag;
    });
    await connector.sendFrame(buildSendDiscoverReqFrame(tag: tag));
    _scanTimer?.cancel();
    _scanTimer = Timer(_scanWindow, () {
      if (!mounted) return;
      setState(() => _isScanning = false);
    });
  }

  void _clearResults() {
    setState(() {
      _discoveries.clear();
      _lastSeen.clear();
    });
  }

  String _fmtAgo(DateTime since) {
    final diff = DateTime.now().difference(since);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }

  @override
  void dispose() {
    _frameSubscription?.cancel();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connector = context.watch<MeshCoreConnector>();
    final results = _discoveries.values.toList()
      ..sort((a, b) => b.localSnr.compareTo(a.localSnr));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discoverNodes_title),
        actions: [
          if (_discoveries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: l10n.discoverNodes_clearList,
              onPressed: _clearResults,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.discoverNodes_description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.travel_explore),
                  label: Text(
                    _isScanning
                        ? l10n.discoverNodes_scanning
                        : l10n.discoverNodes_scan,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.discoverNodes_resultsCount(results.length),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        l10n.discoverNodes_noResults,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _buildResultTile(context, connector, results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(
    BuildContext context,
    MeshCoreConnector connector,
    DiscoverResponse response,
  ) {
    final l10n = context.l10n;
    final contact = connector.contacts
        .where((c) => c.publicKeyHex == response.pubkeyHex)
        .firstOrNull;
    final name =
        contact?.displayName ??
        l10n.discoverNodes_unknownNode(response.pubkeyHex.substring(0, 8));
    final lastSeen = _lastSeen[response.pubkeyHex];
    final snrUi = snrUiFromSNR(context, response.localSnr, connector.currentSf);

    return ListTile(
      leading: Icon(
        response.nodeType == discoverNodeTypeRoom
            ? Icons.forum
            : Icons.cell_tower,
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        [
          response.nodeTypeName,
          if (lastSeen != null)
            l10n.discoverNodes_lastSeenAgo(_fmtAgo(lastSeen)),
          l10n.discoverNodes_remoteSnr(response.remoteSnr.toStringAsFixed(1)),
        ].join(' · '),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(snrUi.icon, color: snrUi.color, size: 18),
          Text(snrUi.text, style: TextStyle(fontSize: 10, color: snrUi.color)),
        ],
      ),
    );
  }
}
