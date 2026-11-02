import 'package:flutter/material.dart';

import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';

/// Pantalla de configuración local de audio y accesibilidad
class SettingsScreen extends StatefulWidget {
  final LocalPersistenceService storage;

  const SettingsScreen({super.key, required this.storage});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sfxEnabled;
  late bool _shakeEnabled;

  @override
  void initState() {
    super.initState();
    _sfxEnabled = widget.storage.isSfxEnabled;
    _shakeEnabled = widget.storage.isScreenShakeEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CONFIGURACIÓN',
          style: TextStyle(
            color: ArcadeColors.neonCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionHeader('AUDIO Y EFECTOS'),
            SwitchListTile(
              activeThumbColor: ArcadeColors.neonGreen,
              title: const Text(
                'Efectos de Sonido (SFX)',
                style: TextStyle(color: ArcadeColors.textPrimary, fontSize: 14),
              ),
              subtitle: const Text(
                'Sonidos retro arcade y retroalimentación',
                style: TextStyle(color: ArcadeColors.textMuted, fontSize: 12),
              ),
              value: _sfxEnabled,
              onChanged: (val) async {
                setState(() => _sfxEnabled = val);
                await widget.storage.setSfxEnabled(val);
              },
            ),
            const Divider(color: ArcadeColors.surfaceBorder),
            _buildSectionHeader('ACCESIBILIDAD'),
            SwitchListTile(
              activeThumbColor: ArcadeColors.neonGreen,
              title: const Text(
                'Sacudida de Pantalla (Screen Shake)',
                style: TextStyle(color: ArcadeColors.textPrimary, fontSize: 14),
              ),
              subtitle: const Text(
                'Impactos y efectos de vibración visual',
                style: TextStyle(color: ArcadeColors.textMuted, fontSize: 12),
              ),
              value: _shakeEnabled,
              onChanged: (val) async {
                setState(() => _shakeEnabled = val);
                await widget.storage.setScreenShakeEnabled(val);
              },
            ),
            const Divider(color: ArcadeColors.surfaceBorder),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'VERSIÓN 1.0.0 • 100% OFFLINE',
                style: TextStyle(
                  color: ArcadeColors.textMuted.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: ArcadeColors.arcadeMagenta,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
