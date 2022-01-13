import 'dart:async';

import 'package:flutter/services.dart';

class TslRfidProtocols {
  static const String NAMESPACE = "plugins.chrisgate.dev";
  static const _channel = const MethodChannel('callbacks');
  static const _eventChannel = const EventChannel('events');
  static const EventChannel _connectionStateChannel =
      const EventChannel('$NAMESPACE/connectionState');
  static const EventChannel _rfidTagMessageChannel =
      const EventChannel('$NAMESPACE/rfidTagMessage');
  static const EventChannel _barcodeMessageChannel =
      const EventChannel('$NAMESPACE/barcodeMessage');
  static const EventChannel _rssiSignalStrengthChannel =
      const EventChannel('$NAMESPACE/rssiSignalStrength');

  static String _resultTextMessage = "";

  static Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'resultText':
        _resultTextMessage = call.arguments as String;
        break;

      default:
        print(
            'TslRfidProtocols: Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  static Stream<String>? _transpoders;
  static Stream<String>? _barcodes;
  static Stream<String>? _connectionState;
  static Stream<String>? _rssiSignalStrength;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static String get resultText {
    _channel.setMethodCallHandler(_methodCallHandler);
    return _resultTextMessage;
  }

  static Future<bool> get isconnected async {
    final bool isConnected = await _channel.invokeMethod("isConnected");
    return isConnected;
  }

  static Stream<String> get onConnectionStateChanged {
    _connectionState ??= _connectionStateChannel
        .receiveBroadcastStream()
        .map((connectionState) => connectionState);
    return _connectionState!;
  }

  static Future<bool> useFastId(bool isChecked) async {
    final bool isFastIdSet =
        await _channel.invokeMethod("useFastId", isChecked);
    return isFastIdSet;
  }

  static Future<void> connectReader() async {
    await _channel.invokeMethod("connectReader");
  }

  static Stream<String> get startListeningToRfidTagMessages {
    _transpoders = _rfidTagMessageChannel
        .receiveBroadcastStream()
        .map<String>((data) => data);
    return _transpoders!;
  }

  static Stream<String> get startListeningToBarcodeMessages {
    _barcodes ??= _barcodeMessageChannel
        .receiveBroadcastStream()
        .map<String>((data) => data);
    return _barcodes!;
  }

  static Stream<String> get startListeningToRssiSignalStrength {
    _rssiSignalStrength ??= _rssiSignalStrengthChannel
        .receiveBroadcastStream()
        .map<String>((data) => data);
    return _rssiSignalStrength!;
  }
}
