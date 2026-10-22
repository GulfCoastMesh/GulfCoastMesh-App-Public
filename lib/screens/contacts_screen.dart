import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/screens/path_trace_map.dart';
import 'package:gulf_coast_mesh_app/utils/app_logger.dart';
import 'package:gulf_coast_mesh_app/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/contact_advert_uri.dart';
import '../helpers/list_filters.dart';
import '../l10n/l10n.dart';
import '../connector/meshcore_protocol.dart';
import '../models/contact.dart';
import '../models/contact_group.dart';
import '../services/app_settings_service.dart';
import '../storage/contact_group_store.dart';
import '../theme/app_colors.dart';
import '../utils/contact_search.dart';
import '../utils/disconnect_navigation_mixin.dart';
import '../utils/emoji_utils.dart';
import '../widgets/block_node_dialog.dart';
import '../widgets/connection_overflow_menu_button.dart';
import '../widgets/list_filter_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import '../widgets/notification_target_marker.dart';
import '../widgets/repeater_login_dialog.dart';
import '../widgets/room_login_dialog.dart';
import '../widgets/unread_badge.dart';
import 'chat_screen.dart';
import 'contact_qr_scanner_screen.dart';
import 'map_screen.dart';
import 'my_contact_qr_screen.dart';
import 'repeater_hub_screen.dart';

enum RoomLoginDestination { chat, management }

enum ContactOperationType { import, export, zeroHopShare }

class ContactsScreen extends StatefulWidget {
  final bool hideBackButton;
  final String? selectedContactKey;
  final ValueChanged<Contact>? onSelected;
  final bool hideScaffold;

