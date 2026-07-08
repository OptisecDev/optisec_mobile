import 'dart:async';

import 'package:flutter/services.dart';

/// Tracks whether the system clipboard currently holds something the vault
/// put there, so it can be cleared automatically after a short delay *and*
/// immediately on lock — without ever touching clipboard content that came
/// from somewhere else (a copied link, another app's text, etc).
class VaultClipboardGuard {
  VaultClipboardGuard._();

  static final VaultClipboardGuard instance = VaultClipboardGuard._();

  static const _autoClearDelay = Duration(seconds: 35);

  Timer? _clearTimer;
  bool _holdsVaultContent = false;

  bool get holdsVaultContent => _holdsVaultContent;

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _holdsVaultContent = true;
    _clearTimer?.cancel();
    _clearTimer = Timer(_autoClearDelay, _clear);
  }

  /// Called on vault lock — no-ops if the clipboard doesn't currently hold
  /// vault content, so a user's unrelated copy afterwards is never wiped.
  Future<void> clearIfHoldingVaultContent() async {
    if (!_holdsVaultContent) return;
    await _clear();
  }

  Future<void> _clear() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    if (_holdsVaultContent) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
    _holdsVaultContent = false;
  }
}
