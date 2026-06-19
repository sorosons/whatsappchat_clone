import 'package:flutter/material.dart';
import '../chat_store.dart';
import '../models.dart';
import '../theme.dart';
import 'smart_image.dart';

/// Klasik yeşil Android WhatsApp üst barı.
class AndroidAppBar extends StatelessWidget {
  final ChatPeer peer;
  final ChatTheme theme;
  final VoidCallback onMenu;
  final VoidCallback onBack;

  const AndroidAppBar({
    super.key,
    required this.peer,
    required this.theme,
    required this.onMenu,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bg = theme.androidBarBg;
    return Material(
      color: bg,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: onBack,
            ),
            ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: SmartImage(
                  path: peer.avatarAsset,
                  fit: BoxFit.cover,
                  placeholder: (_) => Container(
                    color: const Color(0xFF6E8B95),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onMenu,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (peer.status.isNotEmpty)
                      Text(
                        peer.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFD6E7E2), fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.white, size: 24),
              onPressed: onMenu,
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.white, size: 21),
              onPressed: onMenu,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 23),
              onPressed: onMenu,
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

/// Klasik Android WhatsApp alt giriş çubuğu:
/// yuvarlak beyaz alan (emoji, metin, ataç, kamera) + dışında yuvarlak yeşil
/// mikrofon/gönder butonu.
class AndroidInputBar extends StatefulWidget {
  final ChatTheme theme;
  final ChatStore store;
  final ScrollController scrollController;

  const AndroidInputBar({
    super.key,
    required this.theme,
    required this.store,
    required this.scrollController,
  });

  @override
  State<AndroidInputBar> createState() => _AndroidInputBarState();
}

class _AndroidInputBarState extends State<AndroidInputBar> {
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
    return '${n.hour.toString().padLeft(2, '0')}:'
        '${n.minute.toString().padLeft(2, '0')}';
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
    final fieldBg = theme.isDark ? const Color(0xFF1F2C33) : Colors.white;
    final iconColor =
        theme.isDark ? const Color(0xFF8696A0) : const Color(0xFF7E8B92);
    return Container(
      color: theme.isDark ? const Color(0xFF0B141A) : const Color(0xFFEFE7DE),
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Icon(Icons.emoji_emotions_outlined,
                        color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 5,
                      cursorColor: const Color(0xFF008069),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: TextStyle(
                          color: theme.bubbleText, fontSize: 16.5),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Mesaj',
                        hintStyle:
                            TextStyle(color: iconColor, fontSize: 16.5),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Icon(Icons.attach_file, color: iconColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (!_hasText)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9, right: 2),
                      child: Icon(Icons.photo_camera_outlined,
                          color: iconColor, size: 22),
                    ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _hasText ? _send : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF00A884),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _hasText ? Icons.send : Icons.mic,
                color: Colors.white,
                size: _hasText ? 22 : 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
