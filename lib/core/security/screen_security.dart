import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class ScreenSecurity {
  static const _channel = MethodChannel('com.takluk.app/security');
  static StreamController<bool>? _captureController;

  /// Enable secure mode (FLAG_SECURE on Android)
  static Future<void> enableSecureMode() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('enableSecureFlag');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('enableScreenProtection');
      }
    } catch (e) {
      // Fallback: try flutter_windowmanager
      print('ScreenSecurity: $e');
    }
  }

  /// Disable secure mode
  static Future<void> disableSecureMode() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableSecureFlag');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('disableScreenProtection');
      }
    } catch (e) {
      print('ScreenSecurity: $e');
    }
  }

  /// Start listening for screen capture events (iOS)
  static Stream<bool> get onScreenCaptureChanged {
    _captureController ??= StreamController<bool>.broadcast();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onScreenCaptureChanged') {
        _captureController?.add(call.arguments as bool);
      }
    });
    return _captureController!.stream;
  }

  /// Check if screen is being captured
  static Future<bool> isScreenBeingCaptured() async {
    try {
      if (Platform.isIOS) {
        return await _channel.invokeMethod('isScreenCaptured') ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void dispose() {
    _captureController?.close();
    _captureController = null;
  }
}
