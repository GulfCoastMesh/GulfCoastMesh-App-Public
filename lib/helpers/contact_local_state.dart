import 'dart:typed_data';

import '../models/contact.dart';

/// App-local contact fields that the device contact list does not own.
///
/// Survives full contact sync clears so favorites, path overrides, and
/// first-seen timestamps are not wiped when reconnecting.
class ContactLocalState {
  final bool isFavorite;
  final int? pathOverride;
  final Uint8List? pathOverrideBytes;
  final DateTime? firstSeenAt;
  final String? nickname;

  const ContactLocalState({
    required this.isFavorite,
    this.pathOverride,
    this.pathOverrideBytes,
    this.firstSeenAt,
    this.nickname,
  });

  factory ContactLocalState.fromContact(Contact contact) {
    return ContactLocalState(
      isFavorite: contact.isFavorite,
      pathOverride: contact.pathOverride,
      pathOverrideBytes: contact.pathOverrideBytes == null
          ? null
          : Uint8List.fromList(contact.pathOverrideBytes!),
      firstSeenAt: contact.firstSeenAt,
      nickname: contact.nickname,
    );
  }
}

/// Prefer in-memory [existing] local fields when present, otherwise [local].
Contact mergeContactLocalFields(
  Contact device, {
  Contact? existing,
  ContactLocalState? local,
}) {
  final isFavorite = existing?.isFavorite ?? local?.isFavorite ?? false;
  final nickname = existing != null ? existing.nickname : local?.nickname;
  final pathOverride = existing != null
      ? existing.pathOverride
      : local?.pathOverride;
  final pathOverrideBytes = existing != null
      ? existing.pathOverrideBytes
      : local?.pathOverrideBytes;
  final firstSeenAt =
      existing?.firstSeenAt ?? local?.firstSeenAt ?? DateTime.now();
  final lastMessageAt =
      existing != null && existing.lastMessageAt.isAfter(device.lastMessageAt)
      ? existing.lastMessageAt
      : device.lastMessageAt;

  final hasLocalPathSource = existing != null || local != null;
  final hasLocalNicknameSource = existing != null || local != null;
  return device.copyWith(
    isFavorite: isFavorite,
    pathOverride: pathOverride,
    pathOverrideBytes: pathOverrideBytes,
    clearPathOverride: pathOverride == null && hasLocalPathSource,
    firstSeenAt: firstSeenAt,
    lastMessageAt: lastMessageAt,
    nickname: nickname,
    clearNickname: nickname == null && hasLocalNicknameSource,
  );
}
