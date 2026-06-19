import 'package:flutter/material.dart';

/// Açık/koyu tema renk kümesi. Tüm ekranlar bu nesneden renk alır.
class ChatTheme {
  final bool isDark;

  // Üst bar (iOS'ta sohbet arka planıyla aynı tonda, ayrı yeşil değil)
  final Color appBarBg;
  final Color appBarText;
  final Color appBarSubtitle;
  final Color appBarIcon;

  // Sohbet arka planı + desen
  final Color chatBg;
  final Color doodle;

  // Baloncuklar
  final Color incomingBubble;
  final Color outgoingBubble;
  final Color bubbleText;

  // İkincil metinler
  final Color timeStamp;
  final Color systemPill; // tarih ayracı / "Bu mesaj silindi" arka planı
  final Color systemPillText;
  final Color unreadPill;
  final Color unreadPillText;

  // Tikler
  final Color tickBlue;
  final Color tickGrey;

  // Input bar
  final Color inputBarBg;
  final Color inputFieldBg;
  final Color inputHint;
  final Color inputIcon;

  // View once
  final Color viewOnceRing;
  final Color viewOnceText;

  // Tam ekran medya bar
  final Color mediaBar;
  final Color mediaBarText;
  final Color mediaBarSubtitle;
  final Color mediaBarIcon;

  // "Devamını okuyun" / link rengi
  final Color link;

  const ChatTheme({
    required this.isDark,
    required this.appBarBg,
    required this.appBarText,
    required this.appBarSubtitle,
    required this.appBarIcon,
    required this.chatBg,
    required this.doodle,
    required this.incomingBubble,
    required this.outgoingBubble,
    required this.bubbleText,
    required this.timeStamp,
    required this.systemPill,
    required this.systemPillText,
    required this.unreadPill,
    required this.unreadPillText,
    required this.tickBlue,
    required this.tickGrey,
    required this.inputBarBg,
    required this.inputFieldBg,
    required this.inputHint,
    required this.inputIcon,
    required this.viewOnceRing,
    required this.viewOnceText,
    required this.mediaBar,
    required this.mediaBarText,
    required this.mediaBarSubtitle,
    required this.mediaBarIcon,
    required this.link,
  });

  // Klasik yeşil Android WhatsApp üst bar rengi (tema fark etmeksizin).
  Color get androidBarBg =>
      isDark ? const Color(0xFF1F2C33) : const Color(0xFF008069);

  static const ChatTheme light = ChatTheme(
    isDark: false,
    appBarBg: Color(0xFFF6F5F3),
    appBarText: Color(0xFF000000),
    appBarSubtitle: Color(0xFF8E8E93),
    appBarIcon: Color(0xFF1C1C1E),
    chatBg: Color(0xFFEDE7DD),
    doodle: Color(0xFFD7CDBF),
    incomingBubble: Color(0xFFFFFFFF),
    outgoingBubble: Color(0xFFD9FDD3),
    bubbleText: Color(0xFF111111),
    timeStamp: Color(0xFF8A8F93),
    systemPill: Color(0xFFFFFFFF),
    systemPillText: Color(0xFF54656F),
    unreadPill: Color(0xFFFFFFFF),
    unreadPillText: Color(0xFF54656F),
    tickBlue: Color(0xFF34B7F1),
    tickGrey: Color(0xFF8A8F93),
    inputBarBg: Color(0xFFF6F5F3),
    inputFieldBg: Color(0xFFFFFFFF),
    inputHint: Color(0xFF8E8E93),
    inputIcon: Color(0xFF8E8E93),
    viewOnceRing: Color(0xFF09CA66),
    viewOnceText: Color(0xFF111111),
    mediaBar: Color(0xFFF6F5F3),
    mediaBarText: Color(0xFF000000),
    mediaBarSubtitle: Color(0xFF8E8E93),
    mediaBarIcon: Color(0xFF128C7E),
    link: Color(0xFF027EB5),
  );

  static const ChatTheme dark = ChatTheme(
    isDark: true,
    appBarBg: Color(0xFF1F2C33),
    appBarText: Color(0xFFE9EDEF),
    appBarSubtitle: Color(0xFF8696A0),
    appBarIcon: Color(0xFF00A884),
    chatBg: Color(0xFF0B141A),
    doodle: Color(0xFF18242C),
    incomingBubble: Color(0xFF1F2C33),
    outgoingBubble: Color(0xFF005C4B),
    bubbleText: Color(0xFFE9EDEF),
    timeStamp: Color(0xFF8696A0),
    systemPill: Color(0xFF1D282F),
    systemPillText: Color(0xFF8696A0),
    unreadPill: Color(0xFF1D282F),
    unreadPillText: Color(0xFF8696A0),
    tickBlue: Color(0xFF53BDEB),
    tickGrey: Color(0xFF8696A0),
    inputBarBg: Color(0xFF1F2C33),
    inputFieldBg: Color(0xFF2A3942),
    inputHint: Color(0xFF8696A0),
    inputIcon: Color(0xFF8696A0),
    viewOnceRing: Color(0xFF00D959),
    viewOnceText: Color(0xFFE9EDEF),
    mediaBar: Color(0xFF1F2C33),
    mediaBarText: Color(0xFFE9EDEF),
    mediaBarSubtitle: Color(0xFF8696A0),
    mediaBarIcon: Color(0xFF00A884),
    link: Color(0xFF53BDEB),
  );
}
