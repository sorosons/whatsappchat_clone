import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

/// WhatsApp sohbet arka planına benzer yoğun "doodle" deseni.
/// Tek renkli bir SVG tile'ı ekran boyunca döşer (tiling).
class DoodleBackground extends StatelessWidget {
  final Widget child;
  final ChatTheme theme;
  const DoodleBackground({super.key, required this.child, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.chatBg,
      child: Stack(
        children: [
          Positioned.fill(
            child: _DoodleTiles(color: theme.doodle, dark: theme.isDark),
          ),
          child,
        ],
      ),
    );
  }
}

class _DoodleTiles extends StatelessWidget {
  final Color color;
  final bool dark;
  const _DoodleTiles({required this.color, required this.dark});

  static const double _tile = 168; // ekrandaki döşeme boyutu

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = (constraints.maxWidth / _tile).ceil() + 1;
        final rows = (constraints.maxHeight / _tile).ceil() + 1;
        final svg = SvgPicture.asset(
          'assets/images/doodle.svg',
          width: _tile,
          height: _tile,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: cols * _tile,
            maxHeight: rows * _tile,
            child: Opacity(
              opacity: dark ? 0.5 : 0.38,
              child: Wrap(
                children: List.generate(
                  cols * rows,
                  (_) => SizedBox(width: _tile, height: _tile, child: svg),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
