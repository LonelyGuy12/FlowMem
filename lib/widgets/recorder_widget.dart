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
  
  // Vercel AMOLED Colors
  static const vercelBlack = Color(0xFF000000);
  static const vercelGray = Color(0xFF1A1A1A);
  static const vercelBorder = Color(0xFF2A2A2A);
  static const vercelAccent = Color(0xFF0070F3);
  static const vercelError = Color(0xFFE00);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status text
          if (_isRecording || _isProcessing)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: vercelGray,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: vercelBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isRecording)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: vercelError,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (_isProcessing)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(vercelAccent),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _isRecording ? 'Recording...' : 'Processing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Main button
          GestureDetector(
            onTap: _isProcessing ? null : _toggleRecording,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isRecording 
                          ? [
                              vercelError,
                              Color(0xFFFF4444),
                            ]
                          : [
                              vercelAccent,
                              Color(0xFF0055CC),
                            ],
                    ),
                    boxShadow: [
                      if (_isRecording)
                        BoxShadow(
                          color: vercelError.withOpacity(0.3 + (_animationController.value * 0.3)),
                          blurRadius: 20 + (10 * _animationController.value),
                          spreadRadius: 2 + (3 * _animationController.value),
                        )
                      else
                        BoxShadow(
                          color: vercelAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: vercelBlack,
                    ),
                    child: Icon(
                      _isProcessing 
                          ? Icons.hourglass_empty_rounded 
                          : (_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
