// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoNetworkMonitor {
  static final ZegoNetworkMonitor _instance = ZegoNetworkMonitor._internal();
  factory ZegoNetworkMonitor() => _instance;
  ZegoNetworkMonitor._internal();

  final ValueNotifier<Map<String, ZegoStreamQualityLevel>> userNetworkQuality =
      ValueNotifier({});

  Function(String userID, ZegoStreamQualityLevel upstreamQuality,
      ZegoStreamQualityLevel downstreamQuality)? _originalOnNetworkQuality;

  void init() {
    _originalOnNetworkQuality = ZegoExpressEngine.onNetworkQuality;

    ZegoExpressEngine.onNetworkQuality =
        (userID, upstreamQuality, downstreamQuality) {
      _originalOnNetworkQuality?.call(
          userID, upstreamQuality, downstreamQuality);

      final currentMap =
          Map<String, ZegoStreamQualityLevel>.from(userNetworkQuality.value);

      if (userID.isEmpty) {
        // Local user
        currentMap['local'] = upstreamQuality;
        currentMap[ZegoUIKit().getLocalUser().id] = upstreamQuality;
      } else {
        // Remote user
        currentMap[userID] = downstreamQuality;
      }

      userNetworkQuality.value = currentMap;
    };
  }

  void uninit() {
    // Restore original handler?
    // If we just set it to _originalOnNetworkQuality, we might remove someone else's handler if they chained after us.
    // But usually uninit happens on dispose.
    if (_originalOnNetworkQuality != null) {
      ZegoExpressEngine.onNetworkQuality = _originalOnNetworkQuality;
    } else {
      ZegoExpressEngine.onNetworkQuality = null;
    }
    userNetworkQuality.value = {};
  }
}
