import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/app_settings_service.dart';
import '../services/storage_service.dart';
import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../utils/app_logger.dart';
import 'path_management_dialog.dart';

class RepeaterLoginDialog extends StatefulWidget {
  final Contact repeater;
  final Function(String password) onLogin;
  final String? initialPassword;
  @visibleForTesting
  final StorageService? storage;

  const RepeaterLoginDialog({
    super.key,
    required this.repeater,
    required this.onLogin,
    this.initialPassword,
    this.storage,
  });

  /// Loads a saved password before creating an editable field. This prevents a
  /// delayed secure-storage response from interrupting Android IME composition.
  static Future<void> show(
    BuildContext context, {
    required Contact repeater,
    required Function(String password) onLogin,
    @visibleForTesting StorageService? storage,
  }) async {
    final passwordStorage = storage ?? StorageService();
    String? savedPassword;
    try {
      savedPassword = await passwordStorage.getRepeaterPassword(
        repeater.publicKeyHex,
      );
    } catch (error) {
      appLogger.warn(
        'Could not load saved password for ${repeater.name}: $error',
        tag: 'RepeaterLogin',
      );
    }
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => RepeaterLoginDialog(
        repeater: repeater,
        initialPassword: savedPassword,
        storage: passwordStorage,
        onLogin: onLogin,
      ),
    );
  }

  @override
  State<RepeaterLoginDialog> createState() => _RepeaterLoginDialogState();
}

class _RepeaterLoginDialogState extends State<RepeaterLoginDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  late final StorageService _storage;
  bool _savePassword = false;
  bool _obscurePassword = true;
  String? _loginError;
  late MeshCoreConnector _connector;
  int _currentAttempt = 0;
  static const int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? StorageService();
    _connector = Provider.of<MeshCoreConnector>(context, listen: false);
    final savedPassword = widget.initialPassword;
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
      _savePassword = true;
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoggingIn = false;

  Contact _resolveRepeater(MeshCoreConnector connector) {
    return connector.contacts.firstWhere(
      (c) => c.publicKeyHex == widget.repeater.publicKeyHex,
      orElse: () => widget.repeater,
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _currentAttempt = 0;
      _loginError = null;
    });

    try {
      final password = _passwordController.text;
      final repeater = _resolveRepeater(_connector);
      appLogger.info(
        'Login started for ${repeater.name} (${repeater.publicKeyHex})',
        tag: 'RepeaterLogin',
      );
      final selection = await _connector.preparePathForContactSend(repeater);
      final loginFrame = buildSendLoginFrame(repeater.publicKey, password);
      final pathLengthValue = selection.useFlood ? -1 : selection.hopCount;
      final responseBytes = loginFrame.length > maxFrameSize
          ? loginFrame.length
          : maxFrameSize;
      final timeoutMs = _connector.calculateTimeout(
        pathLength: pathLengthValue,
        messageBytes: responseBytes,
      );
      final timeoutSeconds = (timeoutMs / 1000).ceil();
      final timeout = Duration(milliseconds: timeoutMs);
      final selectionLabel = selection.useFlood
          ? 'flood'
          : '${selection.hopCount} hops';
      appLogger.info('Login routing: $selectionLabel', tag: 'RepeaterLogin');
      bool? loginResult;
      for (int attempt = 0; attempt < _maxAttempts; attempt++) {
        if (!mounted) return;
        setState(() {
          _currentAttempt = attempt + 1;
        });

        appLogger.info(
          'Sending login attempt ${attempt + 1}/$_maxAttempts',
          tag: 'RepeaterLogin',
        );
        await _connector.sendFrame(loginFrame);

        loginResult = await _awaitLoginResponse(timeout);
        if (loginResult == true) {
          appLogger.info(
            'Login succeeded for ${repeater.name}',
            tag: 'RepeaterLogin',
          );
          break;
        }
        if (loginResult == false) {
          appLogger.warn(
            'Login failed for ${repeater.name}',
            tag: 'RepeaterLogin',
          );
          break;
        }
        appLogger.warn(
          'Login attempt ${attempt + 1} timed out after ${timeoutSeconds}s',
          tag: 'RepeaterLogin',
        );
      }

      if (loginResult == null) {
        appLogger.warn(
          'Login timed out for ${repeater.name}',
          tag: 'RepeaterLogin',
        );
      }

      if (loginResult == true) {
        _connector.recordRepeaterPathResult(repeater, selection, true, null);
      } else {
        _connector.recordRepeaterPathResult(repeater, selection, false, null);
      }

      if (loginResult != true) {
        if (mounted) {
          setState(() {
            _isLoggingIn = false;
            _loginError = context.l10n.login_failedMessage;
          });
        }
        return;
      }

      if (!mounted) return;
      try {
        await Provider.of<AppSettingsService>(
          context,
          listen: false,
        ).recordSuccessfulRepeaterLogin(widget.repeater.publicKeyHex);
      } catch (error) {
        // The login itself succeeded; a settings write failure must not turn
        // that into a user-visible login failure.
        appLogger.warn(
          'Could not record successful login for ${widget.repeater.name}: '
          '$error',
          tag: 'RepeaterLogin',
        );
      }

      // If we got a response, login succeeded
      // Save password if requested
      if (_savePassword) {
        await _storage.saveRepeaterPassword(
          widget.repeater.publicKeyHex,
          password,
        );
      } else {
        // Remove saved password if user unchecked the box
        await _storage.removeRepeaterPassword(widget.repeater.publicKeyHex);
      }

      if (mounted) {
        Navigator.pop(context, password);
        Future.microtask(() => widget.onLogin(password));
      }
    } catch (e) {
      final repeater = _resolveRepeater(_connector);
      appLogger.warn(
        'Login error for ${repeater.name}: $e',
        tag: 'RepeaterLogin',
      );
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
          _loginError = context.l10n.login_failedMessage;
        });
      }
    }
  }

  Future<bool?> _awaitLoginResponse(Duration timeout) async {
    final completer = Completer<bool?>();
    Timer? timer;
    StreamSubscription<Uint8List>? subscription;
    final targetPrefix = widget.repeater.publicKey.sublist(0, 6);

    subscription = _connector.receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      final code = frame[0];
      if (code != pushCodeLoginSuccess && code != pushCodeLoginFail) return;
      if (frame.length < 8) return;
      final prefix = frame.sublist(2, 8);
      if (!listEquals(prefix, targetPrefix)) return;

      completer.complete(code == pushCodeLoginSuccess);
      subscription?.cancel();
      timer?.cancel();
    });

    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
        subscription?.cancel();
      }
    });

    final result = await completer.future;
    timer.cancel();
    await subscription.cancel();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cell_tower, color: colorScheme.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.login_repeaterLogin),
                Text(
                  widget.repeater.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.login_repeaterDescription,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_loginError != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loginError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const ValueKey('repeater_login_password'),
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              // Repeaters are addressed by a mesh identity rather than a web
              // domain. Letting a third-party Android autofill provider infer
              // credentials here can interrupt the IME (as Bitwarden did in
              // the recorded first-keystroke failure). Saved repeater
              // passwords are handled by this app's secure storage instead.
              autofillHints: null,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l10n.login_password,
                hintText: l10n.login_enterPassword,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onChanged: (_) {
                if (_loginError != null && mounted) {
                  setState(() {
                    _loginError = null;
                  });
                }
              },
              onSubmitted: (_) => _handleLogin(),
              autofocus:
                  !(defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS) &&
                  _passwordController.text.isEmpty,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _savePassword,
              onChanged: (value) {
                setState(() {
                  _savePassword = value ?? false;
                });
              },
              title: Text(
                l10n.login_savePassword,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                l10n.login_savePasswordSubtitle,
                style: const TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            _RepeaterLoginRoutingSection(repeater: widget.repeater),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        if (_isLoggingIn)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.login_attempt(_currentAttempt, _maxAttempts)),
                ],
              ),
            ),
          )
        else
          FilledButton.icon(
            onPressed: _handleLogin,
            icon: const Icon(Icons.login, size: 18),
            label: Text(l10n.login_login),
          ),
      ],
    );
  }
}

