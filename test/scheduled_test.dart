import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/chat_store.dart';
import 'package:whatsapp_clone/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('zamanlanmış mesaj süre dolunca eklenir + metinde yazıyor efekti', () {
    fakeAsync((async) {
      final store = ChatStore();
      final before = store.messages.length;

      store.addScheduled(ScheduledMessage(
        id: '1',
        delaySeconds: 5,
        message: const ChatMessage(
            id: 's1', type: ItemType.text, text: 'merhaba', isMe: false),
      ));
      store.addScheduled(ScheduledMessage(
        id: '2',
        delaySeconds: 8,
        message: const ChatMessage(
            id: 's2', type: ItemType.viewOnce, mediaKind: MediaKind.photo,
            isMe: false, mediaLabel: 'Fotoğraf'),
      ));

      store.startSchedule();

      async.elapse(const Duration(milliseconds: 3500));
      expect(store.isTyping, true);
      expect(store.messages.length, before);

      async.elapse(const Duration(milliseconds: 1600));
      expect(store.isTyping, false);
      expect(store.messages.length, before + 1);
      expect(store.messages.last.text, 'merhaba');

      async.elapse(const Duration(seconds: 3));
      expect(store.messages.length, before + 2);
      expect(store.messages.last.type, ItemType.viewOnce);

      store.cancelSchedule();
      async.flushTimers();
    });
  });
}
