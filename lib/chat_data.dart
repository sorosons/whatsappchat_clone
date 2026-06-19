import 'models.dart';

/// Varsayılan örnek sohbet (panelden tamamen değiştirilebilir).
/// Referans ekran görüntülerindeki "Yakup" sohbetine yakın.
const ChatPeer kPeer = ChatPeer(
  name: 'Yakup',
  status: 'çevrimiçi',
  backBadge: '1',
);

/// Tam ekranda gösterilecek varsayılan görsel.
/// Panelden kendi foto/videonla değiştirebilirsin.
const String kPhotoAsset = 'assets/images/view_once_photo.jpg';

final List<ChatMessage> kMessages = [
  const ChatMessage(
    id: '1',
    type: ItemType.text,
    text: 'View Once is a feature many users search because photos and videos '
        'disappear after being opened.',
    isMe: true,
    time: '03:13',
    status: MessageStatus.read,
  ),
  const ChatMessage(id: '2', type: ItemType.dateSeparator, text: 'Bugün'),

  const ChatMessage(
    id: '3',
    type: ItemType.viewOnce,
    isMe: false,
    time: '13:45',
    mediaKind: MediaKind.video,
    mediaLabel: 'Video',
    mediaAsset: kPhotoAsset,
  ),
  const ChatMessage(
    id: '4',
    type: ItemType.viewOnce,
    isMe: false,
    time: '13:46',
    mediaKind: MediaKind.photo,
    mediaLabel: 'Fotoğraf',
    mediaAsset: kPhotoAsset,
  ),
  const ChatMessage(
    id: '5',
    type: ItemType.viewOnce,
    isMe: false,
    time: '13:46',
    mediaKind: MediaKind.audio,
    mediaLabel: 'Sesli mesaj',
    mediaAsset: kPhotoAsset,
  ),
  const ChatMessage(
    id: '6',
    type: ItemType.deleted,
    isMe: false,
    time: '13:47',
    text: 'Bu mesaj silindi',
  ),
];
