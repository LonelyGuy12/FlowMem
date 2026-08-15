import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_recorder_service.dart';
import '../services/api_service.dart';
import '../providers/dashboard_provider.dart';

class RecorderWidget extends StatefulWidget {
  const RecorderWidget({Key? key}) : super(key: key);

  @override
  _RecorderWidgetState createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget> with SingleTickerProviderStateMixin {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final ApiService _apiService = ApiService();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _recorderService.stopRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (path != null) {
        // Send to API
        final success = await _apiService.processAudio(path);
        if (success && mounted) {
          // Refresh dashboard
          Provider.of<DashboardProvider>(context, listen: false).loadDashboard();
        }
      }
      
      setState(() {
        _isProcessing = false;
      });
    } else {
      // Start recording
      await _recorderService.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isProcessing ? null : _toggleRecording,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording 
                  ? Colors.red.withOpacity(0.5 + (_animationController.value * 0.5))
                  : Colors.deepPurple,
              boxShadow: [
                if (_isRecording)
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20 * _animationController.value,
                    spreadRadius: 5 * _animationController.value,
                  )
              ],
            ),
            child: Icon(
              _isProcessing ? Icons.hourglass_empty : (_isRecording ? Icons.stop : Icons.mic),
              color: Colors.white,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}
