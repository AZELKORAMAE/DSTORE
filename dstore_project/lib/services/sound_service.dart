import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Sons disponibles
  static const Map<String, String> _sounds = {
    'beep': 'sounds/beep.mp3',
    'success': 'sounds/success.mp3',
    'notification': 'sounds/notification.mp3',
    'cash_register': 'sounds/cash_register.mp3',
    'none': '',
  };

  /// Joue un son par son ID
  static Future<void> playSound(String soundId) async {
    try {
      if (soundId == 'none' || !_sounds.containsKey(soundId)) {
        return;
      }

      final soundPath = _sounds[soundId]!;
      if (soundPath.isNotEmpty) {
        try {
          await _audioPlayer.play(AssetSource(soundPath));
        } catch (audioError) {
          print(
              'Fichier audio non trouvé: $soundPath, utilisation de la vibration');
          // Fallback: utiliser la vibration système si le fichier audio n'existe pas
          _playFallbackSound(soundId);
        }
      }
    } catch (e) {
      print('Erreur lors de la lecture du son: $e');
      // Fallback: utiliser la vibration système
      _playFallbackSound(soundId);
    }
  }

  /// Joue un son de remplacement (vibration ou son système)
  static void _playFallbackSound(String soundId) {
    switch (soundId) {
      case 'beep':
      case 'notification':
        HapticFeedback.lightImpact();
        break;
      case 'success':
        HapticFeedback.mediumImpact();
        break;
      case 'cash_register':
        HapticFeedback.heavyImpact();
        break;
      default:
        HapticFeedback.lightImpact();
    }
  }

  /// Joue le son de scan par défaut
  static Future<void> playScanSound() async {
    await playSound('beep');
  }

  /// Joue le son de succès
  static Future<void> playSuccessSound() async {
    await playSound('success');
  }
  
  /// Joue le son de succès (alias pour compatibilité)
  static Future<void> playSuccess() async {
    await playSuccessSound();
  }

  /// Joue le son de notification
  static Future<void> playNotificationSound() async {
    await playSound('notification');
  }
  
  /// Joue le son d'erreur
  static Future<void> playError() async {
    await playSound('notification');
  }

  /// Joue le son de caisse enregistreuse
  static Future<void> playCashRegisterSound() async {
    await playSound('cash_register');
  }

  /// Arrête tous les sons
  static Future<void> stopAllSounds() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Erreur lors de l\'arrêt des sons: $e');
    }
  }

  /// Configure le volume
  static Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Erreur lors du réglage du volume: $e');
    }
  }

  /// Libère les ressources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Erreur lors de la libération des ressources audio: $e');
    }
  }
}
