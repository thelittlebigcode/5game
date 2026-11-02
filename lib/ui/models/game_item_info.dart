import 'package:flutter/material.dart';

enum GameStatus { playable, comingSoon }

class GameItemInfo {
  final String id;
  final String title;
  final String subtitle;
  final Color accentColor;
  final GameStatus status;

  const GameItemInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.status,
  });
}
