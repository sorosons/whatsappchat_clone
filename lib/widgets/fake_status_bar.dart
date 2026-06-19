import 'package:flutter/material.dart';
import '../models.dart';

/// Sahte telefon status bar'ı — saat, sinyal, wifi, şarj.
/// iOS ve Android için ayrı yerleşim. Renk (koyu/açık) dışarıdan verilir.
class FakeStatusBar extends StatelessWidget {
  final StatusBarConfig config;
  final UiPlatform platform;
  final Color color; // ikon/yazı rengi
  final Color bg;

  const FakeStatusBar({
    super.key,
    required this.config,
    required this.platform,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final isIos = platform == UiPlatform.ios;
    return Container(
      color: bg,
      height: isIos ? 54 : 30,
      padding: EdgeInsets.only(
        left: isIos ? 30 : 14,
        right: isIos ? 26 : 12,
        top: isIos ? 14 : 4,
      ),
      child: Row(
        children: [
          // Saat (iOS ortaya yakın değil, sola; Android sola)
          Text(
            config.clock,
            style: TextStyle(
              color: color,
              fontSize: isIos ? 17 : 14,
              fontWeight: FontWeight.w600,
              letterSpacing: isIos ? 0 : 0.2,
              fontFeatures: const [],
            ),
          ),
          const Spacer(),
          if (isIos) ...[
            _SignalBars(color: color, level: config.signal),
            const SizedBox(width: 7),
            if (config.wifi) _WifiIcon(color: color, size: 17),
            const SizedBox(width: 7),
            _BatteryIos(color: color, level: config.battery, charging: config.charging),
          ] else ...[
            // Android: sinyal, wifi, batarya (yüzde yazısı + ikon)
            _SignalBars(color: color, level: config.signal, size: 13),
            const SizedBox(width: 5),
            if (config.wifi) _WifiIcon(color: color, size: 15),
            const SizedBox(width: 5),
            Text('${config.battery}%',
                style: TextStyle(color: color, fontSize: 12.5)),
            const SizedBox(width: 3),
            _BatteryAndroid(color: color, level: config.battery, charging: config.charging),
          ],
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final Color color;
  final int level;
  final double size;
  const _SignalBars({required this.color, required this.level, this.size = 17});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(painter: _SignalPainter(color, level)),
    );
  }
}

class _SignalPainter extends CustomPainter {
  final Color color;
  final int level;
  _SignalPainter(this.color, this.level);

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 4;
    final gap = size.width * 0.12;
    final barW = (size.width - gap * (bars - 1)) / bars;
    for (int i = 0; i < bars; i++) {
      final h = size.height * (0.4 + 0.2 * i);
      final x = i * (barW + gap);
      final y = size.height - h;
      final paint = Paint()
        ..color = i < level ? color : color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SignalPainter old) =>
      old.color != color || old.level != level;
}

class _WifiIcon extends StatelessWidget {
  final Color color;
  final double size;
  const _WifiIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.wifi, color: color, size: size);
  }
}

class _BatteryIos extends StatelessWidget {
  final Color color;
  final int level;
  final bool charging;
  const _BatteryIos(
      {required this.color, required this.level, required this.charging});

  @override
  Widget build(BuildContext context) {
    final fillColor = charging
        ? const Color(0xFF34C759)
        : (level <= 20 ? const Color(0xFFFF3B30) : color);
    return SizedBox(
      width: 30,
      height: 14,
      child: CustomPaint(
        painter: _BatteryIosPainter(color, fillColor, level, charging),
      ),
    );
  }
}

class _BatteryIosPainter extends CustomPainter {
  final Color outline;
  final Color fill;
  final int level;
  final bool charging;
  _BatteryIosPainter(this.outline, this.fill, this.level, this.charging);

  @override
  void paint(Canvas canvas, Size size) {
    final bodyW = size.width - 4;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bodyW, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = outline.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // uç
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyW + 1, size.height * 0.3, 2, size.height * 0.4),
        const Radius.circular(1),
      ),
      Paint()..color = outline.withValues(alpha: 0.4),
    );
    // dolum
    final fillW = (bodyW - 4) * (level / 100).clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, fillW, size.height - 4),
        const Radius.circular(2),
      ),
      Paint()..color = fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryIosPainter old) =>
      old.level != level || old.fill != fill || old.charging != charging;
}

class _BatteryAndroid extends StatelessWidget {
  final Color color;
  final int level;
  final bool charging;
  const _BatteryAndroid(
      {required this.color, required this.level, required this.charging});

  @override
  Widget build(BuildContext context) {
    return Icon(
      charging
          ? Icons.battery_charging_full
          : (level >= 95
              ? Icons.battery_full
              : level >= 60
                  ? Icons.battery_5_bar
                  : level >= 30
                      ? Icons.battery_3_bar
                      : Icons.battery_2_bar),
      color: color,
      size: 16,
    );
  }
}
