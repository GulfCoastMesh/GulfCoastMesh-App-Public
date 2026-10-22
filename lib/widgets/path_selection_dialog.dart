import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';

class PathSelectionDialog extends StatefulWidget {
  final List<Contact> availableContacts;
  final String title;
  final String? initialPath;
  final String? currentPathLabel;
  final VoidCallback? onRefresh;
  final int hashSizeBytes;

  const PathSelectionDialog({
    super.key,
    required this.availableContacts,
    required this.title,
    this.initialPath,
    this.currentPathLabel,
    this.onRefresh,
    this.hashSizeBytes = pathHashSize,
  });

  @override
  State<PathSelectionDialog> createState() => _PathSelectionDialogState();

  static Future<Uint8List?> show(
    BuildContext context, {
    required List<Contact> availableContacts,
    String? title,
    String? initialPath,
    String? currentPathLabel,
    VoidCallback? onRefresh,
    int hashSizeBytes = pathHashSize,
  }) {
    return showDialog<Uint8List?>(
      context: context,
      builder: (context) => PathSelectionDialog(
        availableContacts: availableContacts,
        title: title ?? context.l10n.path_enterCustomPath,
        initialPath: initialPath,
        currentPathLabel: currentPathLabel,
        onRefresh: onRefresh,
        hashSizeBytes: hashSizeBytes,
      ),
    );
  }
}

class _PathSelectionDialogState extends State<PathSelectionDialog> {
  late TextEditingController _controller;
  final List<Contact> _selectedContacts = [];
  List<Contact> _validContacts = [];

  int get _hexCharsPerHop => widget.hashSizeBytes * 2;

  int get _maxHops {
    switch (widget.hashSizeBytes) {
      case 3:
        return 21;
      case 2:
        return 32;
      default:
        return 64;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPath ?? '');
    _filterValidContacts();
  }

  @override
  void didUpdateWidget(PathSelectionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.availableContacts != oldWidget.availableContacts) {
      _filterValidContacts();
    }
  }

  void _filterValidContacts() {
    _validContacts = widget.availableContacts
        .where((c) => c.type == 2 || c.type == 3)
        .toList();
  }

  String _prefixForContact(Contact contact) {
    final hexLen = _hexCharsPerHop.clamp(2, contact.publicKeyHex.length);
    return contact.publicKeyHex.substring(0, hexLen);
  }

  void _updateTextFromContacts() {
    final pathParts = _selectedContacts
        .map(_prefixForContact)
        .where((s) => s.isNotEmpty)
        .toList();

    _controller.text = pathParts.join(',');
  }

  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
      _updateTextFromContacts();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedContacts.clear();
      _controller.clear();
    });
  }

  Future<void> _validateAndSubmit() async {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final path = _controller.text.trim().toUpperCase();
    if (path.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final pathIds = path
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final pathBytesList = <int>[];
    final invalidPrefixes = <String>[];

    for (final id in pathIds) {
      if (id.length != _hexCharsPerHop || id.length % 2 != 0) {
        invalidPrefixes.add(id);
        continue;
      }

      try {
        for (var i = 0; i < id.length; i += 2) {
          pathBytesList.add(int.parse(id.substring(i, i + 2), radix: 16));
        }
      } catch (e) {
        invalidPrefixes.add(id);
      }
    }

    if (!mounted) return;

    if (invalidPrefixes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.path_invalidHexPrefixes(invalidPrefixes.join(", ")),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final hopCount = pathBytesList.length ~/ widget.hashSizeBytes;
    if (hopCount > _maxHops) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.path_tooLong),
          duration: const Duration(seconds: 3),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (pathBytesList.isNotEmpty && mounted) {
      Navigator.pop(context, Uint8List.fromList(pathBytesList));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final example = widget.hashSizeBytes == 1
        ? l10n.path_hexPrefixExample
        : widget.hashSizeBytes == 2
        ? 'ABCD,EF01,2345'
        : 'ABCDEF,123456';
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.currentPathLabel != null) ...[
                Row(
                  children: [
                    Text(
                      l10n.path_currentPathLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.onRefresh != null)
                      TextButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(l10n.common_reload),
                      ),
                  ],
                ),
                Text(
                  widget.currentPathLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                l10n.path_hexPrefixInstructions,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                example,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: l10n.path_labelHexPrefixes,
                  hintText: example,
                  border: const OutlineInputBorder(),
                  helperText: l10n.path_helperMaxHops,
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: _maxHops * _hexCharsPerHop + (_maxHops - 1),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    l10n.path_selectFromContacts,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedContacts.isNotEmpty)
                    TextButton(
                      onPressed: _clearSelection,
                      child: Text(l10n.common_clear),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_validContacts.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.path_noRepeatersFound,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.path_customPathsRequire,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _validContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _validContacts[index];
                      final isSelected = _selectedContacts.contains(contact);
                      final prefix = _prefixForContact(contact);

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected
                              ? colorScheme.tertiary
                              : (contact.type == 2
                                    ? colorScheme.primary
                                    // Colors.purple: room-type contact badge,
                                    // not a themed semantic role.
                                    : Colors.purple),
                          child: Icon(
                            contact.type == 2
                                ? Icons.router
                                : Icons.meeting_room,
                            size: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        title: Text(
                          contact.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          '${contact.typeLabel} • $prefix',
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: colorScheme.tertiary,
                              )
                            : const Icon(Icons.add_circle_outline),
                        onTap: () => _toggleContact(contact),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: _validateAndSubmit,
          child: Text(l10n.path_setPath),
        ),
      ],
    );
  }
}
