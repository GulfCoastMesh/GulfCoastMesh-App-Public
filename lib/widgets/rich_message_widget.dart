import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/rich_message.dart';
import '../services/rich_link_preview_service.dart';

/// Material renderer for a locally parsed [RichMessage].
///
/// The source text is still rendered as text; this widget only decorates
/// recognized spans and reports interactions through callbacks. It does not
/// launch URLs, navigate to a map, or mutate contacts on its own.
class RichMessageWidget extends StatefulWidget {
  final RichMessage message;
  final TextStyle? style;
  final TextAlign textAlign;
  final Color? accentColor;
  final ValueChanged<RichMessageToken>? onTokenTap;
  final ValueChanged<RichMentionToken>? onMentionTap;
  final ValueChanged<RichHashtagToken>? onHashtagTap;
  final ValueChanged<Uri>? onUrlTap;
  final ValueChanged<RichContactShareToken>? onContactShareTap;
  final ValueChanged<RichCoordinateToken>? onCoordinateTap;
  final RichLinkPreviewService? previewService;
  final bool showLinkPreviews;
  final bool linkPreviewsEnabled;
  final bool online;
  final double previewImageHeight;

  const RichMessageWidget({
    super.key,
    required this.message,
    this.style,
    this.textAlign = TextAlign.start,
    this.accentColor,
    this.onTokenTap,
    this.onMentionTap,
    this.onHashtagTap,
    this.onUrlTap,
    this.onContactShareTap,
    this.onCoordinateTap,
    this.previewService,
    this.showLinkPreviews = false,
    this.linkPreviewsEnabled = true,
    this.online = true,
    this.previewImageHeight = 120,
  });

  @override
  State<RichMessageWidget> createState() => _RichMessageWidgetState();
}

class _RichMessageWidgetState extends State<RichMessageWidget> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];
  final Map<String, Future<RichLinkPreview?>> _previewRequests =
      <String, Future<RichLinkPreview?>>{};

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final theme = Theme.of(context);
    final baseStyle = widget.style ?? theme.textTheme.bodyMedium;
    final accent = widget.accentColor ?? theme.colorScheme.primary;
    final spans = widget.message.tokens
        .map((token) => _spanFor(token, baseStyle, accent))
        .toList(growable: false);

    final content = <Widget>[
      Text.rich(
        TextSpan(style: baseStyle, children: spans),
        textAlign: widget.textAlign,
      ),
    ];
    if (widget.showLinkPreviews &&
        widget.linkPreviewsEnabled &&
        widget.previewService != null) {
      for (final token in widget.message.tokens.whereType<RichUrlToken>()) {
        if (token.isInferred) continue;
        content.add(_previewFor(token.uri, accent));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: content,
    );
  }

  TextSpan _spanFor(
    RichMessageToken token,
    TextStyle? baseStyle,
    Color accent,
  ) {
    final linkStyle = baseStyle?.copyWith(
      color: accent,
      decoration: TextDecoration.underline,
      decorationColor: accent.withValues(alpha: 0.65),
    );
    final emphasizedStyle = baseStyle?.copyWith(
      color: accent,
      fontWeight: FontWeight.w600,
    );
    final quoteStyle = baseStyle?.copyWith(
      color: (baseStyle.color ?? Theme.of(context).colorScheme.onSurface)
          .withValues(alpha: 0.72),
      fontStyle: FontStyle.italic,
    );

    switch (token) {
      case RichPlainTextToken():
        return TextSpan(text: token.raw);
      case RichMentionToken():
        return _interactiveSpan(token, emphasizedStyle, () {
          widget.onMentionTap?.call(token);
        });
      case RichReplyQuoteToken():
        return _interactiveSpan(token, quoteStyle, () {});
      case RichContactShareToken():
        return _interactiveSpan(token, emphasizedStyle, () {
          widget.onContactShareTap?.call(token);
        });
      case RichHashtagToken():
        return _interactiveSpan(token, emphasizedStyle, () {
          widget.onHashtagTap?.call(token);
        });
      case RichUrlToken():
        return _interactiveSpan(token, linkStyle, () {
          widget.onUrlTap?.call(token.uri);
        });
      case RichMeshcoreUrlToken():
        return _interactiveSpan(token, linkStyle, () {
          widget.onUrlTap?.call(token.uri);
        });
      case RichCoordinateToken():
        return _interactiveSpan(token, emphasizedStyle, () {
          widget.onCoordinateTap?.call(token);
        });
    }
  }

  TextSpan _interactiveSpan(
    RichMessageToken token,
    TextStyle? style,
    VoidCallback specializedCallback,
  ) {
    final hasSpecializedCallback = switch (token) {
      RichMentionToken() => widget.onMentionTap != null,
      RichContactShareToken() => widget.onContactShareTap != null,
      RichHashtagToken() => widget.onHashtagTap != null,
      RichUrlToken() || RichMeshcoreUrlToken() => widget.onUrlTap != null,
      RichCoordinateToken() => widget.onCoordinateTap != null,
      RichReplyQuoteToken() => false,
      RichPlainTextToken() => false,
    };
    final canTap = widget.onTokenTap != null || hasSpecializedCallback;
    if (!canTap) return TextSpan(text: token.raw, style: style);

    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        widget.onTokenTap?.call(token);
        if (hasSpecializedCallback) specializedCallback();
      };
    _recognizers.add(recognizer);
    return TextSpan(text: token.raw, style: style, recognizer: recognizer);
  }

  Widget _previewFor(Uri uri, Color accent) {
    final service = widget.previewService!;
    final key = uri.toString();
    final future = _previewRequests.putIfAbsent(
      key,
      () => service.fetch(
        uri,
        enabledOverride: widget.linkPreviewsEnabled,
        onlineOverride: widget.online,
      ),
    );
    return FutureBuilder<RichLinkPreview?>(
      key: ValueKey<String>('rich-preview:$key'),
      future: future,
      builder: (context, snapshot) {
        final preview = snapshot.data;
        if (preview == null) return const SizedBox.shrink();
        return _RichLinkPreviewCard(
          preview: preview,
          accentColor: accent,
          imageHeight: widget.previewImageHeight,
          onTap: () => widget.onUrlTap?.call(uri),
        );
      },
    );
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}

class _RichLinkPreviewCard extends StatelessWidget {
  final RichLinkPreview preview;
  final Color accentColor;
  final double imageHeight;
  final VoidCallback? onTap;

  const _RichLinkPreviewCard({
    required this.preview,
    required this.accentColor,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = preview.imageUri;
    final card = Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            CachedNetworkImage(
              imageUrl: image.toString(),
              height: imageHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox(
                height: 72,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (preview.title != null)
                  Text(
                    preview.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                if (preview.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    preview.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  preview.uri.host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: accentColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return onTap == null ? card : InkWell(onTap: onTap, child: card);
  }
}

/// Short alias for call sites that prefer a view-oriented name.
typedef RichMessageView = RichMessageWidget;