  const ContactsScreen({
    super.key,
    this.hideBackButton = false,
    this.selectedContactKey,
    this.onSelected,
    this.hideScaffold = false,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with DisconnectNavigationMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ContactSortOption _sortOption = ContactSortOption.lastSeen;
  bool _showUnreadOnly = false;
  NodeCategoryFilter _categoryFilter = NodeCategoryFilter.contacts;
  bool _filterLoaded = false;
  final ContactGroupStore _groupStore = ContactGroupStore();
  List<ContactGroup> _groups = [];
  Timer? _searchDebounce;

  final Set<ContactOperationType> _pendingOperations = {};

  StreamSubscription<Uint8List>? _frameSubscription;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _setupFrameListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_filterLoaded) {
      final settings = context.read<AppSettingsService>().settings;
      _categoryFilter = nodeCategoryFilterFromString(
        settings.nodeCategoryFilter,
      );
      _filterLoaded = true;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _frameSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setCategoryFilter(NodeCategoryFilter filter) async {
    setState(() => _categoryFilter = filter);
    await context.read<AppSettingsService>().setNodeCategoryFilter(
      nodeCategoryFilterToString(filter),
    );
  }

  Future<void> _loadGroups() async {
    final groups = await _groupStore.loadGroups();
    if (!mounted) return;
    setState(() {
      _groups = groups;
    });
  }

  Future<void> _saveGroups() async {
    await _groupStore.saveGroups(_groups);
  }

  void _setupFrameListener() {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    // Listen for incoming text messages from the repeater
    _frameSubscription = connector.receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      final frameBuffer = BufferReader(frame);
      try {
        final code = frameBuffer.readUInt8();

        if (code == respCodeExportContact) {
          final advertPacket = frameBuffer.readRemainingBytes();
          // Validate packet has expected minimum size (98+ bytes per protocol)
          if (advertPacket.length < 98) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.contacts_invalidAdvertFormat),
                ),
              );
            }
            _pendingOperations.remove(ContactOperationType.export);
            return;
          }
          final hexString = pubKeyToHex(advertPacket);
          Clipboard.setData(ClipboardData(text: "meshcore://$hexString"));
        }

        if (code == respCodeOk) {
          // Show a snackbar indicating success
          if (!mounted) return;

          if (_pendingOperations.contains(ContactOperationType.import)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.contacts_contactImported)),
            );
          }

          if (_pendingOperations.contains(ContactOperationType.zeroHopShare)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.contacts_zeroHopContactAdvertSent),
              ),
            );
          }

          if (_pendingOperations.contains(ContactOperationType.export)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.contacts_contactAdvertCopied),
              ),
            );
          }

          _pendingOperations.clear();
        }

        if (code == respCodeErr) {
          // Show a snackbar indicating failure
          if (!mounted) return;

          if (_pendingOperations.contains(ContactOperationType.import)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.contacts_contactImportFailed),
              ),
            );
          }

          if (_pendingOperations.contains(ContactOperationType.zeroHopShare)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.contacts_zeroHopContactAdvertFailed),
              ),
            );
          }
          if (_pendingOperations.contains(ContactOperationType.export)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.contacts_contactAdvertCopyFailed),
              ),
            );
          }

          _pendingOperations.clear();
        }
      } catch (e) {
        appLogger.error(
          'Error processing received frame: $e',
          tag: 'ContactsScreen',
        );
      }
    });
  }

  Future<void> _contactExport(Uint8List pubKey) async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final exportContactFrame = buildExportContactFrame(pubKey);
    _pendingOperations.add(ContactOperationType.export);
    await connector.sendFrame(exportContactFrame, expectsGenericAck: true);
  }

  Future<void> _contactZeroHop(Uint8List pubKey) async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final exportContactZeroHopFrame = buildZeroHopContact(pubKey);
    _pendingOperations.add(ContactOperationType.zeroHopShare);
    await connector.sendFrame(
      exportContactZeroHopFrame,
      expectsGenericAck: true,
    );
  }

  Future<void> _contactImport() async {
    final connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null || clipboardData.text == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.contacts_clipboardEmpty)),
        );
      }
      return;
    }
    final text = clipboardData.text!.trim();
    final hexString = ContactAdvertUri.contactHexFromUri(text);
    if (hexString == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.contacts_invalidAdvertFormat)),
        );
      }
      return;
    }
    try {
      final importContactFrame = buildImportContactFrame(hexString);
      _pendingOperations.add(ContactOperationType.import);
      await connector.sendFrame(importContactFrame, expectsGenericAck: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.contacts_invalidAdvertFormat)),
        );
      }
    }
  }

  Future<void> _openContactQrScanner(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ContactQrScannerScreen()),
    );
    if (result == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.contacts_contactImported)),
    );
  }

  void _openMyContactQr(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyContactQrScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    // The connector notifies on block-list changes; the switch lives here.
    context.watch<AppSettingsService>();

    // Auto-navigate back to scanner if disconnected
    if (!checkConnectionAndNavigate(connector)) {
      return const SizedBox.shrink();
    }

    final body = _buildContactsBody(context, connector);
    if (widget.hideScaffold) return body;

    final allowBack = !widget.hideBackButton;
    final page = PopScope(
      canPop: allowBack,
      child: Scaffold(
        appBar: AppBar(
          title: AppBarTitle(context.l10n.contacts_title),
          automaticallyImplyLeading: false,
          leading: allowBack ? const BackButton() : null,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.connect_without_contact),
                      const SizedBox(width: 8),
                      Text(context.l10n.contacts_zeroHopAdvert),
                    ],
                  ),
                  onTap: () => _sendAdvert(context, connector, flood: false),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.cell_tower),
                      const SizedBox(width: 8),
                      Text(context.l10n.contacts_floodAdvert),
                    ],
                  ),
                  onTap: () => _sendAdvert(context, connector, flood: true),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.copy),
                      const SizedBox(width: 8),
                      Text(context.l10n.contacts_copyAdvertToClipboard),
                    ],
                  ),
                  onTap: () => _contactExport(Uint8List.fromList([])),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code),
                      const SizedBox(width: 8),
                      Text(context.l10n.contacts_showMyQrCode),
                    ],
                  ),
                  onTap: () => _openMyContactQr(context),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.paste),
                      const SizedBox(width: 8),
                      Text(context.l10n.contacts_addContactFromClipboard),
                    ],
                  ),
                  onTap: () => _contactImport(),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner),
                      const SizedBox(width: 8),
                      Text(context.l10n.contacts_addContactByScanQr),
                    ],
                  ),
                  onTap: () => _openContactQrScanner(context),
                ),
              ],
              icon: const Icon(Icons.connect_without_contact),
            ),
            const ConnectionOverflowMenuButton(),
          ],
        ),
        body: body,
      ),
    );
    // Only a pushed copy of the list is tracked. The hub's copy stays mounted
    // in the home screen's tab stack even while another tab is showing.
    return NotificationTargetMarker(
      target: allowBack ? NotificationTarget.contacts : null,
      child: page,
    );
  }

  Widget _buildFilterButton(BuildContext context, MeshCoreConnector connector) {
    return ContactsFilterMenu(
      sortOption: _sortOption,
      showUnreadOnly: _showUnreadOnly,
      onSortChanged: (value) {
        setState(() {
          _sortOption = value;
        });
      },
      onUnreadOnlyChanged: (value) {
        setState(() {
          _showUnreadOnly = value;
        });
      },
      onNewGroup: () => _showGroupEditor(context, connector.visibleContacts),
    );
  }

  Widget _buildContactsBody(BuildContext context, MeshCoreConnector connector) {
    final colorScheme = Theme.of(context).colorScheme;
    final contacts = connector.visibleContacts;
    final hasStoredContacts = connector.contacts.isNotEmpty;

    if (!hasStoredContacts && connector.isLoadingContacts && _groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasStoredContacts && _groups.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: context.l10n.contacts_noContacts,
        subtitle: context.l10n.contacts_contactsWillAppear,
      );
    }

    final filteredAndSorted = _filterAndSortContacts(contacts, connector);
    final filteredGroups = _showUnreadOnly
        ? const <ContactGroup>[]
        : _filterAndSortGroups(_groups, contacts);
    final resultCount = filteredAndSorted.length + filteredGroups.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.nodes_searchHintCount(resultCount),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  _buildFilterButton(context, connector),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              });
            },
          ),
        ),
        FilterChipRow<NodeCategoryFilter>(
          selected: _categoryFilter,
          onSelected: _setCategoryFilter,
          items: [
            FilterChipItem(
              value: NodeCategoryFilter.favorites,
              label: context.l10n.nodes_filterFavorites,
            ),
            FilterChipItem(
              value: NodeCategoryFilter.contacts,
              label: context.l10n.nodes_filterContacts,
            ),
            FilterChipItem(
              value: NodeCategoryFilter.repeaters,
              label: context.l10n.nodes_filterRepeaters,
            ),
            FilterChipItem(
              value: NodeCategoryFilter.rooms,
              label: context.l10n.nodes_filterRooms,
            ),
          ],
        ),
        Expanded(
          child: filteredAndSorted.isEmpty && filteredGroups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showUnreadOnly
                            ? context.l10n.contacts_noUnreadContacts
                            : context.l10n.contacts_noContactsFound,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      connector.refreshContactsBestEffort(tag: 'Contacts'),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredGroups.length + filteredAndSorted.length,
                    itemBuilder: (context, index) {
                      if (index < filteredGroups.length) {
                        final group = filteredGroups[index];
                        return _buildGroupTile(context, group, contacts);
                      }
                      final contact =
                          filteredAndSorted[index - filteredGroups.length];
                      final unreadCount = connector.getUnreadCountForContact(
                        contact,
                      );
                      return _ContactTile(
                        contact: contact,
                        lastSeen: _resolveLastSeen(contact),
                        unreadCount: unreadCount,
                        selected:
                            widget.selectedContactKey == contact.publicKeyHex,
                        onTap: () => _handleContactTap(context, contact),
                        onLongPress: () =>
                            _showContactOptions(context, connector, contact),
                        onToggleFavorite: () =>
                            connector.toggleContactFavorite(contact),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  List<ContactGroup> _filterAndSortGroups(
    List<ContactGroup> groups,
    List<Contact> contacts,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    final contactsByKey = <String, Contact>{};
    for (final contact in contacts) {
      contactsByKey[contact.publicKeyHex] = contact;
    }

    final filtered = groups
        .where((group) {
          if (query.isEmpty) return true;
          if (group.name.toLowerCase().contains(query)) return true;
          for (final key in group.memberKeys) {
            final contact = contactsByKey[key];
            if (contact != null && matchesContactQuery(contact, query)) {
              return true;
            }
          }
          return false;
        })
        .where((group) {
          if (_categoryFilter == NodeCategoryFilter.favorites) {
            for (final key in group.memberKeys) {
              final contact = contactsByKey[key];
              if (contact != null && contact.isFavorite) return true;
            }
            return false;
          }
          for (final key in group.memberKeys) {
            final contact = contactsByKey[key];
            if (contact != null && _matchesCategoryFilter(contact)) return true;
          }
          return false;
        })
        .toList();

    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return filtered;
  }

  List<Contact> _filterAndSortContacts(
    List<Contact> contacts,
    MeshCoreConnector connector,
  ) {
    var filtered = contacts.where((contact) {
      if (_searchQuery.isEmpty) return true;
      return matchesContactQuery(contact, _searchQuery);
    }).toList();

    // Filter out own node from the list
    if (connector.selfPublicKey != null) {
      final selfPubKeyHex = pubKeyToHex(connector.selfPublicKey!);
      filtered = filtered.where((contact) {
        return contact.publicKeyHex != selfPubKeyHex;
      }).toList();
    }

    filtered = filtered.where(_matchesCategoryFilter).toList();

    if (_showUnreadOnly) {
      filtered = filtered.where((contact) {
        return connector.getUnreadCountForContact(contact) > 0;
      }).toList();
    }

    switch (_sortOption) {
      case ContactSortOption.lastSeen:
        filtered.sort(
          (a, b) => _resolveLastSeen(b).compareTo(_resolveLastSeen(a)),
        );
        break;
      case ContactSortOption.recentMessages:
        filtered.sort((a, b) {
          final aMessages = connector.getMessages(a);
          final bMessages = connector.getMessages(b);
          final aLastMsg = aMessages.isEmpty
              ? DateTime(1970)
              : aMessages.last.timestamp;
          final bLastMsg = bMessages.isEmpty
              ? DateTime(1970)
              : bMessages.last.timestamp;
          return bLastMsg.compareTo(aLastMsg);
        });
        break;
      case ContactSortOption.name:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }

    return filtered;
  }

  bool _matchesCategoryFilter(Contact contact) {
    switch (_categoryFilter) {
      case NodeCategoryFilter.favorites:
        return contact.isFavorite;
      case NodeCategoryFilter.contacts:
        return contact.type == advTypeChat;
      case NodeCategoryFilter.repeaters:
        return contact.type == advTypeRepeater;
      case NodeCategoryFilter.rooms:
        return contact.type == advTypeRoom;
    }
  }

  DateTime _resolveLastSeen(Contact contact) {
    if (contact.type != advTypeChat) return contact.lastSeen;
    return contact.lastMessageAt.isAfter(contact.lastSeen)
        ? contact.lastMessageAt
        : contact.lastSeen;
  }

  Widget _buildGroupTile(
    BuildContext context,
    ContactGroup group,
    List<Contact> contacts,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final memberContacts = _resolveGroupContacts(group, contacts);
    final subtitle = _formatGroupMembers(context, memberContacts);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.group, color: colorScheme.onPrimary, size: 20),
      ),
      title: Text(group.name),
      subtitle: Text(subtitle),
      trailing: Text(
        memberContacts.length.toString(),
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      onTap: () => _showGroupOptions(context, group, contacts),
      onLongPress: () => _showGroupOptions(context, group, contacts),
    );
  }

  List<Contact> _resolveGroupContacts(
    ContactGroup group,
    List<Contact> contacts,
  ) {
    final byKey = <String, Contact>{};
    for (final contact in contacts) {
      byKey[contact.publicKeyHex] = contact;
    }
    final resolved = <Contact>[];
    for (final key in group.memberKeys) {
      final contact = byKey[key];
      if (contact != null) {
        resolved.add(contact);
      }
    }
    resolved.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return resolved;
  }

  String _formatGroupMembers(BuildContext context, List<Contact> members) {
    if (members.isEmpty) return context.l10n.contacts_noMembers;
    final names = members.map((c) => c.name).toList();
    if (names.length <= 2) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2}';
  }

  void _handleContactTap(BuildContext context, Contact contact) {
    if (widget.onSelected != null) {
      widget.onSelected!(contact);
      return;
    }
    _openChat(context, contact);
  }

  void _openChat(BuildContext context, Contact contact) {
    // Check if this is a repeater
    if (contact.type == advTypeRepeater) {
      _showRepeaterLogin(context, contact);
    } else if (contact.type == advTypeRoom) {
      _showRoomLogin(context, contact, RoomLoginDestination.chat);
    } else {
      context.read<MeshCoreConnector>().markContactRead(contact.publicKeyHex);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(contact: contact)),
      );
    }
  }

  void _showRepeaterLogin(BuildContext context, Contact repeater) {
    RepeaterLoginDialog.show(
      context,
      repeater: repeater,
      onLogin: (password) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RepeaterHubScreen(repeater: repeater, password: password),
          ),
        );
      },
    );
  }

  Future<void> _sendAdvert(
    BuildContext context,
    MeshCoreConnector connector, {
    required bool flood,
  }) async {
    try {
      await connector.sendSelfAdvert(flood: flood);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settings_advertisementSent)),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settings_error(error.toString()))),
      );
    }
  }

  void _showRoomLogin(
    BuildContext context,
    Contact room,
    RoomLoginDestination destination,
  ) {
    showDialog(
      context: context,
      builder: (context) => RoomLoginDialog(
        room: room,
        onLogin: (password) {
          context.read<MeshCoreConnector>().markContactRead(room.publicKeyHex);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  destination == RoomLoginDestination.management
                  ? RepeaterHubScreen(repeater: room, password: password)
                  : ChatScreen(contact: room),
            ),
          );
        },
      ),
    );
  }

  void _showGroupOptions(
    BuildContext context,
    ContactGroup group,
    List<Contact> contacts,
  ) {
    final members = _resolveGroupContacts(group, contacts);
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(context.l10n.contacts_editGroup),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showGroupEditor(context, contacts, group: group);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: colorScheme.error),
                title: Text(
                  context.l10n.contacts_deleteGroup,
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDeleteGroup(context, group);
                },
              ),
              if (members.isNotEmpty) const Divider(),
              ...members.map((member) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(member.name),
                  subtitle: Text(member.typeLabel),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openChat(context, member);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, ContactGroup group) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.contacts_deleteGroup),
        content: Text(context.l10n.contacts_deleteGroupConfirm(group.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() {
                _groups.removeWhere((g) => g.name == group.name);
              });
              await _saveGroups();
            },
            child: Text(
              context.l10n.common_delete,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupEditor(
    BuildContext context,
    List<Contact> contacts, {
    ContactGroup? group,
  }) {
    final isEditing = group != null;
    final nameController = TextEditingController(text: group?.name ?? '');
    final selectedKeys = <String>{...group?.memberKeys ?? []};
    String filterQuery = '';
    final sortedContacts = List<Contact>.from(contacts)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) {
          final filteredContacts = filterQuery.isEmpty
              ? sortedContacts
              : sortedContacts
                    .where(
                      (contact) => matchesContactQuery(contact, filterQuery),
                    )
                    .toList();
          return AlertDialog(
            title: Text(
              isEditing
                  ? context.l10n.contacts_editGroup
                  : context.l10n.contacts_newGroup,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.contacts_groupName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: context.l10n.contacts_filterContacts,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        filterQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: filteredContacts.isEmpty
                        ? Center(
                            child: Text(
                              context.l10n.contacts_noContactsMatchFilter,
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              final isSelected = selectedKeys.contains(
                                contact.publicKeyHex,
                              );
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(contact.displayName),
                                subtitle: Text(contact.typeLabel),
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      selectedKeys.add(contact.publicKeyHex);
                                    } else {
                                      selectedKeys.remove(contact.publicKeyHex);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.common_cancel),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.contacts_groupNameRequired),
                      ),
                    );
                    return;
                  }
                  final exists = _groups.any((g) {
                    if (isEditing && g.name == group.name) return false;
                    return g.name.toLowerCase() == name.toLowerCase();
                  });
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.contacts_groupAlreadyExists(name),
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    if (isEditing) {
                      final index = _groups.indexWhere(
                        (g) => g.name == group.name,
                      );
                      if (index != -1) {
                        _groups[index] = ContactGroup(
                          name: name,
                          memberKeys: selectedKeys.toList(),
                        );
                      }
                    } else {
                      _groups.add(
                        ContactGroup(
                          name: name,
                          memberKeys: selectedKeys.toList(),
                        ),
                      );
                    }
                  });
                  await _saveGroups();
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(
                  isEditing
                      ? context.l10n.common_save
                      : context.l10n.common_create,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showContactOptions(
    BuildContext context,
    MeshCoreConnector connector,
    Contact contact,
  ) {
    final isRepeater = contact.type == advTypeRepeater;
    final isRoom = contact.type == advTypeRoom;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRepeater) ...[
              ListTile(
                leading: Icon(Icons.radar, color: colorScheme.tertiary),
                title: contact.pathLength > 0
                    ? Text(context.l10n.contacts_pathTrace)
                    : Text(context.l10n.contacts_ping),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PathTraceMapScreen(
                        title: contact.pathLength > 0
                            ? context.l10n.contacts_repeaterPathTrace
                            : context.l10n.contacts_repeaterPing,
                        path: contact.traceRouteBytes ?? Uint8List(0),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.cell_tower, color: colorScheme.tertiary),
                title: Text(context.l10n.contacts_manageRepeater),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showRepeaterLogin(context, contact);
                },
              ),
            ] else if (isRoom) ...[
              ListTile(
                leading: Icon(Icons.radar, color: colorScheme.tertiary),
                title: contact.pathLength > 0
                    ? Text(context.l10n.contacts_pathTrace)
                    : Text(context.l10n.contacts_ping),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PathTraceMapScreen(
                        title: contact.pathLength > 0
                            ? context.l10n.contacts_roomPathTrace
                            : context.l10n.contacts_roomPing,
                        path: contact.traceRouteBytes ?? Uint8List(0),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.room, color: colorScheme.primary),
                title: Text(context.l10n.contacts_roomLogin),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showRoomLogin(context, contact, RoomLoginDestination.chat);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.room_preferences,
                  color: colorScheme.tertiary,
                ),
                title: Text(context.l10n.room_management),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showRoomLogin(
                    context,
                    contact,
                    RoomLoginDestination.management,
                  );
                },
              ),
            ] else ...[
              if (contact.pathLength > 0)
                ListTile(
                  leading: Icon(Icons.radar, color: colorScheme.tertiary),
                  title: Text(context.l10n.contacts_chatTraceRoute),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PathTraceMapScreen(
                          title: context.l10n.contacts_pathTraceTo(
                            contact.displayName,
                          ),
                          path: contact.traceRouteBytes ?? Uint8List(0),
                        ),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: Text(context.l10n.contacts_openChat),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openChat(context, contact);
                },
              ),
            ],
            ListTile(
              leading: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: colorScheme.tertiary,
              ),
              title: Text(
                contact.isFavorite
                    ? context.l10n.contacts_removeFromFavorites
                    : context.l10n.contacts_addToFavorites,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                connector.toggleContactFavorite(contact);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(context.l10n.contacts_ShareContact),
              onTap: () {
                Navigator.pop(sheetContext);
                _contactExport(contact.publicKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.connect_without_contact),
              title: Text(context.l10n.contacts_ShareContactZeroHop),
              onTap: () {
                Navigator.pop(sheetContext);
                _contactZeroHop(contact.publicKey);
              },
            ),
            if (context
                .read<AppSettingsService>()
                .settings
                .experimentalNodeBlockingEnabled)
              ListTile(
                leading: Icon(Icons.block, color: colorScheme.error),
                title: Text(
                  context.l10n.blockedNodes_blockAction,
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  confirmBlockNode(context, contact);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: Text(
                context.l10n.contacts_deleteContact,
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, connector, contact);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    MeshCoreConnector connector,
    Contact contact,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.contacts_deleteContact),
        content: Text(context.l10n.contacts_removeConfirm(contact.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await connector.removeContact(contact);
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.settings_error(error.toString()),
                    ),
                  ),
                );
              }
            },
            child: Text(
              context.l10n.common_delete,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final Contact contact;
  final DateTime lastSeen;
  final int unreadCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;
  final bool selected;

  const _ContactTile({
    required this.contact,
    required this.lastSeen,
    required this.unreadCount,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(contact.type),
          child: _buildContactAvatar(contact),
        ),
        title: Text(
          contact.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.pathLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              contact.shortPubKeyHex,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.3),
            ),
          ),
          child: SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (contact.isNew)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          context.l10n.contacts_newBadge,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    if (unreadCount > 0) UnreadBadge(count: unreadCount),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatLastSeen(context, lastSeen),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (contact.hasLocation)
                      GestureDetector(
                        onTap: () => _openOnMap(context),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    GestureDetector(
                      onTap: onToggleFavorite,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          contact.isFavorite ? Icons.star : Icons.star_border,
                          size: 18,
                          color: contact.isFavorite
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  void _openOnMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          highlightPosition: LatLng(contact.latitude!, contact.longitude!),
          highlightLabel: contact.displayName,
        ),
      ),
    );
  }

  Widget _buildContactAvatar(Contact contact) {
    final emoji = firstEmoji(contact.displayName);
    if (emoji != null) {
      return Text(emoji, style: const TextStyle(fontSize: 18));
    }
    return Icon(
      _getTypeIcon(contact.type),
      color: AppColors.textColorForBackground(_getTypeColor(contact.type)),
      size: 20,
    );
  }

  IconData _getTypeIcon(int type) {
    switch (type) {
      case advTypeChat:
        return Icons.chat;
      case advTypeRepeater:
        return Icons.cell_tower;
      case advTypeRoom:
        return Icons.group;
      case advTypeSensor:
        return Icons.sensors;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case advTypeChat:
        return AppColors.contactChat;
      case advTypeRepeater:
        return AppColors.contactRepeater;
      case advTypeRoom:
        return AppColors.contactRoom;
      case advTypeSensor:
        return AppColors.contactSensor;
      default:
        return Colors.grey;
    }
  }

  String _formatLastSeen(BuildContext context, DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.isNegative || diff.inMinutes < 5) {
      return context.l10n.contacts_lastSeenNow;
    }
    if (diff.inMinutes < 60) {
      return context.l10n.contacts_lastSeenMinsAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return hours == 1
          ? context.l10n.contacts_lastSeenHourAgo
          : context.l10n.contacts_lastSeenHoursAgo(hours);
    }
    final days = diff.inDays;
    return days == 1
        ? context.l10n.contacts_lastSeenDayAgo
        : context.l10n.contacts_lastSeenDaysAgo(days);
  }
}
