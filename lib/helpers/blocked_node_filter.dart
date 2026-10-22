import '../models/contact.dart';

/// [contacts] without the nodes for which [isHidden] returns true.
List<Contact> withoutHiddenNodes(
  List<Contact> contacts,
  bool Function(String publicKeyHex) isHidden,
) => contacts.where((c) => !isHidden(c.publicKeyHex)).toList();

enum NodeMarkerLongPress { none, confirmBlock, removeMarker }

/// What long-pressing a node marker on the map should do.
NodeMarkerLongPress nodeMarkerLongPress({
  required bool isBuildingPathTrace,
  required bool blockingEnabled,
}) {
  if (isBuildingPathTrace) return NodeMarkerLongPress.none;
  return blockingEnabled
      ? NodeMarkerLongPress.confirmBlock
      : NodeMarkerLongPress.removeMarker;
}
