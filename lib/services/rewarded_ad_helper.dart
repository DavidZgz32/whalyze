import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../monetization_config.dart';

typedef RewardedAdRewardCallback = void Function();

/// Carga y muestra un anuncio bonificado una vez; llama [onUserEarnedReward] si el usuario completa el anuncio.
class RewardedAdHelper {
  RewardedAdHelper._();
  static final instance = RewardedAdHelper._();

  RewardedAd? _ad;

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }

  Future<void> show({
    required void Function(String message) onFailed,
    required RewardedAdRewardCallback onUserEarnedReward,
  }) async {
    final completer = Completer<void>();

    await RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad?.dispose();
          _ad = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedAd a) {},
            onAdFailedToShowFullScreenContent: (RewardedAd a, Object error) {
              debugPrint('RewardedAd show failed: $error');
              a.dispose();
              _ad = null;
              onFailed('No se pudo mostrar el anuncio.');
              if (!completer.isCompleted) completer.complete();
            },
            onAdDismissedFullScreenContent: (RewardedAd a) {
              a.dispose();
              _ad = null;
              if (!completer.isCompleted) completer.complete();
            },
          );
          ad.show(
            onUserEarnedReward: (AdWithoutView adView, RewardItem reward) {
              onUserEarnedReward();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd load failed: $error');
          onFailed('No hay anuncio disponible. Prueba más tarde.');
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    return completer.future;
  }
}
