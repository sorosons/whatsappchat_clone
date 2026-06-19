import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_store.dart';
import 'message_editor.dart';
import 'models.dart';

/// Her şeyi düzenleyen panel: tema, kişi, mesaj listesi (ekle/sil/sırala/düzenle).
class SettingsScreen extends StatefulWidget {
  final ChatStore store;
  const SettingsScreen({super.key, required this.store});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ChatStore get store => widget.store;
  final _picker = ImagePicker();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _statusCtrl;
  late final TextEditingController _badgeCtrl;
  late final TextEditingController _clockCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: store.peer.name);
    _statusCtrl = TextEditingController(text: store.peer.status);
    _badgeCtrl = TextEditingController(text: store.peer.backBadge);
    _clockCtrl = TextEditingController(text: store.statusBar.clock);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _statusCtrl.dispose();
    _badgeCtrl.dispose();
    _clockCtrl.dispose();
    super.dispose();
  }

  Widget _statusBarEditors() {
    final sb = store.statusBar;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: TextField(
            controller: _clockCtrl,
            decoration: const InputDecoration(
              labelText: 'Saat (ör. 01:54)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) =>
                store.updateStatusBar(sb.copyWith(clock: v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              const Text('Şarj:'),
              Expanded(
                child: Slider(
                  value: sb.battery.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${sb.battery}%',
                  onChanged: (v) => store
                      .updateStatusBar(sb.copyWith(battery: v.round())),
                ),
              ),
              SizedBox(
                  width: 44,
                  child: Text('${sb.battery}%',
                      textAlign: TextAlign.right)),
            ],
          ),
        ),
        SwitchListTile(
          dense: true,
          title: const Text('Şarj oluyor (şimşek)'),
          value: sb.charging,
          onChanged: (v) =>
              store.updateStatusBar(sb.copyWith(charging: v)),
        ),
        SwitchListTile(
          dense: true,
          title: const Text('Wi-Fi göster'),
          value: sb.wifi,
          onChanged: (v) => store.updateStatusBar(sb.copyWith(wifi: v)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Text('Sinyal:'),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 4, label: Text('4')),
                  ],
                  selected: {sb.signal},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      store.updateStatusBar(sb.copyWith(signal: s.first)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _savePeer() {
    store.updatePeer(store.peer.copyWith(
      name: _nameCtrl.text,
      status: _statusCtrl.text,
      backBadge: _badgeCtrl.text,
    ));
  }

  Future<void> _pickAvatar() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    store.updatePeer(store.peer.copyWith(avatarAsset: x.path));
  }

  Future<void> _addMessage() async {
    final created = await Navigator.of(context).push<ChatMessage>(
      MaterialPageRoute(
        builder: (_) => MessageEditorScreen(
          picker: _picker,
          initial: ChatMessage(id: store.nextId(), time: '13:46'),
        ),
      ),
    );
    if (created != null) store.addMessage(created);
  }

  Future<void> _editMessage(int index) async {
    final edited = await Navigator.of(context).push<ChatMessage>(
      MaterialPageRoute(
        builder: (_) => MessageEditorScreen(
          picker: _picker,
          initial: store.messages[index],
        ),
      ),
    );
    if (edited != null) store.updateMessage(index, edited);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final messages = store.messages;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Düzenle'),
            backgroundColor: const Color(0xFF008069),
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'reset') {
                    store.resetToDefault();
                    _nameCtrl.text = store.peer.name;
                    _statusCtrl.text = store.peer.status;
                    _badgeCtrl.text = store.peer.backBadge;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'reset', child: Text('Varsayılana sıfırla')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 90),
            children: [
              _section('Görünüm'),
              // Platform seçimi: iOS / Android
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    const Text('Telefon stili:',
                        style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<UiPlatform>(
                        segments: const [
                          ButtonSegment(
                              value: UiPlatform.ios,
                              label: Text('iPhone'),
                              icon: Icon(Icons.phone_iphone)),
                          ButtonSegment(
                              value: UiPlatform.android,
                              label: Text('Android'),
                              icon: Icon(Icons.phone_android)),
                        ],
                        selected: {store.platform},
                        onSelectionChanged: (s) =>
                            store.setPlatform(s.first),
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Gece modu (koyu tema)'),
                value: store.isDark,
                onChanged: store.setDark,
              ),
              const Divider(height: 1),

              _section('Üst çubuk (saat / wifi / şarj)'),
              _statusBarEditors(),
              const Divider(height: 1),

              _section('Kişi'),
              ListTile(
                leading: GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFB7C0C5),
                    backgroundImage: _avatarImage(),
                    child: _avatarImage() == null
                        ? const Icon(Icons.add_a_photo,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                title: const Text('Profil fotoğrafı'),
                subtitle: const Text('Değiştirmek için dokun'),
              ),
              _textField('İsim', _nameCtrl),
              _textField('Durum (ör. çevrimiçi, son görülme...)', _statusCtrl),
              _textField('Geri okundaki sayı (ör. 12, boş bırakılabilir)',
                  _badgeCtrl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savePeer,
                    child: const Text('Kişi bilgilerini kaydet'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              _section('Mesajlar (${messages.length})'),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Sürükleyerek sırala • dokunarak düzenle • sağa kaydırarak sil',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: true,
                itemCount: messages.length,
                onReorder: store.reorder,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  return Dismissible(
                    key: ValueKey('msg_${m.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => store.removeAt(index),
                    child: ListTile(
                      leading: Icon(_iconFor(m)),
                      title: Text(_titleFor(m),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(_subtitleFor(m)),
                      trailing: const Icon(Icons.drag_handle),
                      onTap: () => _editMessage(index),
                    ),
                  );
                },
              ),

              const Divider(height: 1),
              _scheduledSection(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addMessage,
            backgroundColor: const Color(0xFF008069),
            icon: const Icon(Icons.add),
            label: const Text('Mesaj ekle'),
          ),
        );
      },
    );
  }

  Widget _scheduledSection() {
    final list = store.scheduled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('Zamanlanmış mesajlar (${list.length})'),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '"Başlat"a basınca, her mesaj kendi süresi dolunca sohbete '
            'kendiliğinden düşer. Gelen metin mesajından önce "yazıyor..." '
            'görünür.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        ...list.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Dismissible(
            key: ValueKey('sched_${s.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => store.removeScheduledAt(i),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF008069),
                radius: 18,
                child: Text('${s.delaySeconds}s',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
              ),
              title: Text(_titleFor(s.message),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${s.message.isMe ? "Giden" : "Gelen"} • ${s.delaySeconds} sn sonra'),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _editScheduled(i),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addScheduled,
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Zamanlı ekle'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: list.isEmpty
                      ? null
                      : () {
                          store.startSchedule();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Başladı! Sohbete dön; mesajlar sırayla düşecek.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Başlat'),
                ),
              ),
            ],
          ),
        ),
        if (list.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextButton.icon(
              onPressed: () {
                store.cancelSchedule();
                store.clearScheduled();
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Tümünü temizle / durdur'),
            ),
          ),
      ],
    );
  }

  Future<void> _addScheduled() async {
    final created = await Navigator.of(context).push<ChatMessage>(
      MaterialPageRoute(
        builder: (_) => MessageEditorScreen(
          picker: _picker,
          initial: ChatMessage(id: 'tmp', time: _peerNowHint()),
        ),
      ),
    );
    if (created == null) return;
    final delay = await _askDelay(5);
    if (delay == null) return;
    store.addScheduled(ScheduledMessage(
      id: store.nextScheduledId(),
      message: created.copyWith(),
      delaySeconds: delay,
    ));
  }

  Future<void> _editScheduled(int index) async {
    final s = store.scheduled[index];
    final edited = await Navigator.of(context).push<ChatMessage>(
      MaterialPageRoute(
        builder: (_) => MessageEditorScreen(
          picker: _picker,
          initial: s.message,
        ),
      ),
    );
    if (edited == null) return;
    final delay = await _askDelay(s.delaySeconds);
    if (delay == null) return;
    store.updateScheduled(
        index, s.copyWith(message: edited, delaySeconds: delay));
  }

  String _peerNowHint() => store.statusBar.clock;

  /// Gecikme (saniye) sorar.
  Future<int?> _askDelay(int initial) async {
    final ctrl = TextEditingController(text: '$initial');
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kaç saniye sonra gelsin?'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: 'saniye',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.pop(ctx, (v == null || v < 1) ? 1 : v);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  ImageProvider? _avatarImage() {
    final p = store.peer.avatarAsset;
    if (p == null || p.isEmpty) return null;
    if (p.startsWith('assets/')) return AssetImage(p);
    return null; // dosya yolu CircleAvatar'da FileImage gerektirir; basit tutuldu
  }

  IconData _iconFor(ChatMessage m) {
    switch (m.type) {
      case ItemType.dateSeparator:
        return Icons.calendar_today;
      case ItemType.unreadSeparator:
        return Icons.mark_chat_unread_outlined;
      case ItemType.deleted:
        return Icons.block;
      case ItemType.viewOnce:
        switch (m.mediaKind) {
          case MediaKind.video:
            return Icons.videocam_outlined;
          case MediaKind.audio:
            return Icons.mic_none;
          default:
            return Icons.photo_outlined;
        }
      case ItemType.text:
        return m.isMe ? Icons.south_east : Icons.north_west;
    }
  }

  String _titleFor(ChatMessage m) {
    switch (m.type) {
      case ItemType.dateSeparator:
        return 'Tarih ayracı: ${m.text}';
      case ItemType.unreadSeparator:
        return 'Okunmamış ayracı: ${m.text}';
      case ItemType.deleted:
        return 'Silinen mesaj';
      case ItemType.viewOnce:
        final lbl = m.mediaLabel.isEmpty ? '(etiket)' : m.mediaLabel;
        return 'Tek seferlik: $lbl';
      case ItemType.text:
        return m.text.isEmpty ? '(boş mesaj)' : m.text;
    }
  }

  String _subtitleFor(ChatMessage m) {
    final side = m.isMe ? 'Giden' : 'Gelen';
    if (m.type == ItemType.dateSeparator ||
        m.type == ItemType.unreadSeparator) {
      return 'Ayraç';
    }
    return '$side • ${m.time}';
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF008069),
          ),
        ),
      );

  Widget _textField(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: TextField(
          controller: c,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );
}
