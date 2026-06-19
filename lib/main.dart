import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_screen.dart';
import 'chat_store.dart';

late final ChatStore chatStore;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tam ekran: gerçek telefon status/navigation bar'ı gizle (immersive).
  // Böylece sahte status bar tek görünen üst çubuk olur.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  chatStore = ChatStore();
  await chatStore.load();
  runApp(WhatsAppCloneApp(store: chatStore));
}

class WhatsAppCloneApp extends StatelessWidget {
  final ChatStore store;
  const WhatsAppCloneApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFEFE7DE),
        useMaterial3: false,
      ),
      home: AnimatedBuilder(
        animation: store,
        builder: (context, _) => ChatScreen(store: store),
      ),
    );
  }
}
