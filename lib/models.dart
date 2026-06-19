enum MessageStatus { none, sent, delivered, read }

enum MediaKind { photo, video, audio }

/// Hangi platform görünümü kullanılacak.
enum UiPlatform { ios, android }

/// Sahte status bar (üstteki saat/wifi/şarj) ayarları — panelden düzenlenebilir.
class StatusBarConfig {
  final String clock; // "01:54"
  final int battery; // 0-100
  final bool charging;
  final bool wifi;
  final int signal; // 0-4 sinyal çubuğu

  const StatusBarConfig({
    this.clock = '01:54',
    this.battery = 84,
    this.charging = false,
    this.wifi = true,
    this.signal = 4,
  });

  StatusBarConfig copyWith({
    String? clock,
    int? battery,
    bool? charging,
    bool? wifi,
    int? signal,
  }) {
    return StatusBarConfig(
      clock: clock ?? this.clock,
      battery: battery ?? this.battery,
      charging: charging ?? this.charging,
      wifi: wifi ?? this.wifi,
      signal: signal ?? this.signal,
    );
  }
}

/// Bir öğenin türü. Normal mesajlar dışında tarih ayracı, sistem
/// mesajı (ör. "Bu mesaj silindi") ve okunmamış ayracı da listede yer alır.
enum ItemType { text, viewOnce, dateSeparator, deleted, unreadSeparator }

/// Sohbet listesindeki tek bir öğe. Her şey panelden düzenlenebilir.
class ChatMessage {
  final String id;
  final ItemType type;

  /// Metin (text tipinde), tarih ayracı yazısı (dateSeparator tipinde) veya
  /// okunmamış ayracı yazısı (unreadSeparator tipinde) için kullanılır.
  final String text;

  /// true => giden (sağ), false => gelen (sol).
  final bool isMe;
  final String time;
  final MessageStatus status;

  /// "Düzenlendi" etiketi gösterilsin mi.
  final bool edited;

  // View-once medya alanları
  final MediaKind? mediaKind;

  /// Baloncukta gösterilecek etiket — dil serbest (ör. "Fotoğraf", "Video",
  /// "Sesli mesaj", "Foto"). Boşsa mediaKind'a göre varsayılan kullanılır.
  final String mediaLabel;

  /// Tam ekran açıldığında gösterilecek görsel: 'assets/...' veya cihaz dosyası.
  final String? mediaAsset;

  const ChatMessage({
    required this.id,
    this.type = ItemType.text,
    this.text = '',
    this.isMe = false,
    this.time = '',
    this.status = MessageStatus.none,
    this.edited = false,
    this.mediaKind,
    this.mediaLabel = '',
    this.mediaAsset,
  });

  ChatMessage copyWith({
    ItemType? type,
    String? text,
    bool? isMe,
    String? time,
    MessageStatus? status,
    bool? edited,
    MediaKind? mediaKind,
    String? mediaLabel,
    String? mediaAsset,
  }) {
    return ChatMessage(
      id: id,
      type: type ?? this.type,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
      edited: edited ?? this.edited,
      mediaKind: mediaKind ?? this.mediaKind,
      mediaLabel: mediaLabel ?? this.mediaLabel,
      mediaAsset: mediaAsset ?? this.mediaAsset,
    );
  }
}

/// Zamanlanmış mesaj: "başlat"tan kaç saniye sonra sohbete düşeceği.
class ScheduledMessage {
  final String id;
  final ChatMessage message;
  final int delaySeconds;

  const ScheduledMessage({
    required this.id,
    required this.message,
    required this.delaySeconds,
  });

  ScheduledMessage copyWith({ChatMessage? message, int? delaySeconds}) {
    return ScheduledMessage(
      id: id,
      message: message ?? this.message,
      delaySeconds: delaySeconds ?? this.delaySeconds,
    );
  }
}

/// Sohbet başlığı bilgileri.
class ChatPeer {
  final String name;
  final String? avatarAsset;
  final String status; // "çevrimiçi", "en línea", vb.

  /// Geri okun yanındaki okunmamış sohbet sayısı (ör. "12"). Boşsa gizli.
  final String backBadge;

  const ChatPeer({
    required this.name,
    this.avatarAsset,
    this.status = 'çevrimiçi',
    this.backBadge = '',
  });

  ChatPeer copyWith({
    String? name,
    String? avatarAsset,
    String? status,
    String? backBadge,
  }) {
    return ChatPeer(
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      status: status ?? this.status,
      backBadge: backBadge ?? this.backBadge,
    );
  }
}
