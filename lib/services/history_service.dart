import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';

class HistoryService {
  static const String _historyKey = 'scan_history';
  
  Future<void> saveScan(ScanHistory scan) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    history.add(jsonEncode(scan.toJson()));
    await prefs.setStringList(_historyKey, history);
  }
  
  Future<List<ScanHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    return history.reversed
        .map((item) => ScanHistory.fromJson(jsonDecode(item)))
        .toList();
  }
  
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
  
  Future<void> deleteScan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    history.removeWhere((item) {
      final scan = ScanHistory.fromJson(jsonDecode(item));
      return scan.id == id;
    });
    await prefs.setStringList(_historyKey, history);
  }
}