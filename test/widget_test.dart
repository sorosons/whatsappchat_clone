import 'package:flutter_test/flutter_test.dart';

import 'package:whatsapp_clone/chat_store.dart';
import 'package:whatsapp_clone/main.dart';

void main() {
  testWidgets('Chat ekranı yüklenir ve kişi adı görünür',
      (WidgetTester tester) async {
    final store = ChatStore();
    await tester.pumpWidget(WhatsAppCloneApp(store: store));
    await tester.pump();

    expect(find.text('Yakup'), findsWidgets);
    // Varsayılan view-once etiketleri görünür.
    expect(find.text('Video'), findsWidgets);
    expect(find.text('Fotoğraf'), findsWidgets);
  });
}
