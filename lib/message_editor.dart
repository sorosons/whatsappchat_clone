import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';

/// Tek bir mesaj/öğeyi oluşturma ve düzenleme ekranı.
/// Sonuç olarak düzenlenmiş ChatMessage'ı pop ile geri döndürür.
class MessageEditorScreen extends StatefulWidget {
  final ChatMessage initial;
  final ImagePicker picker;
  const MessageEditorScreen({
    super.key,
    required this.initial,
    required this.picker,
  });

  @override
  State<MessageEditorScreen> createState() => _MessageEditorScreenState();
}

class _MessageEditorScreenState extends State<MessageEditorScreen> {
  late ItemType _type;
  late bool _isMe;
  late MessageStatus _status;
  late bool _edited;
  late MediaKind _mediaKind;
  String? _mediaAsset;

  late final TextEditingController _textCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    _type = m.type;
    _isMe = m.isMe;
    _status = m.status == MessageStatus.none ? MessageStatus.read : m.status;
    _edited = m.edited;
    _mediaKind = m.mediaKind ?? MediaKind.photo;
    _mediaAsset = m.mediaAsset;
    _textCtrl = TextEditingController(text: m.text);
    _timeCtrl = TextEditingController(text: m.time);
    _labelCtrl = TextEditingController(text: m.mediaLabel);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _timeCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final isVideo = _mediaKind == MediaKind.video;
    final x = isVideo
        ? await widget.picker.pickVideo(source: ImageSource.gallery)
        : await widget.picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    setState(() => _mediaAsset = x.path);
  }

  void _save() {
    final result = widget.initial.copyWith(
      type: _type,
      text: _textCtrl.text,
      isMe: _isMe,
      time: _timeCtrl.text,
      status: _isMe ? _status : MessageStatus.none,
      edited: _edited,
      mediaKind: _mediaKind,
      mediaLabel: _labelCtrl.text,
      mediaAsset: _mediaAsset,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isViewOnce = _type == ItemType.viewOnce;
    final isSeparator = _type == ItemType.dateSeparator ||
        _type == ItemType.unreadSeparator;
    final isText = _type == ItemType.text;
    final isDeleted = _type == ItemType.deleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajı düzenle'),
        backgroundColor: const Color(0xFF008069),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('KAYDET',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tür', style: _lblStyle),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _typeChip('Metin', ItemType.text),
              _typeChip('Tek seferlik', ItemType.viewOnce),
              _typeChip('Tarih ayracı', ItemType.dateSeparator),
              _typeChip('Okunmamış ayracı', ItemType.unreadSeparator),
              _typeChip('Silinen mesaj', ItemType.deleted),
            ],
          ),
          const SizedBox(height: 16),

          // Yön (ayraçlarda gizli)
          if (!isSeparator) ...[
            const Text('Yön', style: _lblStyle),
            const SizedBox(height: 6),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Gelen')),
                ButtonSegment(value: true, label: Text('Giden')),
              ],
              selected: {_isMe},
              onSelectionChanged: (s) => setState(() => _isMe = s.first),
            ),
            const SizedBox(height: 16),
          ],

          // Metin alanı (metin, ayraç ve silinen için)
          if (isText || isSeparator || isDeleted)
            _field(
              isSeparator
                  ? 'Ayraç yazısı (ör. Bugün, Dün, 3 okunmamış mesaj)'
                  : isDeleted
                      ? 'Silinen mesaj yazısı (boş = "Bu mesaj silindi.")'
                      : 'Mesaj metni',
              _textCtrl,
              maxLines: isText ? 4 : 1,
            ),

          // View-once alanları
          if (isViewOnce) ...[
            const Text('Medya türü', style: _lblStyle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _mediaChip('Fotoğraf', MediaKind.photo),
                _mediaChip('Video', MediaKind.video),
                _mediaChip('Sesli mesaj', MediaKind.audio),
              ],
            ),
            const SizedBox(height: 12),
            _field('Etiket (ör. Fotoğraf / Video / Foto — istediğin dil)',
                _labelCtrl),
            const SizedBox(height: 8),
            _MediaPreview(path: _mediaAsset),
            const SizedBox(height: 8),
            if (_mediaKind != MediaKind.audio)
              OutlinedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(_mediaKind == MediaKind.video
                    ? 'Galeriden video seç'
                    : 'Galeriden fotoğraf seç'),
              ),
          ],

          // Saat (ayraçlarda gizli)
          if (!isSeparator) ...[
            const SizedBox(height: 12),
            _field('Saat (ör. 13:46)', _timeCtrl),
          ],

          // Giden mesaj seçenekleri
          if (!isSeparator && _isMe) ...[
            const SizedBox(height: 12),
            const Text('Tik durumu', style: _lblStyle),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _statusChip('Tek tik (✓)', MessageStatus.sent),
                _statusChip('Çift gri (✓✓)', MessageStatus.delivered),
                _statusChip('Çift mavi (✓✓)', MessageStatus.read),
                _statusChip('Yok', MessageStatus.none),
              ],
            ),
          ],

          if (isText) ...[
            const SizedBox(height: 4),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('"Düzenlendi" etiketi göster'),
              value: _edited,
              onChanged: (v) => setState(() => _edited = v ?? false),
            ),
          ],

          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Kaydet')),
        ],
      ),
    );
  }

  Widget _typeChip(String label, ItemType t) => ChoiceChip(
        label: Text(label),
        selected: _type == t,
        onSelected: (_) => setState(() => _type = t),
      );

  Widget _mediaChip(String label, MediaKind k) => ChoiceChip(
        label: Text(label),
        selected: _mediaKind == k,
        onSelected: (_) => setState(() {
          _mediaKind = k;
          if (_labelCtrl.text.isEmpty) _labelCtrl.text = label;
        }),
      );

  Widget _statusChip(String label, MessageStatus s) => ChoiceChip(
        label: Text(label),
        selected: _status == s,
        onSelected: (_) => setState(() => _status = s),
      );

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: TextField(
          controller: c,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );

  static const _lblStyle =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
}

class _MediaPreview extends StatelessWidget {
  final String? path;
  const _MediaPreview({this.path});

  @override
  Widget build(BuildContext context) {
    final p = path;
    Widget child;
    if (p == null || p.isEmpty) {
      child = const Center(
        child: Text('Henüz medya seçilmedi',
            style: TextStyle(color: Colors.grey)),
      );
    } else if (p.startsWith('assets/')) {
      child = Image.asset(p, fit: BoxFit.cover);
    } else if (!kIsWeb) {
      child = Image.file(File(p), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.movie, size: 40)));
    } else {
      child = const Center(child: Text('(önizleme yok)'));
    }
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