/// Routing controls that listen to [MeshCoreConnector] without rebuilding the
/// password field (which would dismiss the soft keyboard on mobile).
class _RepeaterLoginRoutingSection extends StatelessWidget {
  const _RepeaterLoginRoutingSection({required this.repeater});

  final Contact repeater;

  Contact _resolveRepeater(MeshCoreConnector connector) {
    return connector.contacts.firstWhere(
      (c) => c.publicKeyHex == repeater.publicKeyHex,
      orElse: () => repeater,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connector = context.watch<MeshCoreConnector>();
    final resolved = _resolveRepeater(connector);
    final isFloodMode = resolved.pathOverride == -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.login_routing,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: Icon(isFloodMode ? Icons.waves : Icons.route),
              tooltip: l10n.login_routingMode,
              onSelected: (mode) async {
                if (mode == 'flood') {
                  await connector.setPathOverride(resolved, pathLen: -1);
                } else {
                  await connector.setPathOverride(resolved, pathLen: null);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'auto',
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_mode,
                        size: 20,
                        color: !isFloodMode
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.login_autoUseSavedPath,
                        style: TextStyle(
                          fontWeight: !isFloodMode
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'flood',
                  child: Row(
                    children: [
                      Icon(
                        Icons.waves,
                        size: 20,
                        color: isFloodMode
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.login_forceFloodMode,
                        style: TextStyle(
                          fontWeight: isFloodMode
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          resolved.pathLabel,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () =>
                PathManagementDialog.show(context, contact: resolved),
            icon: const Icon(Icons.timeline, size: 18),
            label: Text(l10n.login_managePaths),
          ),
        ),
      ],
    );
  }
}
