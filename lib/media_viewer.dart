import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';
import 'widgets/smart_image.dart';

/// Tam ekran "tek seferlik" medya açılma ekranı.
class MediaViewerScreen extends StatefulWidget {
  final ChatMessage message;
  final ChatPeer peer;
  final ChatTheme theme;
  final ViewerTexts texts;

  const MediaViewerScreen({
    super.key,
    required this.message,
    required this.peer,
    required this.theme,
    this.texts = const ViewerTexts(),
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  bool _showToast = false;
  int _toastToken = 0;

  /// İndir (↓) butonuna basınca "Galeriye kaydedildi" toast'ı gösterilir.
  void _saveToGallery() {
    final token = ++_toastToken;
    setState(() => _showToast = true);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted && token == _toastToken) {
        setState(() => _showToast = false);
      }
    });
  }

  void _showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bilgi',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            _infoRow('Gönderen', widget.peer.name),
            _infoRow('Tür', _kindLabel()),
            _infoRow('Saat', widget.message.time),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
                width: 100,
                child: Text(k,
                    style: const TextStyle(color: Color(0xFF8696A0)))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(color: Colors.white))),
          ],
        ),
      );

  String _kindLabel() {
    switch (widget.message.mediaKind) {
      case MediaKind.video:
        return 'Tek seferlik video';
      case MediaKind.audio:
        return 'Tek seferlik sesli mesaj';
      default:
        return 'Tek seferlik fotoğraf';
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final t = widget.theme;
    final isVideo = msg.mediaKind == MediaKind.video;
    final isAudio = msg.mediaKind == MediaKind.audio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              peer: widget.peer,
              theme: t,
              timeText: widget.texts.time,
              onBack: () => Navigator.of(context).maybePop(),
              onDownload: _saveToGallery,
              onInfo: _showInfo,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: isAudio
                        ? _AudioContent(message: msg)
                        : _MediaContent(message: msg, isVideo: isVideo),
                  ),
                  Positioned(
                    bottom: 24,
                    child: AnimatedOpacity(
                      opacity: _showToast ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: _SavedToast(text: widget.texts.savedToast),
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(
              text: widget.texts.reply,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  final ChatMessage message;
  final bool isVideo;
  const _MediaContent({required this.message, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    // Gerçek WhatsApp gibi: medya genişliği TAM kaplar ve dikeyde mümkün
    // olduğunca büyür. Fotoğraf kırpılmadan (contain) ama büyük gösterilir;
    // video ekranı doldurur (cover).
    final media = SizedBox.expand(
      child: SmartImage(
        path: message.mediaAsset,
        fit: isVideo ? BoxFit.cover : BoxFit.contain,
        placeholder: _placeholder,
      ),
    );

    if (!isVideo) return media;

    return Stack(
      alignment: Alignment.center,
      children: [
        media,
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    // Placeholder da tüm alanı kaplasın (gerçek medya gelince yerini alır).
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1E1E1E),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: Colors.white38, size: 56),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Panelden foto/video seç',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioContent extends StatelessWidget {
  final ChatMessage message;
  const _AudioContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF00A884),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 3, color: Colors.white24),
                const SizedBox(height: 10),
                Text(
                  message.time,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ChatPeer peer;
  final ChatTheme theme;
  final String timeText;
  final VoidCallback onBack;
  final VoidCallback onDownload;
  final VoidCallback onInfo;

  const _TopBar({
    required this.peer,
    required this.theme,
    required this.timeText,
    required this.onBack,
    required this.onDownload,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.mediaBar,
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 4, bottom: 4),
        child: Row(
          children: [
            // iOS ince geri chevron
            _iconBtn(
              child: Icon(Icons.arrow_back_ios_new,
                  color: theme.mediaBarIcon, size: 22),
              onTap: onBack,
            ),
            ClipOval(
              child: SizedBox(
                width: 36,
                height: 36,
                child: SmartImage(
                  path: peer.avatarAsset,
                  fit: BoxFit.cover,
                  placeholder: (_) => Container(
                    color: const Color(0xFFDDDDDD),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    peer.name,
                    style: TextStyle(
                      color: theme.mediaBarText,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(
                        color: theme.mediaBarSubtitle, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            _iconBtn(
              child: Icon(Icons.visibility_outlined,
                  color: theme.mediaBarIcon, size: 23),
              onTap: onInfo,
            ),
            _iconBtn(
              child: Icon(Icons.file_download_outlined,
                  color: theme.mediaBarIcon, size: 23),
              onTap: onDownload,
            ),
            _iconBtn(
              child:
                  Icon(Icons.info_outline, color: theme.mediaBarIcon, size: 23),
              onTap: onInfo,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({required Widget child, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        child: child,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const _BottomBar({required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F2C33),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.reply, color: Color(0xFF8696A0), size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                      color: Color(0xFF8696A0), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedToast extends StatelessWidget {
  final String text;
  const _SavedToast({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00A884), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF111111), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
