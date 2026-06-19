import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_data.dart' as defaults;
import 'models.dart';

/// Sohbetin tüm düzenlenebilir durumunu tutar ve cihazda kalıcı saklar.
class ChatStore extends ChangeNotifier {
  static const _kKey = 'chat_state_v3';

  ChatPeer _peer = defaults.kPeer;
  List<ChatMessage> _messages = List.of(defaults.kMessages);
  bool _dark = false;
  UiPlatform _platform = UiPlatform.ios;
  StatusBarConfig _statusBar = const StatusBarConfig();

  // Zamanlanmış mesajlar (kalıcı). Aktif timer'lar ve "yazıyor..." geçici.
  List<ScheduledMessage> _scheduled = [];
  final List<Timer> _activeTimers = [];
  bool _isTyping = false;

  ChatPeer get peer => _peer;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isDark => _dark;
  UiPlatform get platform => _platform;
  StatusBarConfig get statusBar => _statusBar;
  List<ScheduledMessage> get scheduled => List.unmodifiable(_scheduled);
  bool get isTyping => _isTyping;

  // ---- Yükleme / kaydetme ----

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _dark = map['dark'] as bool? ?? false;
      _platform = UiPlatform.values[(map['platform'] as int?) ?? 0];
      _statusBar = _statusFromJson(
          map['statusBar'] as Map<String, dynamic>? ?? const {});
      _peer = _peerFromJson(map['peer'] as Map<String, dynamic>);
      _messages = (map['messages'] as List)
          .map((e) => _msgFromJson(e as Map<String, dynamic>))
          .toList();
      _scheduled = ((map['scheduled'] as List?) ?? [])
          .map((e) => _schedFromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // Bozuk veri => varsayılan.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'dark': _dark,
      'platform': _platform.index,
      'statusBar': _statusToJson(_statusBar),
      'peer': _peerToJson(_peer),
      'messages': _messages.map(_msgToJson).toList(),
      'scheduled': _scheduled.map(_schedToJson).toList(),
    };
    await prefs.setString(_kKey, jsonEncode(map));
  }

  // ---- Mutasyonlar ----

  void setDark(bool v) {
    _dark = v;
    notifyListeners();
    _persist();
  }

  void setPlatform(UiPlatform p) {
    _platform = p;
    notifyListeners();
    _persist();
  }

  void updateStatusBar(StatusBarConfig s) {
    _statusBar = s;
    notifyListeners();
    _persist();
  }

  // ---- Zamanlanmış mesajlar ----

  void addScheduled(ScheduledMessage s) {
    _scheduled.add(s);
    notifyListeners();
    _persist();
  }

  void updateScheduled(int index, ScheduledMessage s) {
    _scheduled[index] = s;
    notifyListeners();
    _persist();
  }

  void removeScheduledAt(int index) {
    _scheduled.removeAt(index);
    notifyListeners();
    _persist();
  }

  void clearScheduled() {
    _scheduled.clear();
    notifyListeners();
    _persist();
  }

  String nextScheduledId() {
    var max = 0;
    for (final s in _scheduled) {
      final n = int.tryParse(s.id) ?? 0;
      if (n > max) max = n;
    }
    return '${max + 1}';
  }

  /// Tüm zamanlanmış mesajlar için geri sayımı başlatır.
  /// Metin mesajlarda, düşmeden ~2.2 sn önce "yazıyor..." gösterilir.
  void startSchedule() {
    cancelSchedule();
    for (final s in _scheduled) {
      final isText = s.message.type == ItemType.text && !s.message.isMe;
      final delayMs = s.delaySeconds * 1000;

      // Gelen metin mesajıysa, düşmeden önce "yazıyor..." göster.
      if (isText) {
        final typingAt = delayMs - 2200;
        if (typingAt > 0) {
          _activeTimers.add(Timer(Duration(milliseconds: typingAt), () {
            _setTyping(true);
          }));
        } else {
          _setTyping(true);
        }
      }

      _activeTimers.add(Timer(Duration(milliseconds: delayMs), () {
        if (isText) _setTyping(false);
        _messages.add(s.message);
        notifyListeners();
        _persist();
      }));
    }
  }

  void cancelSchedule() {
    for (final t in _activeTimers) {
      t.cancel();
    }
    _activeTimers.clear();
    if (_isTyping) {
      _isTyping = false;
      notifyListeners();
    }
  }

  void _setTyping(bool v) {
    if (_isTyping == v) return;
    _isTyping = v;
    notifyListeners();
  }

  @override
  void dispose() {
    cancelSchedule();
    super.dispose();
  }

  Map<String, dynamic> _schedToJson(ScheduledMessage s) => {
        'id': s.id,
        'delay': s.delaySeconds,
        'message': _msgToJson(s.message),
      };

  ScheduledMessage _schedFromJson(Map<String, dynamic> m) => ScheduledMessage(
        id: m['id'] as String,
        delaySeconds: m['delay'] as int? ?? 5,
        message: _msgFromJson(m['message'] as Map<String, dynamic>),
      );

  Map<String, dynamic> _statusToJson(StatusBarConfig s) => {
        'clock': s.clock,
        'battery': s.battery,
        'charging': s.charging,
        'wifi': s.wifi,
        'signal': s.signal,
      };

  StatusBarConfig _statusFromJson(Map<String, dynamic> m) => StatusBarConfig(
        clock: m['clock'] as String? ?? '01:54',
        battery: m['battery'] as int? ?? 84,
        charging: m['charging'] as bool? ?? false,
        wifi: m['wifi'] as bool? ?? true,
        signal: m['signal'] as int? ?? 4,
      );

  void updatePeer(ChatPeer p) {
    _peer = p;
    notifyListeners();
    _persist();
  }

  void updateMessage(int index, ChatMessage updated) {
    _messages[index] = updated;
    notifyListeners();
    _persist();
  }

  void addMessage(ChatMessage m) {
    _messages.add(m);
    notifyListeners();
    _persist();
  }

  void insertMessage(int index, ChatMessage m) {
    _messages.insert(index, m);
    notifyListeners();
    _persist();
  }

  void removeAt(int index) {
    _messages.removeAt(index);
    notifyListeners();
    _persist();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final m = _messages.removeAt(oldIndex);
    _messages.insert(newIndex, m);
    notifyListeners();
    _persist();
  }

  void resetToDefault() {
    _peer = defaults.kPeer;
    _messages = List.of(defaults.kMessages);
    notifyListeners();
    _persist();
  }

  String nextId() {
    var max = 0;
    for (final m in _messages) {
      final n = int.tryParse(m.id) ?? 0;
      if (n > max) max = n;
    }
    return '${max + 1}';
  }

  // ---- JSON ----

  Map<String, dynamic> _peerToJson(ChatPeer p) => {
        'name': p.name,
        'status': p.status,
        'avatarAsset': p.avatarAsset,
        'backBadge': p.backBadge,
      };

  ChatPeer _peerFromJson(Map<String, dynamic> m) => ChatPeer(
        name: m['name'] as String? ?? 'Yakup',
        status: m['status'] as String? ?? 'çevrimiçi',
        avatarAsset: m['avatarAsset'] as String?,
        backBadge: m['backBadge'] as String? ?? '',
      );

  Map<String, dynamic> _msgToJson(ChatMessage m) => {
        'id': m.id,
        'type': m.type.index,
        'text': m.text,
        'isMe': m.isMe,
        'time': m.time,
        'status': m.status.index,
        'edited': m.edited,
        'mediaKind': m.mediaKind?.index,
        'mediaLabel': m.mediaLabel,
        'mediaAsset': m.mediaAsset,
      };

  ChatMessage _msgFromJson(Map<String, dynamic> m) => ChatMessage(
        id: m['id'] as String,
        type: ItemType.values[(m['type'] as int?) ?? 0],
        text: m['text'] as String? ?? '',
        isMe: m['isMe'] as bool? ?? false,
        time: m['time'] as String? ?? '',
        status: MessageStatus.values[(m['status'] as int?) ?? 0],
        edited: m['edited'] as bool? ?? false,
        mediaKind: m['mediaKind'] != null
            ? MediaKind.values[m['mediaKind'] as int]
            : null,
        mediaLabel: m['mediaLabel'] as String? ?? '',
        mediaAsset: m['mediaAsset'] as String?,
      );
}
