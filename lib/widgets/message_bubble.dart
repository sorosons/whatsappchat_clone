import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// Bir sohbet öğesini tipine göre çizer: metin baloncuğu, view-once baloncuğu,
/// tarih ayracı, silinen mesaj veya okunmamış ayracı.
class ChatItem extends StatelessWidget {
  final ChatMessage message;
  final ChatTheme theme;
  final VoidCallback? onViewOnceTap;

  const ChatItem({
    super.key,
    required this.message,
    required this.theme,
    this.onViewOnceTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case ItemType.dateSeparator:
        return _CenterPill(text: message.text, theme: theme);
      case ItemType.unreadSeparator:
        return _UnreadSeparator(text: message.text, theme: theme);
      case ItemType.deleted:
        return _Bubble(
          message: message,
          theme: theme,
          child: _DeletedContent(message: message, theme: theme),
        );
      case ItemType.viewOnce:
        return _Bubble(
          message: message,
          theme: theme,
          onTap: onViewOnceTap,
          child: _ViewOnceContent(message: message, theme: theme),
        );
      case ItemType.text:
        return _Bubble(
          message: message,
          theme: theme,
          child: _TextContent(message: message, theme: theme),
        );
    }
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final ChatTheme theme;
  final Widget child;
  final VoidCallback? onTap;

  const _Bubble({
    required this.message,
    required this.theme,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final color =
        isMe ? theme.outgoingBubble : theme.incomingBubble;

    // iOS WhatsApp: köşeler ~14px. Gelen baloncuğun kuyruğu sol-üstte,
    // giden baloncuğun kuyruğu sağ-üstte (dış üst köşe sivri).
    final radius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? 14 : 5),
      topRight: Radius.circular(isMe ? 5 : 14),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: EdgeInsets.only(
          left: isMe ? 50 : 7,
          right: isMe ? 7 : 50,
          top: 1,
          bottom: 1,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
          boxShadow: theme.isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 0.8,
                    offset: Offset(0, 0.6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final ChatMessage message;
  final ChatTheme theme;
  const _TextContent({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: theme.bubbleText,
              fontSize: 16.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 1),
          _MetaRow(message: message, theme: theme),
        ],
      ),
    );
  }
}

class _DeletedContent extends StatelessWidget {
  final ChatMessage message;
  final ChatTheme theme;
  const _DeletedContent({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 16, color: theme.timeStamp),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message.text.isEmpty ? 'Bu mesaj silindi.' : message.text,
              style: TextStyle(
                color: theme.timeStamp,
                fontStyle: FontStyle.italic,
                fontSize: 15.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message.time,
            style: TextStyle(color: theme.timeStamp, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ViewOnceContent extends StatelessWidget {
  final ChatMessage message;
  final ChatTheme theme;
  const _ViewOnceContent({required this.message, required this.theme});

  String get _label {
    if (message.mediaLabel.isNotEmpty) return message.mediaLabel;
    switch (message.mediaKind) {
      case MediaKind.video:
        return 'Video';
      case MediaKind.audio:
        return 'Sesli mesaj';
      default:
        return 'Fotoğraf';
    }
  }

  @override
  Widget build(BuildContext context) {
    // iOS WhatsApp: [halka] [etiket]   ...   saat (sağ altta).
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 11, 11, 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: _ViewOnceRing(theme: theme),
          ),
          const SizedBox(width: 12),
          Text(
            _label,
            style: TextStyle(
              color: theme.viewOnceText,
              fontSize: 18.5,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 1.5),
            child: _MetaRow(message: message, theme: theme),
          ),
        ],
      ),
    );
  }
}

/// iOS view-once: yeşil kesik halka + ortada net "1".
/// Gerçek WhatsApp'taki gibi belirgin: ~9 uzun segment, kalın çizgi.
class _ViewOnceRing extends StatelessWidget {
  final ChatTheme theme;
  const _ViewOnceRing({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _RingPainter(theme.viewOnceRing),
        child: Center(
          child: Text(
            '1',
            style: TextStyle(
              color: theme.viewOnceRing,
              fontSize: 14.5,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  _RingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 1.6,
    );
    // 9 belirgin segment — gerçek WhatsApp view-once halkasına benzer.
    const dashCount = 9;
    const sweep = 6.2831853 / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
          rect, i * sweep + sweep * 0.18, sweep * 0.64, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.color != color;
}

/// Saat + "Düzenlendi" + tikler.
class _MetaRow extends StatelessWidget {
  final ChatMessage message;
  final ChatTheme theme;
  const _MetaRow({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.edited) ...[
          Text(
            'Düzenlendi',
            style: TextStyle(color: theme.timeStamp, fontSize: 11),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          message.time,
          style: TextStyle(color: theme.timeStamp, fontSize: 11),
        ),
        if (message.isMe && message.status != MessageStatus.none) ...[
          const SizedBox(width: 3),
          _Ticks(status: message.status, theme: theme),
        ],
      ],
    );
  }
}

class _Ticks extends StatelessWidget {
  final MessageStatus status;
  final ChatTheme theme;
  const _Ticks({required this.status, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isRead = status == MessageStatus.read;
    final isSingle = status == MessageStatus.sent;
    final color = isRead ? theme.tickBlue : theme.tickGrey;

    if (isSingle) {
      return Icon(Icons.check, size: 16, color: color);
    }
    return SizedBox(
      width: 17,
      height: 16,
      child: Stack(
        children: [
          Positioned(left: 0, child: Icon(Icons.check, size: 16, color: color)),
          Positioned(left: 5, child: Icon(Icons.check, size: 16, color: color)),
        ],
      ),
    );
  }
}

/// Ortalanmış hap (tarih ayracı, "Bugün/Dün").
class _CenterPill extends StatelessWidget {
  final String text;
  final ChatTheme theme;
  const _CenterPill({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.systemPill,
          borderRadius: BorderRadius.circular(8),
          boxShadow: theme.isDark
              ? null
              : const [BoxShadow(color: Color(0x12000000), blurRadius: 1)],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: theme.systemPillText,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// "X okunmamış mesaj" tam genişlik ayracı.
class _UnreadSeparator extends StatelessWidget {
  final String text;
  final ChatTheme theme;
  const _UnreadSeparator({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 7),
      color: theme.unreadPill,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.unreadPillText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
