import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecorderService {
  final AudioRecorder _record = AudioRecorder();
  String? _audioPath;

  Future<void> startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        _audioPath = '${appDocumentsDir.path}/flowmem_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _record.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioPath!,
        );
      }
    } catch (e) {
      print('Error starting record: $e');
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _record.stop();
      return path ?? _audioPath;
    } catch (e) {
      print('Error stopping record: $e');
      return null;
    }
  }

  void dispose() {
    _record.dispose();
  }
}
