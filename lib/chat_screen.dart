import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_store.dart';
import 'media_viewer.dart';
import 'models.dart';
import 'settings_screen.dart';
import 'theme.dart';
import 'widgets/android_chat.dart';
import 'widgets/doodle_background.dart';
import 'widgets/fake_status_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/smart_image.dart';

class ChatScreen extends StatefulWidget {
  final ChatStore store;
  const ChatScreen({super.key, required this.store});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scroll = ScrollController();
  ChatStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    store.removeListener(_onStoreChanged);
    _scroll.dispose();
    super.dispose();
  }

  ChatTheme get _t => store.isDark ? ChatTheme.dark : ChatTheme.light;

  void _openMedia(BuildContext context, ChatMessage message) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => MediaViewerScreen(
          message: message,
          peer: store.peer,
          theme: _t,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(store: store)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final isAndroid = store.platform == UiPlatform.android;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    final messages = store.messages;

    // Sahte status bar — platform + temaya göre renkli.
    final statusBg = isAndroid ? t.androidBarBg : t.appBarBg;
    final statusFg = isAndroid ? Colors.white : t.appBarText;

    return Scaffold(
      backgroundColor: isAndroid ? t.androidBarBg : t.appBarBg,
      body: Column(
        children: [
          FakeStatusBar(
            config: store.statusBar,
            platform: store.platform,
            color: statusFg,
            bg: statusBg,
          ),
          // Üst bar — platforma göre iOS veya Android.
          if (isAndroid)
            AndroidAppBar(
              peer: store.peer,
              theme: t,
              onMenu: () => _openSettings(context),
              onBack: () => Navigator.of(context).maybePop(),
            )
          else
            _IosAppBar(
              peer: store.peer,
              theme: t,
              onMenu: () => _openSettings(context),
            ),
          Expanded(
            child: DoodleBackground(
              theme: t,
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return ChatItem(
                    message: msg,
                    theme: t,
                    onViewOnceTap: msg.type == ItemType.viewOnce
                        ? () => _openMedia(context, msg)
                        : null,
                  );
                },
              ),
            ),
          ),
          if (isAndroid)
            AndroidInputBar(theme: t, store: store, scrollController: _scroll)
          else
            _IosInputBar(theme: t, store: store, scrollController: _scroll),
        ],
      ),
    );
  }
}

/// iOS WhatsApp üst bar: geri ok + okunmamış sayısı, avatar, isim + durum,
/// sağda video/telefon.
class _IosAppBar extends StatelessWidget {
  final ChatPeer peer;
  final ChatTheme theme;
  final VoidCallback onMenu;

  const _IosAppBar({
    required this.peer,
    required this.theme,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.appBarBg,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.isDark
                  ? const Color(0xFF2A3942)
                  : const Color(0xFFE2E1DE),
              width: 0.5,
            ),
          ),
        ),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              const SizedBox(width: 8),
              // Geri ok — beyaz yuvarlak kapsül içinde (iOS WhatsApp)
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(
                      horizontal: peer.backBadge.isNotEmpty ? 11 : 13),
                  decoration: BoxDecoration(
                    color: theme.isDark
                        ? const Color(0xFF2A3942)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new,
                          color: theme.appBarIcon, size: 19),
                      if (peer.backBadge.isNotEmpty) ...[
                        const SizedBox(width: 3),
                        Text(
                          peer.backBadge,
                          style: TextStyle(
                              color: theme.appBarIcon,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Avatar + isim — dokununca düzenleme paneli açılır
              Expanded(
                child: InkWell(
                  onTap: onMenu,
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: SmartImage(
                            path: peer.avatarAsset,
                            fit: BoxFit.cover,
                            placeholder: (_) => Container(
                              color: const Color(0xFFB7C0C5),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              peer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.appBarText,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (peer.status.isNotEmpty)
                              Text(
                                peer.status,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: theme.appBarSubtitle, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Video + telefon — birlikte beyaz yuvarlak kapsülde
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? const Color(0xFF2A3942)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onMenu,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 9, 11, 9),
                        child: Icon(Icons.videocam_outlined,
                            color: theme.appBarIcon, size: 23),
                      ),
                    ),
                    GestureDetector(
                      onTap: onMenu,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(11, 9, 14, 9),
                        child: Icon(Icons.call_outlined,
                            color: theme.appBarIcon, size: 21),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// iOS alt giriş çubuğu: + , metin alanı (klavye açılır), sticker, kamera,
/// mikrofon. Yazı yazılınca kamera/mik yerine yeşil gönder oku çıkar ve
/// gönderince sohbete giden mesaj eklenir.
class _IosInputBar extends StatefulWidget {
  final ChatTheme theme;
  final ChatStore store;
  final ScrollController scrollController;

  const _IosInputBar({
    required this.theme,
    required this.store,
    required this.scrollController,
  });

  @override
  State<_IosInputBar> createState() => _IosInputBarState();
}

class _IosInputBarState extends State<_IosInputBar> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _now() {
    final n = DateTime.now();
    final h = n.hour.toString().padLeft(2, '0');
    final m = n.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.store.addMessage(ChatMessage(
      id: widget.store.nextId(),
      type: ItemType.text,
      text: text,
      isMe: true,
      time: _now(),
      status: MessageStatus.read,
    ));
    _ctrl.clear();
    setState(() => _hasText = false);
    // En alta kaydır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Container(
      color: theme.inputBarBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.add, color: theme.inputIcon, size: 31),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: theme.inputFieldBg,
                    borderRadius: BorderRadius.circular(22),
                    border: theme.isDark
                        ? null
                        : Border.all(
                            color: const Color(0xFFD8D7D4), width: 0.7),
                  ),
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          minLines: 1,
                          maxLines: 5,
                          cursorColor: const Color(0xFF25D366),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          style: TextStyle(
                              color: theme.bubbleText, fontSize: 16.5),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '',
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9, right: 2),
                        child: CustomPaint(
                          size: const Size(19, 19),
                          painter: _StickerIconPainter(theme.inputIcon),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Yazı varsa yeşil gönder oku, yoksa kamera + mikrofon
              if (_hasText)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward,
                          color: Colors.white, size: 22),
                    ),
                  ),
                )
              else ...[
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.photo_camera_outlined,
                      color: theme.inputIcon, size: 27),
                ),
                const SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.mic_none,
                      color: theme.inputIcon, size: 27),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Gerçek WhatsApp sticker ikonu: sağ-alt köşesi kıvrık (peel) kare.
class _StickerIconPainter extends CustomPainter {
  final Color color;
  _StickerIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final w = size.width, h = size.height;
    const r = 5.5; // köşe yarıçapı (daha yumuşak)
    final peel = w * 0.32; // kıvrık köşe boyutu

    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, h - peel)
      // sağ-alttan kıvrılan köşe — yumuşak geçiş
      ..lineTo(w - peel + 1.5, h - 1.5)
      ..arcToPoint(Offset(w - peel - 1, h),
          radius: const Radius.circular(2))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r));
    canvas.drawPath(path, p);

    // kıvrık köşenin iç katlanma çizgisi (yuvarlatılmış üçgen)
    final fold = Path()
      ..moveTo(w - peel, h - 0.5)
      ..lineTo(w - peel, h - peel + 1.5)
      ..arcToPoint(Offset(w - peel + 1.5, h - peel),
          radius: const Radius.circular(1.5))
      ..lineTo(w - 0.5, h - peel);
    canvas.drawPath(fold, p);
  }

  @override
  bool shouldRepaint(covariant _StickerIconPainter old) => old.color != color;
}
