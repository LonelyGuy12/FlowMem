import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  DashboardData? _data;
  bool _isLoading = false;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    _data = await _apiService.fetchDashboard();
    
    _isLoading = false;
    notifyListeners();
  }
}
