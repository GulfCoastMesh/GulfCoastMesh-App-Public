import 'legacy_map_marker.dart';
import 'tactical_map_payload.dart';

enum ChannelStructuredMessageKind {
  tacticalPosition,
  tacticalPoi,
  legacyPoi,
  gif,
  plain,
}

class PoiPreview {
  final double lat;
  final double lon;
  final String label;
  final String? tacticalType;

  const PoiPreview({
    required this.lat,
    required this.lon,
    required this.label,
    this.tacticalType,
  });
}

class ChannelMessagePreview {
  ChannelMessagePreview._();

  static final RegExp _gifPattern = RegExp(r'^g:([A-Za-z0-9_-]+)$');

  static ChannelStructuredMessageKind classify(String text) {
    final trimmed = text.trim();

    final tactical = TacticalMapPayload.tryParse(trimmed);
    if (tactical is TacticalPositionUpdate) {
      return ChannelStructuredMessageKind.tacticalPosition;
    }
    if (tactical is TacticalPoiMarker) {
      return ChannelStructuredMessageKind.tacticalPoi;
    }

    if (LegacyMapMarker.tryParse(trimmed) != null) {
      return ChannelStructuredMessageKind.legacyPoi;
    }

    if (_gifPattern.hasMatch(trimmed)) {
      return ChannelStructuredMessageKind.gif;
    }

    return ChannelStructuredMessageKind.plain;
  }

  static bool isTacticalPosition(String text) {
    return classify(text) == ChannelStructuredMessageKind.tacticalPosition;
  }

  static bool shouldNotify(String text) {
    return classify(text) != ChannelStructuredMessageKind.tacticalPosition;
  }

  static PoiPreview? parsePoi(String text) {
    final trimmed = text.trim();

    final legacy = LegacyMapMarker.tryParse(trimmed);
    if (legacy != null) {
      return PoiPreview(lat: legacy.lat, lon: legacy.lon, label: legacy.label);
    }

    final tactical = TacticalMapPayload.tryParse(trimmed);
    if (tactical is TacticalPoiMarker) {
      return PoiPreview(
        lat: tactical.lat,
        lon: tactical.lon,
        label: tactical.label,
        tacticalType: tactical.type,
      );
    }

    return null;
  }

  static String? parseGifId(String text) {
    final match = _gifPattern.firstMatch(text.trim());
    return match?.group(1);
  }
}
