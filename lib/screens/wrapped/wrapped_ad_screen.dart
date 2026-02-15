import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Pantalla 4 del wrapped: publicidad de Google que ocupa todo el contenido
/// (la barra de progreso sigue arriba en el slideshow).
class WrappedAdScreen extends StatefulWidget {
  final int totalScreens;

  const WrappedAdScreen({
    super.key,
    required this.totalScreens,
  });

  @override
  State<WrappedAdScreen> createState() => _WrappedAdScreenState();
}

class _WrappedAdScreenState extends State<WrappedAdScreen> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  // IDs de prueba de AdMob (reemplazar por tus IDs reales en producción)
  static const String _androidAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    await _bannerAd?.dispose();
    if (!mounted) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final paddingTop = MediaQuery.paddingOf(context).top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final paddingBottom = MediaQuery.paddingOf(context).bottom + 32;
    final maxHeight = (MediaQuery.sizeOf(context).height - paddingTop - paddingBottom).truncate().clamp(250, 800);

    final adSize = AdSize.getInlineAdaptiveBannerAdSize(width, maxHeight);
    final adUnitId = Platform.isAndroid ? _androidAdUnitId : _iosAdUnitId;

    setState(() {
      _bannerAd = null;
      _isLoaded = false;
      _adSize = null;
    });

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          if (!mounted) return;
          final bannerAd = ad as BannerAd;
          final size = await bannerAd.getPlatformAdSize();
          if (size != null && mounted) {
            setState(() {
              _bannerAd = bannerAd;
              _isLoaded = true;
              _adSize = size;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    await _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: _isLoaded && _bannerAd != null && _adSize != null
            ? SizedBox(
                width: _adSize!.width.toDouble(),
                height: _adSize!.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            : const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }
}
