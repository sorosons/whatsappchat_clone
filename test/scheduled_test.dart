import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/chat_store.dart';
import 'package:whatsapp_clone/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('başlatınca kuyruk boşalır ve mesajlar tek seferlik düşer', () {
    fakeAsync((async) {
      final store = ChatStore();
      final before = store.messages.length;

      store.addScheduled(ScheduledMessage(
        id: '1', delaySeconds: 3,
        message: const ChatMessage(
            id: 's1', type: ItemType.text, text: 'merhaba', isMe: false)));
      store.addScheduled(ScheduledMessage(
        id: '2', delaySeconds: 5,
        message: const ChatMessage(
            id: 's2', type: ItemType.viewOnce, mediaKind: MediaKind.photo,
            isMe: false, mediaLabel: 'Fotoğraf')));

      expect(store.scheduled.length, 2);

      store.startSchedule();
      // Başlatır başlatmaz kuyruk boşalmalı
      expect(store.scheduled.length, 0);

      async.elapse(const Duration(seconds: 6));
      // İki mesaj düştü
      expect(store.messages.length, before + 2);

      // Tekrar "başlat": kuyruk boş, yeni mesaj DÜŞMEMELİ
      store.startSchedule();
      async.elapse(const Duration(seconds: 6));
      expect(store.messages.length, before + 2);

      store.cancelSchedule();
      async.flushTimers();
    });
  });
}
