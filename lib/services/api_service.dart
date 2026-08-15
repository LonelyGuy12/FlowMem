import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to localhost mapping
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<DashboardData?> fetchDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard'));
      if (response.statusCode == 200) {
        return DashboardData.fromJson(jsonDecode(response.body));
      } else {
        print('Error fetching dashboard: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching dashboard: $e');
      return null;
    }
  }

  Future<bool> processAudio(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process-audio'));
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error processing audio: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception processing audio: $e');
      return false;
    }
  }
}
